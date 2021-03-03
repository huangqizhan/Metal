//
//  MetalLineStripe.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/11.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

// 一个线条  包含多个线段
open class MetalLineStripe : MetalCanvasElement  {
    
    public var index: Int = 0
    
    public var brushName: String?
    
    public var color: MetalColor
    /// 包含的多条小线段
    public var lines : [MetalLine] = []
    
    open private(set) var vertexCount: Int = 0
    
    private var vertex_buffer: MTLBuffer?
    
    open weak var brush : MetalBrush? {
        didSet{
            brushName = brush?.name
        }
    }
    
    public init(lines : [MetalLine] , brush : MetalBrush) {
        self.lines = lines
        self.brush = brush
        self.color = brush.renderColor
        remakeBuffer(rotation: brush.rotation)
    }
    open func append(lines : [MetalLine ]){
        self.lines.append(contentsOf: lines)
        vertex_buffer = nil
    }
    
    public func drawSelf(on target: MetalRenderTarget?) {
        brush?.render(lineStrip: self, on: target)
    }
    
    // MARK:创建线条中的所有点
    open func remakeVertexBuffers(rotation: MetalBrush.Rotation) -> MTLBuffer?{
        if vertex_buffer == nil {
            remakeBuffer(rotation: rotation)
        }
        return vertex_buffer
    }
    // 构建顶点数据
    private func remakeBuffer(rotation: MetalBrush.Rotation){
        guard lines.count > 0 else {
            return
        }
        var vertexes: [Point] = []
        lines.forEach { (line) in
            let scale = brush?.target?.contentScaleFactor ?? UIScreen.main.nativeScale
            var line = line
            line.begin = line.begin * scale
            line.end = line.end * scale
            let count = max(line.length / line.pointStep, 1)
            
            for i in 0 ..< Int(count) {
                let index = CGFloat(i)
                let x = line.begin.x + (line.end.x - line.begin.x) * (index / count)
                let y = line.begin.y + (line.end.y - line.begin.y) * (index / count)
                var angle: CGFloat = 0
                switch rotation {
                case let .fixed(a): angle = a
                case .random: angle = CGFloat.random(in: -CGFloat.pi ... CGFloat.pi)
                case .ahead: angle = line.angle
                }
                vertexes.append(Point(x: x, y: y, color: line.color ?? color, size: line.pointSize * scale, angle: angle))
            }
        }
        vertexCount = vertexes.count
        vertex_buffer = shareDevide?.makeBuffer(bytes: vertexes, length: MemoryLayout<Point>.stride * vertexes.count, options: [.cpuCacheModeWriteCombined])
    }
    
    // MARK: - Coding
    enum CodingKeys: String, CodingKey {
        case index
        case brush
        case lines
        case color
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        brushName = try container.decode(String.self, forKey: .brush)
        lines = try container.decode([MetalLine].self, forKey: .lines)
        color = try container.decode(MetalColor.self, forKey: .color)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(brushName, forKey: .brush)
        try container.encode(lines, forKey: .lines)
        try container.encode(color, forKey: .color)
    }
    
}
