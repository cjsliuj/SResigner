//
//  MDCertificate.swift
//  LjTool
//
//  Created by 刘杰cjs on 17/4/14.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class MDCertificate{
    let commonName: String
    let subjectSummary: String
    let emailAddress: [String]
    let expireDate: Date
    let serialNumber: String
    
    let secCertificate: SecCertificate
    
    
    init(secCertificate: SecCertificate) {
        self.secCertificate = secCertificate
        
        var secKey: SecKey? = nil
        SecCertificateCopyPublicKey(secCertificate, &secKey)
        
        //commonName
        var comName: CFString? = nil
        SecCertificateCopyCommonName(secCertificate, &comName)
        commonName = (comName as String?) ?? ""
    
        //subjectSummary
        subjectSummary = (SecCertificateCopySubjectSummary(secCertificate) as String?) ?? ""
        
        //emailAddress
        var cfEmailAddress: CFArray? = nil
        SecCertificateCopyEmailAddresses(secCertificate, &cfEmailAddress)
        emailAddress = (cfEmailAddress as? [String]) ?? [""]
        
        let cfValDic = SecCertificateCopyValues(secCertificate, [
            kSecOIDInvalidityDate,
            kSecOIDX509V1SerialNumber
            ] as CFArray, nil)!
        let valDic: [String : [String: Any]] = cfValDic as! [String : [String: Any]]
        let kValKey = kSecPropertyKeyValue as String
        //expireDate
        expireDate = valDic[kSecOIDInvalidityDate as String]?[kValKey] as? Date ?? Date.distantPast
        //serialNumber
        serialNumber = valDic[kSecOIDX509V1SerialNumber as String]![kValKey]! as! String
        
    }
    convenience init(secIdentity: SecIdentity){
        var cer: SecCertificate? = nil
        SecIdentityCopyCertificate(secIdentity, &cer)
        self.init(secCertificate:cer!)
    }
    //MARK: - Public Func
    //本地安装 && trust
    public func isValidateInLocal() -> Bool{
        return MDUtil.getMatchedCertificatesCount(isTrustedOnly: true, subject: self.subjectSummary, serialNumber: self.serialNumber) >= 1
    }
    //本地是否安装了该证书
    public func isInstalledInLocal() -> Bool{
        return MDUtil.getMatchedCertificatesCount(isTrustedOnly: false, subject: self.subjectSummary, serialNumber: self.serialNumber) >= 1
    }
}
