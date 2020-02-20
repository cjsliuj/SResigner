//
//  MainVC.swift
//  SResigner
//
//  Created by jerry on 2017/11/29.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Cocoa
import Foundation
class MainVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource, DragDropViewDelegate{
 
    @IBOutlet weak var _scrv: NSScrollView!
    static let share = MainVC()
    @IBOutlet var _contentView: NSView!
    @IBOutlet weak var _exportBtn: NSButton!
    @IBOutlet weak var _tbvOfDylibLinks: NSTableView!
    @IBOutlet weak var _ipaSelectBtn: NSButton!
    @IBOutlet weak var _addDylibLinkBtn: NSButton!
    @IBOutlet weak var _removeDylibLinkBtn: NSButton!
    @IBOutlet weak var _appNameTf: NSTextField!
    @IBOutlet weak var _shortVersionTf: NSTextField!
    @IBOutlet weak var _bundleIDTf: NSTextField!
    @IBOutlet weak var _ppfChooseBtn: NSButton!
    @IBOutlet weak var _cerCbx: NSComboBox!
    @IBOutlet weak var _ppfTf: NSTextField!
    var _dragView: DragDropView = DragDropView()
    var _dsOfDylibLinksTbv: [DylibLinkItem] = []
    var _dylibLinkTbvDelegate: DylibLinkTbvDelegate!
    
    private var _currentChoosedPPFPath: String!
    private var _rawIpaPayloadHandler: IpaPayloadHandle!
    private var _rawMachoLinks: [DylibLinkItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _scrv.documentView = _contentView
        _scrv.hasHorizontalScroller = false
        _scrv.hasVerticalScroller = false
        for subv in _contentView.subviews{
            (subv as? NSControl)?.isEnabled = false
        }
        _dragView = DragDropView()
        _contentView.addSubview(_dragView)
        _dragView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        _dragView.delegate = self
        
        _dylibLinkTbvDelegate = DylibLinkTbvDelegate.init(mainVC: self)
        _tbvOfDylibLinks.delegate = _dylibLinkTbvDelegate
        _tbvOfDylibLinks.dataSource = _dylibLinkTbvDelegate
        _tbvOfDylibLinks.tableColumns.forEach { (c) in
            _tbvOfDylibLinks.removeTableColumn(c)
        }
        _tbvOfDylibLinks.doubleAction = #selector(doubleClickOnDylibLinksTbv)
        let columnW = _tbvOfDylibLinks.frame.width
        
        _tbvOfDylibLinks.addTableColumn({
            let c = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("Link Path"))
            c.title = "Link Path"
            c.width = columnW * 0.7
            return c
            }())

        _tbvOfDylibLinks.reloadData()
        
         _ppfTf.isEditable = false
        
        _exportBtn.isEnabled = false
   
    }
    
    //MARK: - Delegate
    //MARK: DragDropViewDelegate
    func onHandleDrag(inIpa filePath: String!) {
        let fileURL = URL(fileURLWithPath: filePath)
        let ext = fileURL.pathExtension.lowercased()
        if ext.elementsEqual("ipa"){
            onChoosedToBeInjectedFile(filePath)
        }else if ext.elementsEqual("mobileprovision"){
            onChoosedPPFFile(filePath)
        }
        
    }
    
    //MARK: - Target Action
    @objc func doubleClickOnDylibLinksTbv(){
        let clickRow = self._tbvOfDylibLinks.clickedRow
        NSAlert.confirm("Are you sure to delete?", cancelCallback: nil) {
            self._dsOfDylibLinksTbv.remove(at: clickRow)
            self._tbvOfDylibLinks.reloadData()
        }
    }
    
    //MARK: 点击 选择Ipa
    @IBAction func onclickChooseIpaBtn(_ sender: Any) {
        let openPanel: NSOpenPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["ipa"]
        openPanel.beginSheetModal(for: self.view.window!) { (resp: NSApplication.ModalResponse) in
            if resp == NSApplication.ModalResponse.OK{
                self.onChoosedToBeInjectedFile(openPanel.url!.path.removingPercentEncoding!)
            }
        }
    }
    //MARK: 点击 '+' 动态库
    @IBAction func onclickAddDylibLinkBtn(_ sender: Any) {
        let vc = EmbResourceSelectVC.init(resourceType: .arbitrary)
        vc.onSelectedPathConfirmed = { (injectResourcePath: String, link: String) -> Void in
            self.dismiss(vc)
            
            let linkItem = DylibLinkItem(type: .userInject, link: link, injectResourcePath: injectResourcePath)
            self._dsOfDylibLinksTbv.removeAll(where: {$0.link == link})
            self._dsOfDylibLinksTbv.insert(linkItem, at: 0)
            self._tbvOfDylibLinks.reloadData()
            //do at next runloop
            //select last added row
            DispatchQueue.main.async {
                self._tbvOfDylibLinks.selectRowIndexes(IndexSet.init(integer:  0), byExtendingSelection: false)
            }
        }
        vc.onCanceled = {
            self.dismiss(vc)
        }
        self.presentAsSheet(vc)
    }
    //MARK: 点击 '-' 动态库
    @IBAction func onclickRemoveDylibLinkBtn(_ sender: Any) {
        if _tbvOfDylibLinks.selectedRow == -1{
            NSAlert.warning("Please select a dynamic library link to delete")
            return
        }
        NSAlert.confirm("Are you sure to delete it?", cancelCallback: nil) {
            self._dsOfDylibLinksTbv.remove(at: self._tbvOfDylibLinks.selectedRow)
            self._tbvOfDylibLinks.reloadData()
        }
    }
   
    //MARK: 点击 ppf '选择'
    @IBAction func onClickPPFChooseBtn(_ sender: Any) {
        let openPanel: NSOpenPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["mobileprovision"]
        openPanel.begin { (resp: NSApplication.ModalResponse) in
            if resp != NSApplication.ModalResponse.OK{
                return
            }
            
            guard let selectedUrl = openPanel.url else{
                return
            }
          
            self.onChoosedPPFFile(selectedUrl.path)
        }
    }
    
    @objc func willCloseWindow(){
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
        NSApplication.shared.stopModal()
    }
   
    //MARK: 点击 'Resign'
    @IBAction func onclickExportBtn(_ sender: Any) {
        let fm = FileManager.default
        for linkItem in _dsOfDylibLinksTbv{
            if linkItem.type == .userInject{
                if !fm.fileExists(atPath: linkItem.injectResourcePath!){
                    NSAlert.warning("Inject file not exists: \(linkItem.injectResourcePath!)")
                    return
                }
            }
        }
        
        //ipa metadata edit Tab check
        let shortVersionVal = _shortVersionTf.stringValue.trimming
        if shortVersionVal.isEmpty{
            NSAlert.warning("Pelease fill 'Version'")
            return
        }
        
        let displayNameVal = _appNameTf.stringValue.trimming
        if displayNameVal.isEmpty{
            NSAlert.warning("Pelease fill 'App Name'")
            return
        }
       
        let bundleIDVal = _bundleIDTf.stringValue.trimming
        if bundleIDVal.isEmpty{
            NSAlert.warning("Pelease fill 'Bundle ID'")
            return
        }
        
        //resign Tab check
        let ppfPath = (_currentChoosedPPFPath ?? "").trimming
        if ppfPath.isEmpty{
            NSAlert.warning("Pelease select a 'Provision File'")
            return
        }
        let signID = _cerCbx.stringValue.trimming
        if signID.isEmpty{
            NSAlert.warning("Pelease select a 'Sign Identity'")
            return
        }
        
        let hud = Hud.showHudInView(self.view)
        DispatchQueue.global().async {
            do{
                var allExportIpaPath: [URL] = []
                
                hud.message = "Preparing export Payload copy..."
                
                let copyDir = URL(fileURLWithPath: "/tmp").appendingPathComponent( "SResignerCopy\(Date().stringWithFormat("yyyyMMddHHmmss"))")
                let copyPayload = copyDir.appendingPathComponent("Payload")
                try! fm.copyItem(at: self._rawIpaPayloadHandler.payload, to: copyPayload, shouldOverwrite: true, withIntermediateDirectories: true)
                let copyPayloadHanlder: IpaPayloadHandle = try IpaPayloadHandle.init(payload: copyPayload)
                
                /* -------------- 清理注入库的 ------------ */
                //清理用户手动删除的 ‘原始注入库’
                let rawOriginInjectLinks = self._rawMachoLinks.filter{$0.type == .originInject}
                let remainOriginInjectLinks = self._dsOfDylibLinksTbv.filter{$0.type == .originInject}
                
                let remainOriginInjectLinkStrs = remainOriginInjectLinks.map{$0.link}
                let toDelOriginInjectLinks = rawOriginInjectLinks.filter{!remainOriginInjectLinkStrs.contains($0.link)}
                for linkItem in toDelOriginInjectLinks{
                    Logger.log("Delete dylib link: \(linkItem.link)")
                    try copyPayloadHanlder.deleteDylibLink(link: linkItem.link)
                }
                
                let toInjectLinkItems: [DylibLinkItem] = self._dsOfDylibLinksTbv.filter{$0.type == .userInject}
                
                //注入新增的
                for linkItem in toInjectLinkItems{
                    hud.message = "Inject \(linkItem.link)"
                    Logger.log("Inject \(linkItem.link)")
                    try copyPayloadHanlder.injectDylib(dylibFilePath: linkItem.injectResourcePath!, link: linkItem.link)
                }
                
                let newShortVersion = shortVersionVal
                Logger.log("Update shortVersion to: \(newShortVersion)")
                hud.message = "Update shortVersion"
                copyPayloadHanlder.mainBundle.updateShortVersion(newShortVersion)
                
                let newDisplayName = displayNameVal
                Logger.log("Update displayName to: \(newDisplayName)")
                hud.message = "Update displayName"
                copyPayloadHanlder.mainBundle.updateDisplayName(newDisplayName)
                
                
                hud.message = "Remove nested app..."
                let allNestedBundles = copyPayloadHanlder.currentNestedAppBundles()
                let remainNestedBundleIDs: [String] = []
                for bundle in allNestedBundles{
                    if !remainNestedBundleIDs.contains(bundle.bundleIdentifier!){
                        Logger.log("Remove nested app at path: \(bundle.bundlePath)")
                        try fm.removeItem(atPath: bundle.bundlePath)
                    }
                }
                let watchDir = copyPayloadHanlder.mainBundle.bundlePath + "/Watch";
                if FileManager.default.fileExists(atPath: watchDir){
                    Logger.log("remove Watch...")
                    hud.message = "remove Watch..."
                    try! FileManager.default.removeItem(atPath: watchDir)
                }
                Logger.log("Start resign...")
                hud.message = "Start resign..."
                
                let extraResignResources: (singleFiles: [String],frameworks: [String]) = {
                    var singleFiles: [String] = []
                    var frameworks: [String] = []
                    let bundlePath =  copyPayloadHanlder.mainBundle.bundlePath
                    let fm = FileManager.default
                    let allSubPaths = fm.subpaths(atPath: bundlePath) ?? []
                    
                    
                    let mainExecutablePath = copyPayloadHanlder.mainBundle.executablePath!
                    for path in allSubPaths{
                        let absPath = bundlePath + "/" + path
                        let absPathUrl = URL(fileURLWithPath: absPath)
                        var isDirectory = ObjCBool(false)
                        fm.fileExists(atPath: absPath, isDirectory: &isDirectory)
                        //frameworks 不过滤
                        if isDirectory.boolValue{
                            if absPathUrl.pathExtension == "framework" && self.checkFrameworkFileIsValidDylib(filePath: absPathUrl.path){
                                frameworks.append(path)
                            }
                            continue
                        }
                        /* -------------- 过滤掉一些不用单独签的 ------------- */
                        //过滤：主executable
                        if absPath == mainExecutablePath{
                            continue
                        }
                        //过滤：Framework 的 executable 文件
                        let lastName = absPathUrl.lastPathComponent
                        let last2Name = absPathUrl.deletingLastPathComponent().lastPathComponent
                        if (lastName + ".framework") == last2Name{
                            continue
                        }
                        
                        let fh: FileHandle = FileHandle.init(forReadingAtPath: absPath)!
                        
                        let bytes = fh.readData(ofLength: 4).bytes
                        if bytes.count < 4{
                            continue
                        }
                        let ret = (UInt32(bytes[0])<<24) + (UInt32(bytes[1])<<16) + (UInt32(bytes[2])<<8) + UInt32(bytes[3]);
                        if ret == FAT_MAGIC
                            || ret == FAT_CIGAM
                            || ret == MH_MAGIC_64
                            || ret == MH_CIGAM_64
                            || ret == MH_CIGAM
                            || ret == MH_MAGIC{
                            singleFiles.append(path)
                        }
                    }
                    return (singleFiles, frameworks)
                }()
                let sdate = Date()
                let newBundleID = bundleIDVal
                
                try copyPayloadHanlder.resign(mainAppNewPPFPath: ppfPath,
                                                   nestAppBundleIDToPPFPath: [:],
                                                   codeSignID: signID,
                                                   extraResignResources: extraResignResources.singleFiles,
                                                   extraResignFrameworks: extraResignResources.frameworks,
                                                   resignBundleIDSettingStrategy: .changeTo(newBundleID),
                                                   process: { (onSignFile: String)->Void in
                                                    hud.message = "Sign " + onSignFile
                })
                let enddate = Date()
                
                Logger.log("resign 用时: \(enddate.timeIntervalSince(sdate)) 秒")
                
                hud.message = "Zip to ipa..."
                let exportIpaName: String = "\(newDisplayName)_resigned\(Date().stringWithFormat("yyyyMMddHHmmss")).ipa"
                
                let exportedIpa = URL(fileURLWithPath: NSHomeDirectory()+"/Downloads").appendingPathComponent(exportIpaName)
                try fm.removeItemIfExists(at: exportedIpa)
                
                //压缩回 ipa
                Logger.log("Zip to ipa: \(exportedIpa)...")
                
                try ShellCmds.zip(filePath: copyPayloadHanlder.payload.path, toDestination: exportedIpa.path)
                hud.message = "Clean..."
                Logger.log("Clean...")
                
                //清理
                do{
                    //在清理文件时，如果文件被 chattr 命令加锁了后，会无法删除，继而会报权限问题 ，这里忽略，在 菜单->清理缓存 的时候会有提示
                    try fm.removeItem(at: copyDir)
                }catch{
                    if (error as NSError).code != 513{
                        throw error
                    }
                }
                
                Logger.log("Done")
                allExportIpaPath.append(exportedIpa)
                hud.hide()
                if allExportIpaPath.count > 1{
                    //open
                    try ShellCmds.open(directory: allExportIpaPath[0].deletingLastPathComponent().path, shouldSelect: true)
                }else{
                    //open
                    try ShellCmds.open(directory: allExportIpaPath[0].path, shouldSelect: true)
                }
                
            }catch{
                hud.hide()
                Logger.log("Resign failed: \(error)")
                NSAlert.warning("Resign failed error:\((error as NSError).localizedDescription)")
            }
        }
    }
    
    //MARK: - 其他
    //MAKR: 检查指定路径上的framework是否是有效的动态库
    func checkFrameworkFileIsValidDylib(filePath: String) -> Bool{
        let url = URL(fileURLWithPath: filePath)
        let fkName = url.deletingPathExtension().lastPathComponent
        let macho = url.appendingPathComponent(fkName)
        if !FileManager.default.fileExists(atPath: macho.path) {
            return false
        }
        let fh: FileHandle = FileHandle.init(forReadingAtPath: macho.path)!
        let bytes = fh.readData(ofLength: 4).bytes
        if bytes.count < 4{
            return false
        }
        let ret = (UInt32(bytes[0])<<24) + (UInt32(bytes[1])<<16) + (UInt32(bytes[2])<<8) + UInt32(bytes[3]);
        if ret == FAT_MAGIC
            || ret == FAT_CIGAM
            || ret == MH_MAGIC_64
            || ret == MH_CIGAM_64
            || ret == MH_CIGAM
            || ret == MH_MAGIC{
            return true
        }
        return false
    }
    //MARK: PPF选择完成处理
    func onChoosedPPFFile(_ ppfPath: String){
        guard let ppfModel = PPFModel.init(mobileprovisionFilePath: ppfPath) else{
            NSAlert.warning("描述文件解析失败")
            return
        }
        let cerNames = ppfModel.mdCertificates.map{ $0.commonName }
        if cerNames.count <= 0{
            NSAlert.warning("描述文件无效: 未包含任何关联证书")
            return
        }
        self._currentChoosedPPFPath = ppfPath
        self._ppfTf.stringValue = ppfModel.name
        
        self._cerCbx.isEnabled = true
        self._cerCbx.removeAllItems()
        self._cerCbx.addItems(withObjectValues: cerNames)
        self._cerCbx.selectItem(at: 0)
    }
    //MARK: IPA选择完成处理
    func onChoosedToBeInjectedFile(_ ipaPath: String){
        
        _dsOfDylibLinksTbv = []
        _rawMachoLinks = []
        
        let hud = Hud.showHudInView(self.view)
        DispatchQueue.global().async {
            Logger.log("handle ipa: \(ipaPath)")
            let upZipDir = URL(fileURLWithPath: "/tmp").appendingPathComponent( "SResignerUnzip\(Date().stringWithFormat("yyyyMMddHHmmss"))")
          
            try! ShellCmds.unzip(filePath: ipaPath, toDirectory: upZipDir.path)
            
            let searchPayloadPath = { () -> String? in
                let opt = FileSearcher.SearchOption()
                opt.maxResultNumbers = 1
                opt.searchItemType = [.directory]
                opt.maxSearchDepth = 1
                return FileSearcher.searchItems(nameMatchPattern: "Payload$", inDirectory: upZipDir.path, option: opt).first
            }()
            guard let payloadPath = searchPayloadPath else{
                NSAlert.warning("Can not find the 'Payload' directory in the ipa decompression directory")
                hud.hide()
                return
            }
            do{
                let ipaPayloadHandle = try IpaPayloadHandle.init(payload: URL(fileURLWithPath: payloadPath))
                self._rawIpaPayloadHandler = ipaPayloadHandle
            }catch{
                forceMainAsyn {
                    hud.hide()
                    Logger.log("Ipa analysis fail : \(error)")
                    NSAlert.warning("Ipa analysis fail: \(error)")
                }
            }
                
            
            
            hud.message = "macho analysis..."
            let dylibLinks = self._rawIpaPayloadHandler.getDylibLinks().map({ (link) -> DylibLinkItem in
                if link.starts(with: "@executable_path"){
                    return DylibLinkItem(type: .originInject, link: link)
                }else if link.starts(with: "@loader_path"){
                    return DylibLinkItem(type: .originInject, link: link)
                }else{
                    return DylibLinkItem(type: .originSystem, link: link)
                }
            })
            
            self._rawMachoLinks = dylibLinks
            self._dsOfDylibLinksTbv = dylibLinks

            DispatchQueue.main.async {
                for subv in self._contentView.subviews{
                    (subv as? NSControl)?.isEnabled = true
                }
             
                self._ipaSelectBtn.title = URL(fileURLWithPath: ipaPath).lastPathComponent
                
                self._appNameTf.stringValue = self._rawIpaPayloadHandler.mainBundle.displayName ?? self._rawIpaPayloadHandler.mainBundle.bundleName!
                
                self._shortVersionTf.stringValue = self._rawIpaPayloadHandler.mainBundle.shortVersion ?? self._rawIpaPayloadHandler.mainBundle.bundleVersion!
              
                self._bundleIDTf.stringValue = self._rawIpaPayloadHandler.mainBundle.bundleIdentifier!
                
                self._tbvOfDylibLinks.reloadData()
                
                self._removeDylibLinkBtn.isEnabled = self._dsOfDylibLinksTbv.count > 0
                self._tbvOfDylibLinks.isEnabled = self._dsOfDylibLinksTbv.count > 0
                self._tbvOfDylibLinks.deselectAll(nil)
                self._tbvOfDylibLinks.scrollRowToVisible(0)
                
                self._ppfTf.stringValue = ""
                
                self._cerCbx.isEnabled = false
                self._cerCbx.removeAllItems()
                self._cerCbx.stringValue = ""
                
                self._exportBtn.isEnabled = true
                
                hud.hide()
            }
        }
    }
     
}



 

