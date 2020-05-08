//
//  MetalTexture.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/8.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import Foundation
import Metal
import UIKit

open class MetalTexture : Hashable{
    
    open private(set) var id : String
    
    open private(set) var texture : MTLTexture
    
    init(id : String , texture : MTLTexture) {
        self.id = id
        self.texture = texture
    }
    
    open lazy var size : CGSize = {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: CGFloat(texture.width) / scale , height: CGFloat(texture.height) / scale)
    }()
    
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: MetalTexture, rhs: MetalTexture) -> Bool {
        return true
    }
    
}
