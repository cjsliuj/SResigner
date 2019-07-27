//
//  Logger.swift
//  SResigner
//
//  Created by 刘杰 on 2018/11/19.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
class Logger{
    static func log(_ msg: String){
        #if DEBUG
        print(msg)
        #endif
    }
}
