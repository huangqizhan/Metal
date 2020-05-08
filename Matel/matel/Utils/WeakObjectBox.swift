//
//  WeakObjectBox.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/7.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

final class WeakObjectBox {
    weak var unboxed : AnyObject?
    
    init(_ boxed : AnyObject?) {
        unboxed = boxed
    }
    
}

class WeakObjectsPool {
    
    /////    compactMap     遍历不会nil
    
    private var boxes : [WeakObjectBox] = []
    
    func addObjec(object : AnyObject?) {
        self.boxes.append(WeakObjectBox(object))
    }
    /// 清空 unboex ==  nil
    func clean() {
        boxes = boxes.compactMap({ $0.unboxed == nil ? nil : $0 })
    }
    /// 清空有 WeakObjectBox ==  nil
    func alive() -> [AnyObject] {
        return boxes.compactMap({$0.unboxed})
    }
    
}





