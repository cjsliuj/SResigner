//
//  Date+Extension.swift
//  SResigner
//
//  Created by 刘杰 on 2018/11/19.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
extension Date{
    public func stringWithFormat(_ format: String) -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
}
