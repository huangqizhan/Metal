//
//  MetalGlowBrush.swift
//  Matel
//
//  Created by 黄麒展 on 2020/7/27.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

public class MetalGlowBrush: MetalBrush {
    // 比例
    public var coreProportion : CGFloat = 0.25
    
    private var subBrush : MetalBrush!
    
    private var pendingCoreLines: [MetalLine] = []
    
    public var coreColor : UIColor = .white{
        didSet{
            subBrush.color = coreColor
        }
    }
    
    public override var pointSize: CGFloat{
        didSet{
            subBrush.pointSize = coreProportion * pointSize
        }
    }
    
    public override var pointStep: CGFloat{
        didSet{
            subBrush.pointStep = 1
        }
    }
    
    public override var forceSensitive: CGFloat{
        didSet{
            subBrush.forceSensitive = forceSensitive
        }
    }
    
    public override var scaleWithCanvas: Bool{
        didSet{
            subBrush.scaleWithCanvas = scaleWithCanvas
        }
    }
    
    public override var forceOnTap: CGFloat{
        didSet{
            subBrush.forceOnTap = forceOnTap
        }
    }
    
    public required init(name: String?, textureId: String?, target: MetalCanvas) {
        super.init(name: name, textureId: textureId, target: target)
        subBrush = MetalBrush(name: name, textureId: nil, target: target)
        subBrush.color = coreColor
        subBrush.opacity = 1.0
    }
    
    public override func makeLine(from: CGPoint, to: CGPoint, force: CGFloat? = nil, uniquecolor: Bool = false) -> [MetalLine] {
        let shadowLines = super.makeLine(from: from, to: to, force: force, uniquecolor: uniquecolor);
        let delta = (pointSize * (1 - coreProportion)) / 2
        var coreLines: [MetalLine] = []
        while let first = pendingCoreLines.first?.begin, first.distance(to: from) >= delta  {
            coreLines.append(pendingCoreLines.removeFirst())
        }
        // 中间白线
        let lines = subBrush.makeLine(from: from, to: to, force: force, uniquecolor: true)
        pendingCoreLines.append(contentsOf: lines)
        return shadowLines + lines
    }
    
    public override func finishLineStripe(at end: MetalPan) -> [MetalLine] {
        let lines = pendingCoreLines
        pendingCoreLines.removeAll()
        return lines
    }
}

