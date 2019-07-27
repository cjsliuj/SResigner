//
//  String+Extension.swift
//  SResigner
//
//  Created by 刘杰 on 2018/11/14.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
extension String{
    func isMatch(_ pattern: String, caseInsensitive: Bool = true) -> Bool{
        var opt: NSRegularExpression.Options = []
        if caseInsensitive{
            opt.insert(NSRegularExpression.Options.caseInsensitive)
        }
        let regex = try! NSRegularExpression(pattern: pattern, options: opt)
        let matchNum = regex.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count))
        return matchNum > 0
    }
    var trimming: String{
        return self.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
    }
    var asFileURL: URL{
        return URL.init(fileURLWithPath: self)
    }
    static func randomStringOfLength(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[String.Index.init(encodedOffset: index)])
        }
        return ranStr
    }
    var stringWithOutExtension: String{
        if let idx = self.lastIndex(of: "."){
            return String(self.prefix(upTo: idx))
        }else{
            return self
        }
    }
}
