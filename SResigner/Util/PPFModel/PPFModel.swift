//
//  PPFReader.swift
//  LjTool
//
//  Created by 刘杰 on 17/4/13.
//  Copyright © 2017年 com.sz.jerry. All rights reserved.
//

import Foundation
class  PPFModel {
    class Entitlements{
        let keychainAccessGroups: [String]
        let getTaskAllow: Bool
        let applicationIdentifier: String
        let comAppleDeveloperAssociatedDomains: String?
        let comAppleDeveloperTeamIdentifier: String
        let apsEnvironment: String?
        init(entitlementsDicInfo:[String:Any]) {
            keychainAccessGroups = entitlementsDicInfo["keychain-access-groups"] as! [String]
            getTaskAllow = entitlementsDicInfo["get-task-allow"] as! Bool
            applicationIdentifier = entitlementsDicInfo["application-identifier"] as! String
            comAppleDeveloperAssociatedDomains = entitlementsDicInfo["com.apple.developer.associated-domains"] as? String
            comAppleDeveloperTeamIdentifier = entitlementsDicInfo["com.apple.developer.team-identifier"] as! String
            apsEnvironment = entitlementsDicInfo["aps-environment"] as? String
        }
    }
    let rawDictionary: [String: Any]
    let name: String
    let UUID: String
    let appIDName: String
    let applicationIdentifierPrefix: [String]
    let platform: [String]
    let devices: [String]?
    let teamIdentifier: [String]
    let teamName: String
    let mdCertificates: [MDCertificate]
    let entitlements: Entitlements
    let entitlementsDictionay: [String: Any]
    
    init(ppfDictionary: [String: Any]){
        name = ppfDictionary["Name"] as! String
        appIDName = ppfDictionary["AppIDName"] as? String ?? ""
        applicationIdentifierPrefix = ppfDictionary["ApplicationIdentifierPrefix"] as! [String]
        platform = ppfDictionary["Platform"] as! [String]
        devices = ppfDictionary["ProvisionedDevices"] as? [String]
        teamIdentifier = ppfDictionary["TeamIdentifier"] as! [String]
        teamName = ppfDictionary["TeamName"] as! String
        UUID = ppfDictionary["UUID"] as! String
        entitlementsDictionay = ppfDictionary["Entitlements"]! as! [String : Any]
        entitlements = PPFModel.Entitlements.init(entitlementsDicInfo: entitlementsDictionay)
        let cerDatas: [Data] = ppfDictionary["DeveloperCertificates"]  as! [Data]
        var mdCers:[MDCertificate] = []
        for cerData in cerDatas{
            let cer = SecCertificateCreateWithData(nil,cerData as CFData)
            let mdcer = MDCertificate.init(secCertificate: cer!)
            mdCers.append(mdcer)
        }
        mdCertificates = mdCers
        rawDictionary = ppfDictionary
    }
    convenience init(xmlString: String) {
        let valDic =  try! PropertyListSerialization.propertyList(from: xmlString.data(using: .utf8)!, options: .mutableContainers , format: nil) as! [String: Any]
        self.init(ppfDictionary:valDic)
    }
    convenience init?(mobileprovisionFilePath: String){
        var decoder: CMSDecoder? = nil
        let s1 = CMSDecoderCreate(&decoder);
        let data: Data = try! Data.init(contentsOf: URL.init(fileURLWithPath: mobileprovisionFilePath))
        let dataBytes = data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> UnsafePointer<UInt8> in
            return bytes
        }
        let s2 = CMSDecoderUpdateMessage(decoder!, dataBytes, data.count);
        let s3 = CMSDecoderFinalizeMessage(decoder!);
        var dataRef: CFData? = nil
        let s4 = CMSDecoderCopyContent(decoder!, &dataRef);
        if (s1 != 0 || s2 != 0 || s3 != 0 || s4 != 0) {
            return nil
        }else{
            let xmlString = String.init(data: dataRef! as Data, encoding: .utf8)!
            self.init(xmlString:xmlString)
        }
    }
}

