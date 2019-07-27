//
//  MainVC+DylibEditTab.swift
//  SResigner
//
//  Created by jerry on 2018/11/18.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
import Cocoa
extension MainVC{
    class DylibLinkTbvDelegate:NSObject, NSTableViewDelegate, NSTableViewDataSource{
        let mainVC: MainVC
        init(mainVC: MainVC) {
            self.mainVC = mainVC
        }
        //MARK: NSTableViewDataSource
        public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool{
            return false
        }
        public func numberOfRows(in tableView: NSTableView) -> Int{
            return mainVC._dsOfDylibLinksTbv.count
        }
        public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?{
            return nil
        }
        func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
            let cell: NSTextFieldCell = cell as! NSTextFieldCell
            cell.title = mainVC._dsOfDylibLinksTbv[row].link
        }
        func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
            return 30
        }
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let linkItem = mainVC._dsOfDylibLinksTbv[row]
            let columnId = tableColumn!.identifier.rawValue
            let ctnView = NSView()
            ctnView.wantsLayer = true
            let lb = NSTextField()
            lb.backgroundColor = NSColor.clear
            lb.isEditable = false
            lb.isBordered = false
            if columnId.elementsEqual("Link Path"){
                lb.stringValue = linkItem.link
                if linkItem.type == .userInject{
                    ctnView.layer?.backgroundColor = NSColor.init(hexString: "0xdeab8a")!.cgColor
                }
            }
            ctnView.addSubview(lb)
            lb.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalToSuperview()
                maker.centerY.equalToSuperview()
            }
            return ctnView
        }
        
        public func tableViewSelectionDidChange(_ notification: Notification){
            mainVC._removeDylibLinkBtn.isEnabled = mainVC._tbvOfDylibLinks.selectedRow != -1
        }
    }
    
    
}
