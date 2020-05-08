//
//  MetalRenderTarget.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/8.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit
import Foundation
import Metal
import simd


open class MetalRenderTarget {
    
    public private(set) var texture : MTLTexture?
    
    open var scale : CGFloat = 1.0 {
        didSet{
            updateTransformBuffer()
        }
    }
    
    open var zoom : CGFloat = 1.0
    
    open var contentOffset : CGPoint = .zero {
        didSet{
            updateTransformBuffer()
        }
    }
    /// 像素格式
    internal var pixelFormat: MTLPixelFormat = .bgra8Unorm
    /// 绘图区域
    internal var drawableSize: CGSize
    /// buffer
    internal var uniform_buffer: MTLBuffer!
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
    
    public init (size: CGSize , pixelFormat : MTLPixelFormat , device : MTLDevice?){
        self.drawableSize = size
        self.device = device
        self.texture = makeEmptyTexture()
        self.pixelFormat = pixelFormat
        self.commandQueue = self.device?.makeCommandQueue()
        renderPassDescriptor = MTLRenderPassDescriptor()
        let attachment = renderPassDescriptor?.colorAttachments[0]
        attachment?.texture = texture
        attachment?.loadAction = .load
        attachment?.storeAction = .store
    }
    
    open func clear(){
        texture = makeEmptyTexture()
        renderPassDescriptor?.colorAttachments[0].texture = texture
        commitCommand()
    }
    
    internal func updateBuffer(width size : CGSize ) {
        self.drawableSize = size
        let matrix = Matrix.identify
        
    }
    
    internal func updateTransformBuffer() {
    }
    internal func commitCommand(){
        commandBuffer?.commit()
        commandBuffer = nil
        modified = true
    }
    
    internal func makeEmptyTexture() -> MTLTexture? {
//       guard drawableSize.width * drawableSize.height > 0 else {
//             return nil
//         }
//         let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
//                                                                          width: Int(drawableSize.width),
//                                                                          height: Int(drawableSize.height),
//                                                                          mipmapped: false)
//         textureDescriptor.usage = [.renderTarget, .shaderRead]
//         let texture = device?.makeTexture(descriptor: textureDescriptor)
//         texture?.clear()
//         return texture
        return nil;
    }
    
}
