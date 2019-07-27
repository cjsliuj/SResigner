//
//  MDTrust.swift
//  LjTool
//
//  Created by 刘杰cjs on 17/4/14.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class MDTrust{
    
    let secTrust: SecTrust
    init(secTrust: SecTrust){
        self.secTrust = secTrust
    }
    convenience init(secCertificate: SecCertificate) {
        var secTrust: SecTrust? = nil
        SecTrustCreateWithCertificates(secCertificate, nil, &secTrust)
        self.init(secTrust: secTrust!)
    }
    convenience init(mdCertificate: MDCertificate) {
        var secTrust: SecTrust? = nil
        SecTrustCreateWithCertificates(mdCertificate.secCertificate, nil, &secTrust)
        self.init(secTrust: secTrust!)
    }
    func evaluate() -> SecTrustResultType{
        var rs: SecTrustResultType = .proceed
        SecTrustEvaluate(self.secTrust, &rs)
        return rs
    }
}
extension SecTrustResultType{
    func representString() -> String{
        switch self {
        case .invalid:return "invalid"
        case .proceed:return "proceed"
        case .deny:return "deny"
        case .unspecified:return "unspecified"
        case .recoverableTrustFailure:return "recoverableTrustFailure"
        case .fatalTrustFailure:return "fatalTrustFailure"
        case .otherError:return "otherError"
        default: return "未知"
        }
    }
}
