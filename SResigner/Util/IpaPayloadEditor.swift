//
//  IpaPayloadEditor.swift
//  SResigner
//
//  Created by jerry on 2018/11/21.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
import MachoHandle

private func descriptionError(_ errorDescription: String) -> NSError{
    return NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : errorDescription])
}

class IpaPayloadHandle{
    enum ResignBundleIDSettingStrategy{
        case keepRaw
        case autoChangeByMobileprovision
        case changeTo(String)
    }
    let fm: FileManager = FileManager.default
    let payload: URL
    let machoHandler: MachoHandle!
    let mainBundle: EditableBundle!
    init(payload: URL) throws{
        self.payload = payload
        let mainAppPath = try { () -> String in
            for sub in try! FileManager.default.contentsOfDirectory(atPath: payload.path){
                if sub.hasSuffix("app"){
                    return payload.appendingPathComponent(sub).path
                }
            }
            throw descriptionError("Ipa file structure has problems: Can not find 'app' file")
        }()
        
        self.mainBundle = EditableBundle.init(path: mainAppPath)
        
        if !FileManager.default.fileExists(atPath: self.mainBundle.executablePath!) {
            throw descriptionError("Ipa file structure has problems: executable file(\(self.mainBundle.executablePath!) not exists)")
        }
        self.machoHandler = MachoHandle.init(machoPath: self.mainBundle.executablePath!)
    }
    
    //MARK: - Macho Dylib link Handle
    func getDylibLinks() -> [String]{
        let fatArchs = machoHandler.getFatArchs()
        var dylibCmds: [DylibCommand] = []
        if fatArchs.count > 0{
            for arch in fatArchs{
                dylibCmds = machoHandler.getDylibCommand(in: arch)
                break
            }
        }else{
            dylibCmds = machoHandler.getDylibCommand(in: nil)
        }
        return dylibCmds.map{ machoHandler.getLinkName(forDylibCmd: $0)}
    }
    
    func injectDylib(dylibFilePath: String, link: String) throws{
        if dylibFilePath.hasSuffix("framework"){
            let embeddedRelativePath = "Frameworks/\(URL(fileURLWithPath: dylibFilePath).lastPathComponent)"
            let absEmbedPath = self.mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath)
            try! FileManager.default.copyItem(atPath: dylibFilePath, toPath: absEmbedPath.path, shouldOverwrite: true, withIntermediateDirectories: true)
            self.machoHandler.addDylibLink(link)
        }else{
            let embeddedRelativePath = link.replacingOccurrences(of: "@executable_path/", with: "")
            let absEmbedPath = self.mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath)
            try! FileManager.default.copyItem(atPath: dylibFilePath, toPath: absEmbedPath.path, shouldOverwrite: true, withIntermediateDirectories: true)
            self.machoHandler.addDylibLink(link)
        }
    }
    
    func addDylibLink(link: String){
        self.machoHandler.addDylibLink(link)
    }
    
    func deleteDylibLink(link: String) throws{
        //remove link
        self.machoHandler.removeLinkedDylib(link)
        //remove embedPath (if exists)
        if link.starts(with: "@executable_path"){
            let embeddedRelativePath = link.replacingOccurrences(of: "@executable_path/", with: "")
            try fm.removeItemIfExists(at: mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath))
        }else if link.starts(with: "@loader_path"){
            let embeddedRelativePath = link.replacingOccurrences(of: "@loader_path/", with: "")
            try fm.removeItemIfExists(at: mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath))
        }
    }
    
    //MARK: - Metadata Edit
    func currentNestedAppBundles() -> [EditableBundle]{
        guard let pluginsDir = mainBundle.builtInPlugInsPath else{
            return []
        }
        if !fm.fileExists(atPath: pluginsDir){
            return []
        }
        let searchOpt = FileSearcher.SearchOption.init()
        searchOpt.maxSearchDepth = 1
        return FileSearcher.searchItems(nameMatchPattern: "(.*\\.app)|(.*\\.appex)", inDirectory: pluginsDir, option: searchOpt).map{ EditableBundle.init(path: $0) }
    }
    func removeNestedAppBundle(_ nestedAppBundle: Bundle) throws{
        try FileManager.default.removeItem(at: nestedAppBundle.bundleURL)
    }
    func addResource(_ resourceFilePath: String, embeddedRelativePath: String, shouldOverwrite: Bool) throws{
        let absEmbeddedPath = self.mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath).path
        try self.fm.copyItem(atPath: resourceFilePath, toPath: absEmbeddedPath, shouldOverwrite: shouldOverwrite, withIntermediateDirectories: true)
    }
    
    func removeResource(_ embeddedRelativePath: String, shouldRemoveEmptyParent: Bool = true) throws{
        let dstPath = self.mainBundle.bundleURL.appendingPathComponent(embeddedRelativePath)
        if self.fm.fileExists(atPath: dstPath.path){
            try self.fm.removeItem(atPath: dstPath.path)
        }
        if shouldRemoveEmptyParent{
            var parentDir = dstPath.deletingLastPathComponent()
            let mainBundlePath = self.mainBundle.bundlePath
            while !parentDir.path.elementsEqual(mainBundlePath) {
                if try self.fm.contentsOfDirectory(atPath: parentDir.path).count <= 0{
                    try self.fm.removeItem(at: parentDir)
                }
                parentDir = parentDir.deletingLastPathComponent()
            }
        }
    }
    //MARK: - Resign
    //返回：resignedIpaPath
    func resign(mainAppNewPPFPath: String,
                nestAppBundleIDToPPFPath: [String:String],
                codeSignID: String,
                extraResignResources: [String],
                extraResignFrameworks: [String],
                resignBundleIDSettingStrategy: ResignBundleIDSettingStrategy,
                process: ((_ onSignFile: String) -> Void)?) throws{
        let nestedAppPaths = self.currentNestedAppBundles().map{$0.bundlePath}
  
        let extraSignSingleFiels = extraResignResources.map{self.mainBundle.bundleURL.appendingPathComponent($0).path}
        let syn = DispatchGroup.init()
        let step = 1
        var i = 0
        var allcount = extraSignSingleFiels.count
        var signError: Error? = nil
        while i < allcount {
            let endIndex = min(i + step - 1, allcount - 1)
            syn.enter()
            let copyI = i
            DispatchQueue.global().async {
                let part = extraSignSingleFiels[copyI...endIndex]
                for file in part{
                    Logger.log("sign \(file)")
                    process?(file)
                    do{
                        try ShellCmds.cmdCodeSign(filePath: file,
                                                  signID: codeSignID, entitlementFilePath: nil)
                    }catch{
                        signError = error
                    }
                }
                syn.leave()
            }
            i = i + step
        }
        syn.wait()
        
        i = 0
        let extraSignFrameworks = extraResignFrameworks.map{self.mainBundle.bundleURL.appendingPathComponent($0).path}
        allcount = extraSignFrameworks.count
        while i < allcount {
            let endIndex = min(i + step - 1, allcount - 1)
            syn.enter()
            let copyI = i
            DispatchQueue.global().async {
                let part = extraSignFrameworks[copyI...endIndex]
                for file in part{
                    Logger.log("sign \(file)")
                    process?(file)
                    do{
                    try ShellCmds.cmdCodeSign(filePath: file,
                                               signID: codeSignID, entitlementFilePath: nil)
                    }catch{
                        signError = error
                    }
                }
                syn.leave()
            }
            i = i + step
        }
        syn.wait()
        
        if signError != nil{
            let r = NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occurred while signing"])
            throw r
        }
        
        for nestedAppPath in nestedAppPaths{
            try self.sign(appPath: URL.init(fileURLWithPath: nestedAppPath),
                          isMainApp: false,
                          mainAppNewPPFPath: mainAppNewPPFPath,
                          nestAppBundleIDToPPFPath: nestAppBundleIDToPPFPath,
                          codeSignID: codeSignID,
                          resignBundleIDSettingStrategy: resignBundleIDSettingStrategy,
                          process: process)
        }
        
        try self.sign(appPath: self.mainBundle!.bundleURL,
                      isMainApp: true,
                      mainAppNewPPFPath: mainAppNewPPFPath,
                      nestAppBundleIDToPPFPath: nestAppBundleIDToPPFPath,
                      codeSignID: codeSignID,
                      resignBundleIDSettingStrategy:resignBundleIDSettingStrategy,
                      process: process)
    }
    
    func sign(appPath: URL,
              isMainApp: Bool,
              mainAppNewPPFPath: String,
              nestAppBundleIDToPPFPath: [String:String],
              codeSignID: String,
              resignBundleIDSettingStrategy: ResignBundleIDSettingStrategy,
              process: ((_ onSignFile: String) -> Void)?) throws{
        let infoPlistPath = appPath.appendingPathComponent("Info.plist")
        let infoPlistData = try Data.init(contentsOf: infoPlistPath, options:[])
        let rawInfoDic = Dictionary<String,Any>.dictionaryWith(plistData: infoPlistData)!
        
        let rawBundleID = rawInfoDic["CFBundleIdentifier"] as! String
        
        guard let newPPFPath = isMainApp ? mainAppNewPPFPath : nestAppBundleIDToPPFPath[rawBundleID] else{
            throw descriptionError("A mobileprovision is needed for: \(appPath)")
        }
        guard let newPPFModel = PPFModel.init(mobileprovisionFilePath: newPPFPath) else {
            throw descriptionError("Provision file:\(newPPFPath) Parsing failed")
        }
        let applicationIdentifierPrefix = newPPFModel.applicationIdentifierPrefix[0]
        let bundleIDInPPF = newPPFModel.entitlements.applicationIdentifier.replacingOccurrences(of: "\(applicationIdentifierPrefix).", with: "")
        
        var finalBundleID: String!
        switch resignBundleIDSettingStrategy {
        case .autoChangeByMobileprovision:
            //wildcard
            if bundleIDInPPF.contains("*"){
                if bundleIDInPPF.elementsEqual("*"){
                    finalBundleID = rawBundleID
                }else{
                    let p = bundleIDInPPF.replacingOccurrences(of: ".", with: "\\.").replacingOccurrences(of: "*", with: ".*")
                    if rawBundleID.isMatch(p){
                        finalBundleID = rawBundleID
                    }else{
                        finalBundleID = bundleIDInPPF.replacingOccurrences(of: "*", with: String.randomStringOfLength(length: 4).lowercased())
                    }
                }
            }else{
                finalBundleID = bundleIDInPPF
            }
        case .keepRaw:
            finalBundleID = rawBundleID
        case .changeTo(let newBundleID):
            finalBundleID = newBundleID
        }
        
        //更新 Info.plist
        if !finalBundleID.elementsEqual(rawBundleID){
            let bundle = EditableBundle.init(url: appPath)
            bundle.updateBundleID(finalBundleID)
        }
        
        //替换 embedded.mobileprovision
        let embeddedPPFPath = appPath.appendingPathComponent("embedded.mobileprovision")
        if FileManager.default.fileExists(atPath: embeddedPPFPath.path){
            try FileManager.default.removeItem(at: embeddedPPFPath)
        }
        try FileManager.default.copyItem(at: URL.init(fileURLWithPath: newPPFPath), to: embeddedPPFPath)
        
        //从 ppf 中导出 entitlements 文件
        let newEntitlements = URL(fileURLWithPath: "/tmp/new(\(newPPFModel.name)).entitlements")
        let newEntitlementsDic = newPPFModel.entitlementsDictionay
        try PropertyListSerialization.data(fromPropertyList: newEntitlementsDic,
                                           format: PropertyListSerialization.PropertyListFormat.xml,
                                           options: 0).write(to: newEntitlements)
        

        //对App进行签名
        Logger.log("sign \(appPath.path)")
        process?(appPath.path)
        try ShellCmds.cmdCodeSign(filePath: appPath.path, signID: codeSignID, entitlementFilePath: newEntitlements.path)
        
        try FileManager.default.removeItem(at: newEntitlements)
    }
    
   
}
