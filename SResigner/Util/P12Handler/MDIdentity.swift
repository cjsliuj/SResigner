//
//  MDIdentity.swift
//  LjTool
//
//  Created by 刘杰cjs on 17/4/14.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class MDIdentity{
    private let _identity: SecIdentity
    init(secIdentity: SecIdentity) {
        _identity = secIdentity
    }
}
