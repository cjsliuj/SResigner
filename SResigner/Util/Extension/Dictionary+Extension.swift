//
//  Dictionary.swift
//  XLWheel
//
//  Created by jerry on 2018/9/24.
//  Copyright © 2018年 xunlei. All rights reserved.
//

import Foundation
extension Dictionary{
    //MARK: - 编码/解码
    public static func dictionaryWith(plistData: Data) -> [Key:Value]? {
        return (try? PropertyListSerialization.propertyList(from: plistData,
                                                            options: PropertyListSerialization.ReadOptions.mutableContainersAndLeaves,
                                                            format: nil)) as? [Key:Value]
    }
    public static func dictionaryWith(plistString: String) -> [Key:Value]? {
        guard let data = plistString.data(using: .utf8) else{ return nil }
        return Dictionary.dictionaryWith(plistData: data)
    }
    public static func dictionaryWith(jsonData: Data) -> [Key:Value]?{
        return (try? JSONSerialization.jsonObject(with: jsonData, options: [.mutableLeaves, .mutableContainers])) as? [Key:Value]
    }
    public static func dictionaryWith(jsonString: String) -> [Key:Value]?{
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [.mutableLeaves, .mutableContainers])) as? [Key:Value]
    }
    public var plistData: Data?{
        return try? PropertyListSerialization.data(fromPropertyList: self,
                                                   format: PropertyListSerialization.PropertyListFormat.xml,
                                                   options: 0)
    }
    public var plistString: String?{
        guard let data = plistData else{ return nil }
        return String.init(data: data, encoding: .utf8)
    }
    public var jsonString: String?{
        guard let data = self.jsonData else { return nil }
        return String.init(data: data, encoding: .utf8)
    }
    public var jsonStringPrettyPrinted: String?{
        guard let data = self.jsonDataPrettyPrinted else { return nil }
        return String.init(data: data, encoding: .utf8)
    }
    public var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    public var jsonDataPrettyPrinted: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    //MARK: - Accessing Util
    public subscript(keys keys: [Key]) -> [Value?]{
        return keys.map{ self[$0] }
    }
}
