//
//  InjectLinkItem.swift
//  SResigner
//
//  Created by jerry on 2019/3/13.
//  Copyright © 2019 com.sz.jerry. All rights reserved.
//

import Foundation
enum DylibLinkItemType: String{
    case originSystem
    case originInject
    case userInject
}

class DylibLinkItem{
    var type: DylibLinkItemType = .originSystem
    var link: String = ""
    var injectResourcePath: String?
    init(type: DylibLinkItemType, link: String) {
        self.injectResourcePath = nil
        self.type = type
        self.link = link
    }
    
    init(type: DylibLinkItemType, link: String, injectResourcePath: String) {
        self.type = type
        self.link = link
        self.injectResourcePath = injectResourcePath
    }
}
