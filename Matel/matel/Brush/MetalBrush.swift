//
//  MetalBrush.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/11.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

public struct MetalPan{
    
    var point : CGPoint
    var force : CGFloat
    
    
    init(touch : UITouch , on view : UIView) {
        if #available(iOS 9.1, *) {
            point = touch.preciseLocation(in: view)
        }else{
            point = touch.location(in: view)
        }
        force = touch.force
        if touch.type == .direct , force == 0 {
            force = 1
        }
    }
    
    init(point: CGPoint , force : CGFloat) {
        self.point = point
        self.force = force
    }
    
}

open class MetalBrush {
    
    public enum Rotation {
        case fixed(CGFloat)
        case random
        case ahead
    }
    
    open var name : String
    open private(set) var textureId : String?
    open private(set) weak var target : MetalCanvas?
    open var pointSize: CGFloat = 4
    open var pointStep: CGFloat = 1
    open var forceSensitive: CGFloat = 0
    open var scaleWithCanvas = false
    open var forceOnTap: CGFloat = 1
    open var rotation = Rotation.fixed(0)
    internal var renderColor : MetalColor = MetalColor(red: 0, green: 0, blue: 0, alphe: 1)
    open private(set) weak var texture : MTLTexture?
    open private(set) var pipelineState : MTLRenderPipelineState!
    
    open var color : UIColor = .black{
        didSet{
            updateRenderingColor()
        }
    }
    open var opacity: CGFloat = 0.3 {
        didSet{
            updateRenderingColor()
        }
    }
    private func updateRenderingColor() {
        renderColor = color.toMetalColor(opacity: opacity)
    }
    required public init(name: String? ,textureId: String? , target: MetalCanvas){
        self.name = name ?? UUID().uuidString
        self.textureId = textureId
        self.target = target
        if let id = textureId {
            texture = target.findTexture(by: id)?.texture
        }
        updatePointPipeline()
    }
    
    open func use(){
        target?.currentBrush = self
    }
    
    open func makeLine(from : MetalPan , to : MetalPan) ->[MetalLine]{
        let endFoece = from.force * 0.95 + to.force*0.05
        let forceRate = pow(endFoece, forceSensitive)
        return makeLine(from: from.point, to: to.point , force: forceRate)
    }
    
    open func makeLine(from : CGPoint, to : CGPoint , force : CGFloat? = nil , uniquecolor:Bool = false) ->[MetalLine]{
        let force = force ?? forceOnTap
        let scale = scaleWithCanvas ? 1 : canvasScale
        let line = MetalLine(begin: (from + canvasOffset)/canvasScale,
                             end: (to + canvasOffset)/canvasScale,
                             pointSize: pointSize * force / scale,
                             pointStep: pointStep / scale, color: nil)
        return [line]
    }
    open func finishLineStripe(at end : MetalPan) ->[MetalLine]{
        return []
    }
    private var canvasScale : CGFloat {
        return target?.screenRender?.scale ?? 1
    }
    
    private var canvasOffset : CGPoint {
        return target?.screenRender?.contentOffset ?? .zero
    }
    
    open func makeShaderLibrary(from device : MTLDevice) ->MTLLibrary?{
        return device.libraryForMetal()
    }
    open func makeShaderVertexFunction(from library : MTLLibrary) ->MTLFunction?{
        return library.makeFunction(name: "vertex_point_func")
    }
    open func makeShaderFragmentFunction(from library : MTLLibrary) ->MTLFunction?{
        if texture == nil {
            return library.makeFunction(name: "fragment_point_func_without_texture")
        }
        return library.makeFunction(name: "fragment_point_func")
    }
    
    
    
    open func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true

        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        attachment.alphaBlendOperation = .add
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
    
    private func updatePointPipeline(){
        guard let target = target , let device = target.device , let library =  makeShaderLibrary(from: device) else {
            return
        }
        let rpd = MTLRenderPipelineDescriptor()
        if let vertex_fun = makeShaderVertexFunction(from: library) {
            rpd.vertexFunction = vertex_fun
        }
        
        if let fragment_fun = makeShaderFragmentFunction(from: library) {
            rpd.fragmentFunction = fragment_fun
        }
        rpd.colorAttachments[0].pixelFormat = target.colorPixelFormat
        setupBlendOptions(for: rpd.colorAttachments[0]!)
        pipelineState = try! device.makeRenderPipelineState(descriptor: rpd)
    }
    
    internal func render(lineStrip : MetalLineStripe, on renderTarget : MetalRenderTarget? = nil){
        let tar = renderTarget ?? target?.screenRender
        guard lineStrip.lines.count > 0 , let target = tar  else {return}
        target.prepareForDraw()
        let commandencoder = target.makeCommandEncoder()
        
        commandencoder?.setRenderPipelineState(pipelineState)
        
        guard let vertex_buffer = lineStrip.remakeVertexBuffers(rotation: rotation) else { return }
        commandencoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
        commandencoder?.setVertexBuffer(target.uniform_buffer, offset: 0, index: 1)
        commandencoder?.setVertexBuffer(target.transform_buffer, offset: 0, index: 2)
        if let texture = texture{
            commandencoder?.setFragmentTexture(texture, index: 0)
        }
        commandencoder?.drawPrimitives(type: .point, vertexStart: 0, vertexCount: lineStrip.vertexCount)
        commandencoder?.endEncoding()
    }
}