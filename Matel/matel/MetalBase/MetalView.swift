//
//  MetalView.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/9.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit
import MetalKit

internal let shareDevide = MTLCreateSystemDefaultDevice()

open class MetalView: MTKView {
    
    /// 背景渲染器
    internal var screenRender: MetalRenderTarget?
    /// 命令队列
    private var commandQueue : MTLCommandQueue?
    /// 顶点数据
    private var render_target_vertex : MTLBuffer!
    ///平移 放缩数据
    private var render_target_uniform : MTLBuffer!
    /// 渲染管线
    private var pipelineState : MTLRenderPipelineState!
    // MARK: ---   创建纹理
    func makeTexture(with data : Data ,id : String? = nil) throws -> MetalTexture {
        guard metalavaliable else {
            throw MetalError.simulatorNoSupported
        }
        let textureloader = MTKTextureLoader(device: device!)
        let texture = try textureloader.newTexture(data: data, options: [.SRGB: false])
        return  MetalTexture(id: id ?? UUID().uuidString, texture: texture)
    }
    
    func makeTexture(with url : URL , id : String? = nil) throws -> MetalTexture  {
        let data = try Data(contentsOf: url)
        return try makeTexture(with: data , id:id)
    }
    
    internal func getPipelineState() ->MTLRenderPipelineState {
        return self.pipelineState
    }
    
    //MARK: ---  清空画布
    func clear(display : Bool = true) {
        screenRender?.clear()
        if display {
            setNeedsDisplay()
        }
    }
    
    // MARK:-- overide
    open override func layoutSubviews() {
        super.layoutSubviews()
        screenRender?.updateBuffer(width: drawableSize)
    }
    
    open override var backgroundColor: UIColor?{
        didSet{
            clearColor = (backgroundColor ?? .white).toMetalClearColor()
        }
    }
    // MARK: --- INIT
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        setup()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    // MARK: --- setup
    func setup() {
        guard metalavaliable else {
            print("current device id no support metal")
            return
        }
        
        device = shareDevide
        isOpaque = false
        
        commandQueue = device?.makeCommandQueue()
        screenRender = MetalRenderTarget(size: drawableSize, pixelFormat: colorPixelFormat, device: device ,queue: commandQueue)
        setRenderTatgetUniformData()
        
        do {
            try setPipelineState()
        } catch{
            fatalError("metal render pipe line state error ")
        }
    }
    
    // MARK:创建数据
    private func setRenderTatgetUniformData(){
        let size = drawableSize
        let w = size.width , h = size.height
        let vertexes = [
            Vertex(position: CGPoint(x: 0, y: 0), textCoord: CGPoint(x: 0, y: 0)),
            Vertex(position: CGPoint(x: w, y: 0), textCoord: CGPoint(x: 1, y: 0)),
            Vertex(position: CGPoint(x: 0, y: h), textCoord: CGPoint(x: 0, y: 1)),
            Vertex(position: CGPoint(x: w, y: h), textCoord: CGPoint(x: 1, y: 1))
        ]
        
        render_target_vertex = device?.makeBuffer(bytes: vertexes, length: MemoryLayout<Vertex>.stride * vertexes.count, options: [.cpuCacheModeWriteCombined])
        
        let mritex = Matrix.identify
        mritex.scaling(x: 2 / Float(size.width), y: -2 / Float(size.height), z: 1)
        mritex.translation(x: -1, y: 1, z: 0)
        render_target_uniform = device?.makeBuffer(bytes: mritex.m, length: MemoryLayout<Float>.size * 16, options: [])
    }
    
    // MARK: 创建渲染管线
    private func setPipelineState() throws {
        let library = device?.libraryForMetal()
        /// 着色器
        let vertex_fun = library?.makeFunction(name: "vertex_render_target")
        let fragment_fun = library?.makeFunction(name: "fragment_render_target")
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vertex_fun
        rpd.fragmentFunction = fragment_fun
        rpd.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineState = try device?.makeRenderPipelineState(descriptor: rpd)
    }
    
    
    open override func draw() {
        super.draw()

        guard metalavaliable, let render = screenRender , render.modified ,let texture = render.texture else {
            return
        }
        let renderpassdescriptor = MTLRenderPassDescriptor()
        let attachment = renderpassdescriptor.colorAttachments[0]
        attachment?.clearColor = clearColor
        attachment?.texture = currentDrawable?.texture
        attachment?.loadAction = .load
        attachment?.storeAction = .store

        let commanderBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commanderBuffer?.makeRenderCommandEncoder(descriptor:renderpassdescriptor)

        commandEncoder?.setRenderPipelineState(pipelineState)
        /// 设置顶点着色器的参数
        commandEncoder?.setVertexBuffer(render_target_vertex, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(render_target_uniform, offset: 0, index: 1)

        /// 设置片段着色器的纹理
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder?.endEncoding()
        if let drawable = currentDrawable {
            commanderBuffer?.present(drawable)
        }
        commanderBuffer?.commit()
        render.modified = false
    }
}

internal var metalavaliable: Bool = {
    #if targetEnvironment(simulator)
    if #available(iOS 13.0 , *) {
        return true
    }else {
        return false
    }
    #else
    return true
    #endif
}()
