//
//  EmbResourceSelectVC.swift
//  SResigner
//
//  Created by 刘杰 on 2017/12/6.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Cocoa
import Cocoa
class EmbResourceSelectVC: NSViewController {
    enum ResourceType{
        case dylib
        case arbitrary
    }
    @IBOutlet weak var _resourcePathTf: NSTextField!
    @IBOutlet weak var _linkTf: NSTextField!
    @IBOutlet weak var _resourceSelectFlaglb: NSTextField!
    var onCanceled: (()->Void)?
    var onSelectedPathConfirmed: ((_ injectResourcePath: String, _ link: String)->Void)?
    let resourceType: ResourceType
    init(resourceType: ResourceType) {
        self.resourceType = resourceType
        super.init(nibName: NSNib.Name.init("EmbResourceSelectVC"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择注入库"
        _linkTf.refusesFirstResponder = true
        _linkTf.resignFirstResponder()
    }
    
    @IBAction func onclickResourceSelectBtn(_ sender: Any) {
        let openPanel: NSOpenPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
//        openPanel.allowedFileTypes = ["dylib","framework"]
        openPanel.beginSheetModal(for: self.view.window!) { (resp: NSApplication.ModalResponse) in
            if resp == NSApplication.ModalResponse.OK{
                let filePath = openPanel.url!
                self._resourcePathTf.stringValue = filePath.path
                if let bundle = Bundle.init(path: filePath.path),
                    let execuableName = bundle.executableURL?.lastPathComponent{
                    if filePath.path.hasSuffix("framework"){
                        self._linkTf.stringValue = "Frameworks/\(filePath.lastPathComponent.removingPercentEncoding!)/\(execuableName.removingPercentEncoding!)"
                    }else{
                        self._linkTf.stringValue = "\(filePath.lastPathComponent.removingPercentEncoding!)/\(execuableName.removingPercentEncoding!)"
                    }
                    
                }else{
                    self._linkTf.stringValue = "\(filePath.lastPathComponent.removingPercentEncoding!)"
                }
            }
        }
 
    }
   
    @IBAction func onclickOkBtn(_ sender: Any) {
        let link: String = _linkTf.stringValue.trimming
        if link.isEmpty{
            NSAlert.warning("请填Link")
            return
        }
        if link.starts(with: "/"){
            NSAlert.warning("Link不可以以/开头")
            return
        }
        let resourcePath = _resourcePathTf.stringValue.trimming
        if resourcePath.isEmpty{
            NSAlert.warning("请选择资源路径")
            return
        }
        onSelectedPathConfirmed?(resourcePath, "@executable_path/" + link)
    }
    @IBAction func onclickCancelBtn(_ sender: Any) {
        onCanceled?()
    }
}
