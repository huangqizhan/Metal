//
//  MetalView.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/9.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit
import MetalKit

internal let shareDevide = MTLCreateSystemDefaultDevice()

open class MetalView: MTKView {
    
    /// 创建纹理
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
