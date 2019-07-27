//
//  FileManager+Extension.swift
//  SResigner
//
//  Created by jerry on 2018/11/22.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
extension FileManager{
    func removeItemIfExists(at url: URL) throws{
        if self.fileExists(atPath: url.path){
            try self.removeItem(at: url)
        }
    }
    func removeItemIfExists(at path: String) throws{
        if self.fileExists(atPath: path){
            try self.removeItem(atPath: path)
        }
    }
    func copyItem(at srcURL: URL,
                  to dstURL: URL,
                  shouldOverwrite: Bool,
                  withIntermediateDirectories intermediateDirectories: Bool) throws{
        try self.copyItem(atPath: srcURL.path, toPath: dstURL.path, shouldOverwrite: shouldOverwrite, withIntermediateDirectories: intermediateDirectories)
    }
    func copyItem(atPath srcPath: String,
                  toPath dstPath: String,
                  shouldOverwrite: Bool,
                  withIntermediateDirectories intermediateDirectories: Bool) throws{
        if self.fileExists(atPath: dstPath) && shouldOverwrite{
            try self.removeItem(atPath: dstPath)
        }
        if intermediateDirectories{
            try self.createDirectory(at: URL(fileURLWithPath: dstPath).deletingLastPathComponent(), withIntermediateDirectories: intermediateDirectories, attributes: nil)
        }
        try self.copyItem(atPath: srcPath, toPath: dstPath)
    }
    
}
