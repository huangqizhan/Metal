//
//  MetalTexture.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/8.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import Foundation
import Metal
import UIKit

// Metal 纹理
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
        return lhs.id == rhs.id
    }
    
}


extension MetalTexture {
    /// ciimage
    func toCIImage() -> CIImage? {
        let image = CIImage(mtlTexture: texture, options: [CIImageOption.colorSpace:CGColorSpaceCreateDeviceRGB()])
        return image?.oriented(CGImagePropertyOrientation.downMirrored)
    }
    
    ///CGImage
    func toCGImage() -> CGImage? {
        guard let cimage = toCIImage() else {
            return nil
        }
        
        let cicontext = CIContext();
        let rect = CGRect(origin: .zero, size: cimage.extent.size)
        return cicontext.createCGImage(cimage, from: rect)
    }
    
    /// UIImage
    func toUIImage() -> UIImage? {
        guard let cgimage = toCGImage() else {
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
    
    /// Data
    func toData() -> Data? {
        guard let uiimage = toUIImage() else {
            return nil;
        }
        return uiimage.pngData()
    }
    
}
