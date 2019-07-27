//
//  FileSearcher
//  SResigner
//
//  Created by 刘杰 on 2017/11/29.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation

public class FileSearcher{
    public class SearchOption{
         public init(){}
        public var caseInsensitive: Bool = true
        public var maxResultNumbers: Int = Int.max
        //不参与搜索的文件夹的名称（正则）
        public var excludedSearchDirectoryNamePattern: String?
        //不参与搜索的文件夹的路径(相对于搜索跟目录，不可以以 / 开头)
        public var excludedSearchDirectoryPaths: [String] = []
        public var searchItemType: [ItemType] = [.directory,.file]
        public var maxSearchDepth: Int = Int.max
        public static var `default`: SearchOption{
            return SearchOption()
        }
    }
   
    public enum ItemType{
        case file
        case directory
    }

    public static func searchItems(nameMatchPattern: String,
                                   inDirectory: String,
                                   option: SearchOption = SearchOption.default) -> [String]{
        
        var isDir = ObjCBool(false)
        assert(FileManager.default.fileExists(atPath: inDirectory, isDirectory: &isDir), "要搜索的目录不存在")
        assert(isDir.boolValue, "搜索路径必须是个目录")
        assert(option.maxResultNumbers > 0, "maxResultNumbers 必须大于0")
        assert(option.searchItemType.count > 0, "至少指定一个item类型")
        assert(option.maxSearchDepth > 0, "maxResultNumbers 必须大于0")
        if let p = option.excludedSearchDirectoryNamePattern{
            assert((try? NSRegularExpression(pattern: p, options: [])) != nil, "excludedSearchDirectoryNamePattern 不是有效的正则表示式")
        }
        
        assert(option.excludedSearchDirectoryPaths.filter({$0.isMatch("^/.*", caseInsensitive: false)}).count <= 0, "excludedSearchDirectoryPaths 中的路径不可以以 / 开头")
        let searcher = FileSearcher.init(searchDir: inDirectory,
                                         nameMatchPattern: nameMatchPattern,
                                         searchOpt: option)
        searcher._searchItems(inDirectory: inDirectory, curDepth: 1)
        return searcher.result
    }
    
    
    private var result: [String] = []
    private let fm = FileManager.default
    private let searchDir: String
    private let searchOpt: SearchOption
    private let nameMatchPattern: String
    private init(searchDir: String, nameMatchPattern: String, searchOpt: SearchOption) {
        self.searchDir = searchDir
        self.searchOpt = searchOpt
        self.nameMatchPattern = nameMatchPattern
    }
    private func _searchItems(inDirectory: String, curDepth: Int){
        var shouldSkipCurDir = false
        //非初始路径 则进行过滤判断
        if !inDirectory.elementsEqual(searchDir){
            let dirName = URL.init(fileURLWithPath: inDirectory).lastPathComponent
            if let p = searchOpt.excludedSearchDirectoryNamePattern,
                dirName.isMatch(p, caseInsensitive: searchOpt.caseInsensitive){
                shouldSkipCurDir = true
            }else{
                for excludeDirPath in searchOpt.excludedSearchDirectoryPaths{
                    let absPath = URL.init(fileURLWithPath: searchDir).appendingPathComponent(excludeDirPath).path
                    
                    if inDirectory.elementsEqual(absPath){
                        shouldSkipCurDir = true
                    }
                }
            }
        }
        if shouldSkipCurDir{
            return
        }
        let subNames = try! fm.contentsOfDirectory(atPath: inDirectory)
        for subName in subNames {
            let path = (inDirectory as NSString).appendingPathComponent(subName)
            var isDirectory = ObjCBool(false)
            fm.fileExists(atPath: path, isDirectory: &isDirectory)
            let canItemAddToResult = { () -> Bool in
                //文件类型
                if !searchOpt.searchItemType.contains(.directory) && isDirectory.boolValue{
                    return false
                }
                if !searchOpt.searchItemType.contains(.file) && !isDirectory.boolValue{
                    return false
                }
                //名称匹配
                if !subName.isMatch(nameMatchPattern, caseInsensitive: searchOpt.caseInsensitive){
                    return false
                }
                
                //最大结果数
                if result.count >= searchOpt.maxResultNumbers{
                    return false
                }
                return true
            }()
            if canItemAddToResult{
                result.append(path)
            }
            if result.count >= searchOpt.maxResultNumbers{
                break
            }
            if isDirectory.boolValue{
                if (curDepth + 1) <= searchOpt.maxSearchDepth{
                    self._searchItems(inDirectory: path, curDepth: curDepth + 1)
                }
            }
        }
    }
    
}





