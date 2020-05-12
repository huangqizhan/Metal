//
//  MetalPrinter.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/11.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

public final class MetalPrinter : MetalBrush {
    
    public override func makeShaderVertexFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "vertex_printer_func")
    }
    public override func makeShaderFragmentFunction(from library: MTLLibrary) -> MTLFunction? {
        return library.makeFunction(name: "fragment_render_target")
    }
    
    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true
        
        attachment.rgbBlendOperation = .add
        attachment.sourceRGBBlendFactor = .one
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        
        attachment.alphaBlendOperation = .add
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }
    
    final func render(chartlet: MetalChartlet, on renderTarget: MetalRenderTarget? = nil){
        guard let target = renderTarget ?? self.target?.screenRender else{ return }
        target.prepareForDraw()
        
        let commandEmcoder = target.makeCommandEncoder()
        commandEmcoder?.setRenderPipelineState(pipelineState)
        
    }
}
