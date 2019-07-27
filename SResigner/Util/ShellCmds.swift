//
//  ShellCmds.swift
//  SResigner
//
//  Created by jerry on 2018/11/16.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
struct ProcessRunResult{
    let isSuccess: Bool
    let stdError: String
    let stdOutput: String
}
class ProcessHelper{
    static func synRun(_ launchPath: String, _ arguments: [String], _ currentDirectoryURL: URL? = nil) -> ProcessRunResult{
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        if let url = currentDirectoryURL{
            process.currentDirectoryPath = url.path
        }
        let errPipe = Pipe()
        let outputPipe = Pipe()
        process.standardError = errPipe
        process.standardOutput = outputPipe
        
        process.launch()
        process.waitUntilExit()
        return ProcessRunResult.init(isSuccess: process.terminationStatus == 0,
                              stdError: String.init(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "",
                              stdOutput: String.init(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")
    }
}

class ShellCmds{
    static func zip(filePath: String, toDestination: String) throws{
        let fpath = URL.init(fileURLWithPath: filePath)
        let parent = fpath.deletingLastPathComponent()
        let fname = fpath.lastPathComponent
       
        try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: toDestination).deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        let ret = ProcessHelper.synRun("/usr/bin/zip", ["-qry", toDestination, fname], parent)
        if !ret.isSuccess{
            let msg = ret.stdError.isEmpty ? ret.stdOutput : ret.stdError
            throw NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : msg])
        }
    }
    static func unzip(filePath: String, toDirectory: String) throws{
        try FileManager.default.createDirectory(atPath: toDirectory, withIntermediateDirectories: true, attributes: nil)
        let ret = ProcessHelper.synRun("/usr/bin/unzip", ["-qo", filePath, "-d", toDirectory])
        if !ret.isSuccess{
            let msg = ret.stdError.isEmpty ? ret.stdOutput : ret.stdError
            throw NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : msg])
        }
    }

    static func cmdCodeSign(filePath: String, signID: String, entitlementFilePath: String?) throws{
        var ret: ProcessRunResult!
        if let entitlementFilePath = entitlementFilePath{

            ret = ProcessHelper.synRun("/usr/bin/codesign", ["-f","-s",signID, "--entitlements", entitlementFilePath, filePath])
        }else{
            ret = ProcessHelper.synRun("/usr/bin/codesign", ["-f","-s",signID, filePath])
        }
        if !ret.isSuccess{
            let msg = ret.stdError.isEmpty ? ret.stdOutput : ret.stdError
            throw NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : msg])
        }
    }

    static func open(directory: String, shouldSelect: Bool = false) throws{
        var ret: ProcessRunResult!
        if shouldSelect {
            ret = ProcessHelper.synRun("/usr/bin/open", ["-R", URL.init(fileURLWithPath: directory).path])
        }else{
            ret = ProcessHelper.synRun("/usr/bin/open", [URL.init(fileURLWithPath: directory).path])
        }
        if !ret.isSuccess{
            let msg = ret.stdError.isEmpty ? ret.stdOutput : ret.stdError
            throw NSError.init(domain: "0", code: 0, userInfo: [NSLocalizedDescriptionKey : msg])
        }
    }
    
}
