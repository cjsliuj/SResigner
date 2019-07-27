//
//  String+Regex.swift
//  XLWheel
//
//  Created by jerry on 2018/9/24.
//  Copyright © 2018年 xunlei. All rights reserved.
//

import Foundation
extension String{
    private var _wholeRange: NSRange{ return NSRange(location: 0, length: self.count) }
    
    public class Matcher{
        public class Group{
            public let range: Range<String.Index>
            public let value: String
            init(range: Range<String.Index>, value: String) {
                self.range = range
                self.value = value
            }
        }
        private let _checkingResult: NSTextCheckingResult
        public var groups: [Group] = []
        init(checkingResult: NSTextCheckingResult, originString: String) {
            _checkingResult = checkingResult
            for i in 0..<_checkingResult.numberOfRanges{
                let groupRange = checkingResult.range(at: i)
                let swiftRange = Range(groupRange, in: originString)!
                let groupValue = String(originString[swiftRange])
                let group = Group.init(range: swiftRange, value: groupValue)
                groups.append(group)
            }
        }
    }
    public func isMatch(pattern: String) -> Bool{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        return exp.numberOfMatches(in: self, options: [], range: self._wholeRange) > 0
    }
    public func firstMatch(pattern: String) -> String?{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        if let range = exp.firstMatch(in: self, options: [], range: self._wholeRange)?.range{
            return String(self[Range.init(range, in: self)!])
        }else{
            return nil
        }
    }
    public func advancedFirstMatch(pattern: String) -> Matcher?{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        if let checkingRet = exp.firstMatch(in: self, options: [], range: self._wholeRange){
            return Matcher.init(checkingResult: checkingRet, originString: self)
        }else{
            return nil
        }
    }
    public func matches(pattern: String) -> [String]{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = exp.matches(in: self, options: [], range: self._wholeRange)
        return matches.map{ String(self[Range.init($0.range, in: self)!]) }
    }
    public func advancedMatches(pattern: String) -> [Matcher]{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = exp.matches(in: self, options: [], range: self._wholeRange)
        return matches.map{ return Matcher(checkingResult: $0, originString: self) }
    }

    public func indexOf(pattern: String) -> Int?{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        let hitLocation = exp.rangeOfFirstMatch(in: self, options: [], range: self._wholeRange).location
        return  hitLocation == NSNotFound ? nil : hitLocation
    }
    //test case : assert("1111abcd1111ABCD1111efgh1111".split(pattern: "\\d\\d") == ["abcd", "ABCD", "efgh"])
    public func split(separatorPattern: String) -> [String]{
        let exp = try! NSRegularExpression(pattern: separatorPattern, options: [])
        let matches = exp.matches(in: self, options: [], range: self._wholeRange)
        var ret: [String] = []
        var lastCheckRange: NSRange = NSRange(location: 0, length: 0)
        let matchesCount = matches.count
        for (index, checkRet) in matches.enumerated(){
            let currentCheckRange = checkRet.range
            let pieceStartIndex = lastCheckRange.location + lastCheckRange.length
            let pieceEndIndex = currentCheckRange.location - 1
            if pieceStartIndex < pieceEndIndex{
                ret.append(String(self[String.Index(encodedOffset: pieceStartIndex)...String.Index(encodedOffset: pieceEndIndex)]))
            }
            if index == matchesCount - 1{
                let endPieceStartIndex = currentCheckRange.location + currentCheckRange.length
                let endPieceEndIndex = self.count - 1
                if endPieceStartIndex < endPieceEndIndex{
                    ret.append(String(self[String.Index(encodedOffset: endPieceStartIndex)...String.Index(encodedOffset: endPieceEndIndex)]))
                }
            }
            lastCheckRange = currentCheckRange
        }
        return ret
    }
    public func replace(pattern: String, with replacement: String) -> String{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        return exp.stringByReplacingMatches(in: self, options: [], range: self._wholeRange, withTemplate: replacement)
    }
    public func replace(pattern: String, withReplacementHanlder replacementHanlder: (_ match: String) -> String) -> String{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = exp.matches(in: self, options: [], range: self._wholeRange)
        var copy = self
        //倒序替换，索引不会错乱
        for checkRet in matches.reversed(){
            let matchRange = Range.init(checkRet.range, in: self)!
            let matchStr = String(self[matchRange])
            copy.replaceSubrange(matchRange, with: replacementHanlder(matchStr))
        }
        return copy
    }
    public func replaceFirstMatch(pattern: String, with replacement: String) -> String{
        let exp = try! NSRegularExpression(pattern: pattern, options: [])
        if let range = exp.firstMatch(in: self, options: [], range: self._wholeRange)?.range{
            var copy = self
            copy.replaceSubrange(Range(range, in: copy)!, with: replacement)
            return copy
        }else{
            return self
        }
    }
}
