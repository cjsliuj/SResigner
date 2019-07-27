//
//  Data.swift
//  XLWheel-iOS-TestApp
//
//  Created by jerry on 2018/9/23.
//  Copyright © 2018年 xunlei. All rights reserved.
//

import Foundation
import CommonCrypto
extension Data{
    public var bytesPointer: UnsafePointer<Int8> { return self.withUnsafeBytes { return $0 }}
    
    //MARK: - Hash
    public var md5String: String{ return self.md5Data.hexString }
    public var sha1String: String{ return sha1Data.hexString }
    public var sha224String: String{ return sha224Data.hexString }
    public var sha256String: String{ return sha256Data.hexString }
    public var sha384String: String{ return sha384Data.hexString }
    public var sha512String: String{ return sha512Data.hexString }
    
    
    public var bytes: Array<UInt8> {
        return Array(self)
    }

    public var md5Data: Data{
        let len = Int(CC_MD5_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_MD5(self.bytesPointer, UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public var sha1Data: Data{
        let len = Int(CC_SHA1_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_SHA1(self.bytesPointer,UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public var sha224Data: Data{
        let len = Int(CC_SHA224_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_SHA224(self.withUnsafeBytes { (p: UnsafePointer<Int8>) -> UnsafePointer<Int8> in
            return p
        },UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public var sha256Data: Data{
        let len = Int(CC_SHA256_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_SHA256(self.bytesPointer ,UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public var sha384Data: Data{
        let len = Int(CC_SHA384_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_SHA384(self.bytesPointer ,UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public var sha512Data: Data{
        let len = Int(CC_SHA512_DIGEST_LENGTH)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        CC_SHA512(self.bytesPointer,UInt32(self.count), buffer)
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: len)
    }
    public func hmacMD5String(withKey key: String) -> String{
        return self.hmacMD5Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacSHA1String(withKey key: String) -> String{
        return self.hmacSHA1Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacSHA224String(withKey key: String) -> String{
        return self.hmacSHA224Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacSHA256String(withKey key: String) -> String{
        return self.hmacSHA256Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacSHA384String(withKey key: String) -> String{
        return self.hmacSHA384Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacSHA512String(withKey key: String) -> String{
        return self.hmacSHA512Data(withKey: key.data(using: .utf8)!).hexString
    }
    public func hmacMD5Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgMD5), withKey: key)
    }
    public func hmacSHA1Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA1), withKey: key)
    }
    public func hmacSHA224Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA224), withKey: key)
    }
    public func hmacSHA256Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA256), withKey: key)
    }
    public func hmacSHA384Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA384), withKey: key)
    }
    public func hmacSHA512Data(withKey key: Data) -> Data{
        return _hmacData(usingAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA512), withKey: key)
    }
    private func _hmacData(usingAlgorithm alg: CCHmacAlgorithm, withKey key: Data) -> Data{
        var size: Int32!
        if alg == kCCHmacAlgMD5{
            size = CC_MD5_DIGEST_LENGTH
        }else if alg == kCCHmacAlgSHA1{
            size = CC_SHA1_DIGEST_LENGTH
        }else if alg == kCCHmacAlgSHA224{
            size = CC_SHA224_DIGEST_LENGTH
        }else if alg == kCCHmacAlgSHA256{
            size = CC_SHA256_DIGEST_LENGTH
        }else if alg == kCCHmacAlgSHA384{
            size = CC_SHA384_DIGEST_LENGTH
        }else if alg == kCCHmacAlgSHA512{
            size = CC_SHA512_DIGEST_LENGTH
        }
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(size))
        CCHmac(alg, key.bytesPointer, key.count, self.bytesPointer, self.count, buffer);
        return Data.init(bytes: UnsafeRawPointer.init(buffer), count: Int(size))
    }
    
    //MARK: - Encrypt / Decrypt [TODO]
    //MARK: - 压缩 / 解压缩 [TODO]
    //MARK: - Encode
    public var hexString: String{
        return self.map{String(format: "%02x", $0)}.joined()
    }
}
