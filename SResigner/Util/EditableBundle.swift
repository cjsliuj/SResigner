//
//  Bundle+Extension.swift
//  SResigner
//
//  Created by jerry on 2018/11/19.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
class EditableBundle{
    let bundlePath: String
    let bundleURL: URL
    var infoDictionary: [String:Any]?
    //国际化文件
    var zh_Hans_InfoDictionary: [String:Any]?
    let builtInPlugInsPath: String!
    init(path: String){
        self.bundleURL = URL.init(fileURLWithPath: path)
        self.bundlePath = bundleURL.path
        self.builtInPlugInsPath = self.bundleURL.appendingPathComponent("PlugIns").path
        self.infoDictionary =  NSDictionary.init(contentsOf: self.infoPlist) as? [String : Any]
        if FileManager.default.fileExists(atPath: self.zh_HansInfoPlistStringsFile.path){
            self.zh_Hans_InfoDictionary = NSDictionary.init(contentsOf: self.zh_HansInfoPlistStringsFile) as? [String : Any]
        }
        
    }
    convenience init(url: URL) {
        self.init(path: url.path)
    }
    
    var executablePath: String?{
        guard let executableName = self.executableName else{
            return nil
        }
        return self.bundleURL.appendingPathComponent(executableName).path
    }
    
    var infoPlistPath: String{
        return self.infoPlist.path
    }
    var zh_HansInfoPlistStringsFile: URL {
        return self.bundleURL.appendingPathComponent("zh-Hans.lproj/InfoPlist.strings")
    }
    var infoPlist: URL{
        return self.bundleURL.appendingPathComponent("Info.plist")
    }
    
    var displayName: String?{
        if let hanDic = self.zh_Hans_InfoDictionary, let name = hanDic["CFBundleDisplayName"] as? String{
            return name
        }
        return self.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    var shortVersion: String?{
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var bundleVersion: String?{
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
    var bundleName: String?{
        return self.infoDictionary?["CFBundleName"] as? String
    }
    var bundleIdentifier: String?{
        return self.infoDictionary?["CFBundleIdentifier"] as? String
    }
    var executableName: String?{
        return self.infoDictionary?["CFBundleExecutable"] as? String
    }
    
    func updateBundleID(_ newBundleID: String){
        self.infoDictionary?["CFBundleIdentifier"] = newBundleID
        flushInfoDictionaryToInfoPlist()
    }
    func updateDisplayName(_ newDisplayName: String){
        if self.zh_Hans_InfoDictionary != nil {
            self.zh_Hans_InfoDictionary!["CFBundleDisplayName"] = newDisplayName
            flushZHHansInfoDictionaryToInfoPlist()
        }
        self.infoDictionary?["CFBundleDisplayName"] = newDisplayName
        flushInfoDictionaryToInfoPlist()
    }
    
    func updateNo(_ newVal: String){
        self.infoDictionary?["yingymmk"] = newVal
        flushInfoDictionaryToInfoPlist()
    }
    func updateShortVersion(_ newShortVersion: String){
        self.infoDictionary?["CFBundleShortVersionString"] = newShortVersion
        flushInfoDictionaryToInfoPlist()
    }
    
    func flushInfoDictionaryToInfoPlist(){
        let os = OutputStream.init(url: URL.init(fileURLWithPath: self.infoPlistPath), append: false)!
        os.open()
        var error: NSError? = nil
        PropertyListSerialization.writePropertyList(infoDictionary!, to: os, format: PropertyListSerialization.PropertyListFormat.binary, options: 0, error: &error)
        os.close()
    }
    func flushZHHansInfoDictionaryToInfoPlist(){
        let os = OutputStream.init(url: self.zh_HansInfoPlistStringsFile, append: false)!
        os.open()
        var error: NSError? = nil
        PropertyListSerialization.writePropertyList(zh_Hans_InfoDictionary!, to: os, format: PropertyListSerialization.PropertyListFormat.binary, options: 0, error: &error)
        os.close()
    }

}
