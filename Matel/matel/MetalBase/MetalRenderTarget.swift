//
//  MetalRenderTarget.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/8.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit
import Foundation
import Metal
import simd

/// 主要负责渲染 
open class MetalRenderTarget {
    
    /// 背景纹理
    public private(set) var texture : MTLTexture?
    open var scale : CGFloat = 1 {
        didSet{
            updateTransformBuffer()
        }
    }
    
    open var zoom : CGFloat = 1
    
    open var contentOffset : CGPoint = .zero {
        didSet{
            updateTransformBuffer()
        }
    }
    /// 像素格式
    internal var pixelFormat: MTLPixelFormat = .bgra8Unorm
    /// 绘图区域
    internal var drawableSize: CGSize
    /// 顶点 buffer
    internal var uniform_buffer: MTLBuffer!
    /// 顶点平移 buffer
    internal var transform_buffer: MTLBuffer!
    ///渲染编码器描述
    internal var renderPassDescriptor: MTLRenderPassDescriptor?
    ///渲染编码器buffer
    internal var commandBuffer: MTLCommandBuffer?
    /// 渲染编码器队列
    internal var commandQueue: MTLCommandQueue?
    /// GPU
    internal var device: MTLDevice?
    internal var modified = false
    
    public init (size: CGSize , pixelFormat : MTLPixelFormat , device : MTLDevice? , queue: MTLCommandQueue?){
        self.drawableSize = size
        self.device = device
        self.texture = makeEmptyTexture()
        self.pixelFormat = pixelFormat
//        self.commandQueue = queue
        self.commandQueue = self.device?.makeCommandQueue()
        renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor?.colorAttachments[0]
        attachment?.texture = texture
        attachment?.loadAction = .load
        attachment?.storeAction = .store
    }
    /// 清空画板
    open func clear(){
        texture = makeEmptyTexture()
        renderPassDescriptor?.colorAttachments[0].texture = texture
        commitCommand()
    }
    /// 跟新顶点数据
    internal func updateBuffer(width size : CGSize ) {
        self.drawableSize = size
        let metrix = Matrix.identify
        let zoomUniform = 2 * Float(zoom / scale )
        metrix.scaling(x: zoomUniform  / Float(size.width), y: -zoomUniform / Float(size.height), z: 1)
        metrix.translation(x: -1, y: 1, z: 0)
        uniform_buffer = device?.makeBuffer(bytes: metrix.m, length: MemoryLayout<Float>.size * 16, options: [])
        
        updateTransformBuffer()
    }
    internal func updateTransformBuffer() {
        let scaleFactor = UIScreen.main.nativeScale
        var scrollTransform = ScrollintTransform(offset: contentOffset * scaleFactor, scale: scale)
        transform_buffer = device?.makeBuffer(bytes: &scrollTransform, length: MemoryLayout<ScrollintTransform>.stride, options: [])
    }
    /// 创建 command buffer
    internal func prepareForDraw(){
        if commandBuffer == nil {
            commandBuffer = commandQueue?.makeCommandBuffer()
        }
    }
    
    /// command buffer 编码
    internal func makeCommandEncoder() -> MTLRenderCommandEncoder? {
        guard let commandBuffer = commandBuffer , let rpd = renderPassDescriptor else {
            return nil
        }
        return commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
    }
    
    /// 提交 command
    internal func commitCommand(){
        commandBuffer?.commit()
        commandBuffer = nil
        modified = true
    }
    
    /// 清空纹理 
    internal func makeEmptyTexture() -> MTLTexture? {
       guard drawableSize.width * drawableSize.height > 0 else {
             return nil
         }
         let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: Int(drawableSize.width), height: Int(drawableSize.height), mipmapped: false)
         textureDescriptor.usage = [.renderTarget, .shaderRead]
         let texture = device?.makeTexture(descriptor: textureDescriptor)
         texture?.clear()
         return texture
    }
}


/*
 
MTLVertexDescriptor是用来描述如何组织顶点数据以及如何映射到shader中顶点着色函数的对象。
一个MTLVertexDescriptor对象用来配置顶点数据如何在内存中存储，以及映射到vertex shader中的attribute属性上。
 
 
 */
