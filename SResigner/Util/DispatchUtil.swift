//
//  DispatchUtil.swift
//  SResigner
//
//  Created by jerry on 2018/11/22.
//  Copyright © 2018年 com.sz.jerry. All rights reserved.
//

import Foundation
func forceMainAsyn(_ task: @escaping ()->Void){
    if Thread.isMainThread{
        task()
    }else{
        DispatchQueue.main.async {
            task()
        }
    }
}
func forceMainSyn<T>(_ task: () -> T) -> T{
    if Thread.isMainThread{
        return task()
    }else{
        return DispatchQueue.main.sync {
                    return task()
               }
    }
}
