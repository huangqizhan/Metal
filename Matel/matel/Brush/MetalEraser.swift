//
//  MetalEraser.swift
//  Matel
//
//  Created by 黄麒展 on 2020/7/27.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

public class MetalEraser: MetalBrush {
    public override func setupBlendOptions(for attachment: MTLRenderPipelineColorAttachmentDescriptor) {
        attachment.isBlendingEnabled = true
        attachment.alphaBlendOperation = .reverseSubtract
        attachment.rgbBlendOperation = .reverseSubtract
        attachment.sourceRGBBlendFactor = .zero
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationRGBBlendFactor = .destinationAlpha
        attachment.destinationAlphaBlendFactor = .one
    }
}
