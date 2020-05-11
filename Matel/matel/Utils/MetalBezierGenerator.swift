//
//  MetalBezierGenerator.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/11.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

class MetalBezierGenerator{
    
    enum Style {
        case linear
        case quadratic
        case cubic
    }
    
    var points: [CGPoint] = []
    var style: Style = .quadratic
    private var step = 0
    
    
    init() {
    }
    
    init(beginPoint : CGPoint) {
    }
    func begin(with point : CGPoint) {
        step = 0
        points.removeAll()
        points.append(point)
    }
    
    func pushPoint(_ point : CGPoint) -> [CGPoint] {
        if point == points.last {
            return []
        }
        points.append(point)
        if points.count < self.style.pointCount{
            return []
        }
        step += 1
        let result = generatePathPoint()
        return result
    }
    
    func finish() {
        step = 0
        points.removeAll()
    }
    
    private func generatePathPoint() -> [CGPoint]{
        var beginPoint :CGPoint
        var controPoint :CGPoint
        let end = CGPoint.middle(p1: points[step], p2: points[step + 1])
        
        var vertices:[CGPoint] = []
        
        if step == 1 {
            beginPoint = points[0]
            let middle1 = CGPoint.middle(p1: points[0], p2: points[1])
            controPoint = CGPoint.middle(p1: middle1, p2: points[2])
        }else{
            beginPoint = CGPoint.middle(p1: points[step - 1], p2: points[step])
            controPoint = points[step]
        }
        
        let dis = beginPoint.distance(to: end)
        let segements = max(Int(dis / 5), 2)

        for i in 0 ..< segements {
            let t = CGFloat(i) / CGFloat(segements)
            let x = pow(1 - t, 2) * beginPoint.x + 2.0 * (1 - t) * t * controPoint.x + t * t * end.x
            let y = pow(1 - t, 2) * beginPoint.y + 2.0 * (1 - t) * t * controPoint.y + t * t * end.y
            vertices.append(CGPoint(x: x, y: y))
        }
        return vertices
    }
}



extension MetalBezierGenerator.Style{
    
    var pointCount : Int {
        switch self {
        case .quadratic:
            return 3
        default: return Int.max
        }
    }
    
    
}
