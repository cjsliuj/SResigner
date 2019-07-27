//
//  UIColor.swift
//  XLWheel
//
//  Created by 刘杰 on 2018/7/30.
//  Copyright © 2018年 xunlei. All rights reserved.
//

import Foundation
import AppKit
extension NSColor{
    public convenience init (rgb: UInt){
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16)/255.0,
                     green: CGFloat((rgb & 0xFF00) >> 8)/255.0,
                     blue: CGFloat(rgb & 0xFF)/255.0, alpha: 1)

    }
    public convenience init (rgb: UInt, alpha: CGFloat){
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16)/255.0,
                  green: CGFloat((rgb & 0xFF00) >> 8)/255.0,
                  blue: CGFloat(rgb & 0xFF)/255.0,
                  alpha: alpha)
        
    }
    public convenience init (rgba: UInt){
        self.init(red: CGFloat((rgba & 0xFF000000) >> 24)/255.0,
                            green: CGFloat((rgba & 0xFF0000) >> 16)/255.0,
                            blue: CGFloat((rgba & 0xFF00) >> 8)/255.0,
                            alpha: CGFloat(rgba & 0xFF)/255.0)
        
    }
    public convenience init? (hexString: String){
        let s = hexString.lowercased().replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        guard let val = UInt(s, radix: 16) else{
            return nil
        }
        let length = s.count
        // RGB / RRGGBB
        if length == 3 || length == 6{
            self.init(red: CGFloat((val & 0xFF0000) >> 16)/255.0,
                      green: CGFloat((val & 0xFF00) >> 8)/255.0,
                      blue: CGFloat(val & 0xFF)/255.0, alpha: 1)
        }else if length == 4 || length == 8{ // RGBA / RRGGBBAA
            self.init(red: CGFloat((val & 0xFF000000) >> 24)/255.0,
                      green: CGFloat((val & 0xFF0000) >> 16)/255.0,
                      blue: CGFloat((val & 0xFF00) >> 8)/255.0,
                      alpha: CGFloat(val & 0xFF)/255.0)
        }else{
            return nil
        }
        
    }
    
  
    public var rgbaValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let red = UInt(r * 255)
            let green = UInt(g * 255)
            let blue = UInt(b * 255)
            let alpha = UInt(a * 255)
            return (red << 24) + (green << 16) + (blue << 8) + alpha
        }
    }
    
    public var rgbValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let red = UInt(r * 255)
            let green = UInt(g * 255)
            let blue = UInt(b * 255)
            return (red << 16) + (green << 8) + blue
        }
    }
    public var redValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            return UInt(r * 255)
        }
    }
    public var greenValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            return UInt(g * 255)
        }
    }
    public var blueValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            return UInt(b * 255)
        }
    }
    public var alphaValue: UInt{
        get{
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            self.getRed(&r, green: &g, blue: &b, alpha: &a)
            return UInt(a * 255)
        }
    }
}
