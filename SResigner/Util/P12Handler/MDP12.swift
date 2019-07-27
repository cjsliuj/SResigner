//
//  MDP12.swift
//  LjTool
//
//  Created by 刘杰cjs on 17/4/14.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class MDP12 {
    enum MDP12Error : Error{
        //P12文件导入秘钥验证失败
        case verifyPsdFailWhenImportPKCS12
        case otherWithOSStatus(OSStatus)
    }
    var label:String
    var chain:[MDCertificate]
    var identity: MDIdentity
    var trust: MDTrust
    var keyid: Data
    init(p12InfoDic: [String:Any]) {
        //label
        label = (p12InfoDic["label"] as? String)!
        //chain
        chain = []
        if let secCers = p12InfoDic["chain"] as? [SecCertificate]{
            for secCer in secCers{
                chain.append(MDCertificate.init(secCertificate: secCer))
            }
        }
        identity = MDIdentity.init(secIdentity: p12InfoDic["identity"] as! SecIdentity)
        trust = MDTrust.init(secTrust: p12InfoDic["trust"]! as! SecTrust)
        keyid = p12InfoDic[kSecImportItemKeyID as String] as! Data
    }
    public static func createP12ModelsWith(p12FilePath: String, password: String) -> [MDP12]? {
            let p12data = try! Data.init(contentsOf: URL.init(fileURLWithPath: p12FilePath))
            let importExportCnfDic : NSDictionary = [
                kSecImportExportPassphrase :password
            ]
            var arr : CFArray? ;
            let status = SecPKCS12Import(p12data as CFData, importExportCnfDic as CFDictionary, &arr)
            if status != 0{
                
            }
            var p12Models: [MDP12] = []
            
            let p12InfoDics: [[String:Any]] = arr! as!  [[String:Any]]
            for p12InfoDic in p12InfoDics {
              p12Models.append(MDP12.init(p12InfoDic: p12InfoDic))
            }
            return p12Models
    }
    
    public static func createP12ModelsWith(p12FilePath: String, password: String) throws -> [MDP12] {
        let p12data = try! Data.init(contentsOf: URL.init(fileURLWithPath: p12FilePath))
        let importExportCnfDic : NSDictionary = [
            kSecImportExportPassphrase :password
        ]
        var arr : CFArray? ;
        let status = SecPKCS12Import(p12data as CFData, importExportCnfDic as CFDictionary, &arr)
        if status != 0{
            if status == -25264{
                throw MDP12Error.verifyPsdFailWhenImportPKCS12
            }else{
                throw MDP12Error.otherWithOSStatus(status)
            }
        }
        var p12Models: [MDP12] = []
        
        let p12InfoDics: [[String:Any]] = arr! as!  [[String:Any]]
        for p12InfoDic in p12InfoDics {
            p12Models.append(MDP12.init(p12InfoDic: p12InfoDic))
        }
        return p12Models
    }
    
}









