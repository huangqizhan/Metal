//
//  MetalPaintintGestureRecognizer.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/10.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

open class MetalPaintintGestureRecognizer: UIPanGestureRecognizer {
    
    
    private weak var targetView : UIView?
    
    /// 当前压力值，启用压力感应时，使用真实的压力，否则使用模拟压感
    var force: CGFloat = 1
    
    /// 是否启用压力感应，默认开启
    var forceEnabled = true
    
    /// 手势开始点
//    var acturalBeginLocation: CGPoint = CGPoint.zero
    
    @discardableResult
    open class func addTarget(_ view: UIView , action:Selector) -> MetalPaintintGestureRecognizer{
        let obj = MetalPaintintGestureRecognizer(targetView: view, action: action)
        view.addGestureRecognizer(obj)
        return obj
    }
    
    convenience init(targetView t: UIView, action: Selector?) {
        self.init(target: t , action : action)
        targetView = t
        maximumNumberOfTouches = 1
    }
    
    private func updateForceFromTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
                
        if forceEnabled {
            force = max(0, touch.force / 3)
        } else {
            // use simulated force
            let vel = velocity(in: targetView)
            var length = vel.distance(to: .zero)
            length = min(length, 5000)
            length = max(100, length)
            force = sqrt(1000 / length)
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        updateForceFromTouches(touches)
        super.touchesBegan(touches, with: event)
    }
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        updateForceFromTouches(touches)
        super.touchesMoved(touches, with: event)
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        updateForceFromTouches(touches)
        super.touchesEnded(touches, with: event)
    }
}
