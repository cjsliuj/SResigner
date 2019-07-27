//
//  String2.swift
//  XLWheel
//
//  Created by jerry on 2018/9/24.
//  Copyright © 2018年 xunlei. All rights reserved.
//

import Foundation
import AppKit
extension String{
    //MARK: - Hash
    private var _utf8Data: Data? { return self.data(using: .utf8)}
    public var md5String: String?{ return self._utf8Data?.md5String }
    public var sha1String: String?{ return self._utf8Data?.sha1String }
    public var sha224String: String?{ return self._utf8Data?.sha224String }
    public var sha256String: String?{ return self._utf8Data?.sha256String }
    public var sha384String: String?{ return self._utf8Data?.sha384String }
    public var sha512String: String?{ return self._utf8Data?.sha512String }
    public func hmacMD5String(withKey key: String) -> String?{
        return self._utf8Data?.hmacMD5String(withKey: key)
    }
    public func hmacSHA1String(withKey key: String) -> String?{
        return self._utf8Data?.hmacSHA1String(withKey: key)
    }
    public func hmacSHA224String(withKey key: String) -> String?{
        return self._utf8Data?.hmacSHA224String(withKey: key)
    }
    public func hmacSHA256String(withKey key: String) -> String?{
        return self._utf8Data?.hmacSHA256String(withKey: key)
    }
    public func hmacSHA384String(withKey key: String) -> String?{
        return self._utf8Data?.hmacSHA384String(withKey: key)
    }
    public func hmacSHA512String(withKey key: String) -> String?{
        return self._utf8Data?.hmacSHA512String(withKey: key)
    }
    
    //MARK: Encode / Decode
    public var base64EncodedString: String?{
        guard let data = self._utf8Data?.base64EncodedData() else { return nil }
        return String.init(data: data, encoding: .utf8)
    }
    public var base64DecodedString: String?{
        guard let data = Data.init(base64Encoded: self) else { return nil }
        return String.init(data: data, encoding: .utf8)!
    }
    
    /// 对指定字符串进行url encode 编码
    ///
    /// - Parameter extraEncodeCharacters: 额外需要编码的字符，目前参与编码的字符有: #[]@!$&'()*+,;=
    /// - Returns: 编码后的字符串
    public func urlEncodedStringWith(extraEncodeCharacters: String) -> String{
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        allowedCharacterSet.remove(charactersIn: extraEncodeCharacters)
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        if #available(iOS 8.3, *) {
            escaped = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
        } else {
            let batchSize = 50
            var index = self.startIndex
            
            while index != self.endIndex {
                let startIndex = index
                let endIndex = self.index(index, offsetBy: batchSize, limitedBy: self.endIndex) ?? self.endIndex
                let range = startIndex..<endIndex
                
                let substring = self[range]
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? String(substring)
                
                index = endIndex
            }
        }
        return escaped
    }
    /// 对指定字符串进行url encode 编码
    ///
    /// - Returns: 编码后的字符串
    public var urlEncodedString: String{
        return urlEncodedStringWith(extraEncodeCharacters: "")
    }
   
    public var urlDecodedString: String {
        return self.removingPercentEncoding ?? self
    }
    
    public var xmlEscapingString: String{
        return self.map { (c) -> String in
            if c == Character.init("&"){
                return "&amp;"
            }else if c == Character.init("<"){
                return "&lt;"
            }else if c == Character.init(">"){
                return "&gt"
            }else if c == Character.init("'"){
                return "&apos;"
            }else if c == Character.init("\""){
                return "&quot;"
            }
            return String.init(c)
            }.joined()
    }
    public var htmlEscapingString: String{
        return self.xmlEscapingString
    }
    

    //MARK: - Utilities
    public var trimmedString: String{
        return (self as NSString).trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
    }
    
    public var localization: String { return NSLocalizedString(self, comment: self) }
    
    //MARK: - 时间长度处理
    /// 将时间长度转换为 HH:mm:ss 格式字符串
    ///
    /// - Parameter:
    ///   - timeDuration: 时间长度，单位：秒
    ///   - isHiddenZeroPart: 是否隐藏全部是0的部分
    /// - Returns: 格式化后的字符串
    public static func format(timeDuration: Int64, isHiddenZeroPart: Bool = false) -> String{
        let h: Int64 = timeDuration / 3600
        let m: Int64 = timeDuration % 3600 / 60
        let s: Int64 = timeDuration % 60
        if isHiddenZeroPart{
            return String.init(format: "%02d:%02d:%02d", h, m, s).replacingOccurrences(of: "00:", with: "").replacingOccurrences(of: "00", with: "")
        }else{
            return String.init(format: "%02d:%02d:%02d", h, m, s)
        }
    }
    public var toWebSiteURL: URL?{
        //系统的url.Scheme 有问题，比如：
        // a.b:11 此时返回的scheme 是a.b（发现只要加了端口，如果没写scheme 就会返回出问题）
        func getSchemeFromURLString(_ urlstring: String) -> String?{
            let groups = urlstring.advancedFirstMatch(pattern: "^(.*)?://.*")?.groups ?? []
            if groups.count > 1{
                return groups.last?.value
            }else{
                return nil
            }
        }
        
        var formattedUrlString = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        //替换中文
        while let matcher = formattedUrlString.advancedFirstMatch(pattern: "[\\u4e00-\\u9fa5]"){
            let matchedStr = matcher.groups[0].value
            formattedUrlString = formattedUrlString.replacingOccurrences(of: matchedStr, with: matchedStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)
        }
        //过滤有非法字符的链接
        guard var url = URL.init(string: formattedUrlString) else{
            return nil
        }
        
        var isAutoMakeUpScheme = false
        //无scheme 则补上scheme
        if getSchemeFromURLString(formattedUrlString) == nil{
            isAutoMakeUpScheme = true
            if !formattedUrlString.isMatch(pattern: "^[a-z0-9].*"){
                return nil
            }
            url = URL.init(string: "http://" + formattedUrlString)!
        }
        
        //校验 scheme
        if !["http","https","ftp"].contains(url.scheme!.lowercased()){
            return nil
        }
        
        /*
         校验host
         前面补上host 是为了能够解析出host ，但是仍需判断host 是否存在，比如下面这种场景：
         http://
         */
        guard let host = url.host else{
            return nil
        }
        
        //http://xxx 这种host 无效
        if host.range(of: ".") == nil{
            return nil
        }
        //ip类host校验
        if host.isMatch(pattern: "^\\d+\\.\\d+\\.\\d+\\.\\d+$"){
            return url
        }
        //如果是 后面加的 scheme 则进行一级域名校验 和 最末级域名检查
        if isAutoMakeUpScheme{
            //以 www开头 通过
            if host.isMatch(pattern: "^www\\..*"){
                return url
            }
            //一级域名校验
            if !host.isMatch(pattern: ".*\\.(aero|biz|cc|club|cn|co|com|coop|edu|gov|hk|html|idv|info|int|im|is|jp|kim|la|me|mil|mobi|museum|name|net|org|pw|pro|rocks|ren|site|so|space|top|tw|tv|us|vip|wang|xyz)$"){
                return nil
            }
        }
        return url
    }
    /// 将 HH:mm:ss 格式的时间字符串转换为 秒
    ///
    /// - Parameter timeFormat: HH:mm:ss 格式的时间字符串
    /// - Returns: 时长(单位: 秒)
    public static func duration(from timeFormat: String) -> TimeInterval{
        let timeComponents = timeFormat.split(separator: ":").map{ return String($0)}
        let h = Int(timeComponents[0])!
        let m = Int(timeComponents[1])!
        let s = Int(timeComponents[2])!
        return TimeInterval(h * 3600 + m * 60 + s)
    }
}
