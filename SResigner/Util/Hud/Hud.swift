//
//  Hud.swift
//  SResigner
//
//  Created by jerry on 2018/11/21.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Cocoa
import SnapKit
private extension NSView{
    var _hud: Hud?{
        set{
            let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "_hud".hashValue)
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get{
            let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "_hud".hashValue)
            return objc_getAssociatedObject(self, key) as? Hud
        }
    }
}
class Hud: NSView {
    @IBOutlet weak var _indicator: NSProgressIndicator!
    @IBOutlet weak var _messageLb: NSTextField!
    var maskView: NSView!
    weak var inView: NSView?
    init(inView: NSView) {
        super.init(frame: NSRect.zero)
        self.inView = inView
        var arr: NSArray? = nil
        Bundle.main.loadNibNamed(NSNib.Name.init("Hud"), owner: self, topLevelObjects: &arr)
        maskView = (arr!.filter({$0 is NSView}).first!) as! NSView
        self.addSubview(maskView)
        maskView.wantsLayer = true
        maskView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.6).cgColor
        maskView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self._messageLb.stringValue = ""
        self.inView?._hud = self
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var message: String{
        set{
            forceMainAsyn {
                self._messageLb.stringValue = newValue
            }
        }
        get{
            return forceMainSyn { self._messageLb.stringValue }
        }
    }
    static func showHudInView(_ view: NSView) -> Hud{
        return forceMainSyn{
                    if view._hud != nil{
                        return view._hud!
                    }
                    let hud = Hud.init(inView: view)
                    hud.show()
                    return hud
                }

    }
    static func hideHudInView(_ view: NSView){
        forceMainAsyn {
            if view._hud == nil{
                return
            }
            view._hud?.hide()
        }
    }
    func hide(){
        forceMainAsyn {
            self.removeFromSuperview()
            self.inView?._hud = nil
        }
    }
    
    func show(){
        forceMainAsyn {
            guard let inView = self.inView else{
                return
            }
            inView.addSubview(self, positioned: .above, relativeTo: nil)
            self.snp.makeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
            self._indicator.startAnimation(nil)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        //NOP Just Intercept
    }
}
