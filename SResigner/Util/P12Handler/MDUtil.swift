//
//  MDUtil.swift
//  LjTool
//
//  Created by 刘杰cjs on 17/4/15.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class MDUtil {
    public static func getMatchedCertificatesCount(isTrustedOnly: Bool, subject: String, serialNumber: String) -> Int{
        let queryDic: CFDictionary = [
            kSecClass as String : kSecClassCertificate as String,
            kSecMatchSubjectWholeString as String : subject,
            kSecMatchTrustedOnly as String: isTrustedOnly,
            kSecMatchLimit as String: kSecMatchLimitAll as String,
            kSecReturnRef as String : true
            ] as CFDictionary
        
        var ref: CFTypeRef?
        
        SecItemCopyMatching(queryDic,&ref)
        
        if ref == nil{
            return 0
        }else{
            let cers: [SecCertificate] = ref! as! [SecCertificate]
            return cers.filter({ (cer) -> Bool in
                let cfValDic = SecCertificateCopyValues(cer, [kSecOIDX509V1SerialNumber] as CFArray, nil)!
                let valDic: [String : [String: Any]] = cfValDic as! [String : [String: Any]]
                let kValKey = kSecPropertyKeyValue as String
                let serialNum = valDic[kSecOIDX509V1SerialNumber as String]![kValKey]! as! String
                return serialNum == serialNumber
            }).count
            
        }
    }
}
