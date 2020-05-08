//
//  Utils.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/7.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit
import Metal
import simd

extension Bundle {
    static var metal : Bundle {
        var bundle = Bundle.main
        let frameWork = Bundle(for: Canvas.self)
        if let path = frameWork.path(forResource: "Metal", ofType: "bundle") {
            bundle = Bundle(path: path) ?? Bundle.main
        }
        return bundle
    }
}

extension MTLDevice {
    /// default library
    func libraryForMetal() -> MTLLibrary? {
        let frameWork = Bundle.init(for: Canvas.self)
        guard let path = frameWork.path(forResource: "default", ofType: "metallib") else {
            return nil
        }
        return try? makeLibrary(filepath: path)
    }
}

extension MTLTexture {
    /// 清空纹理数据
    func clear() {
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: self.width, height: self.height, depth: 1))
        let bytesPerRaw = self.width * 4;
        let data = Data(capacity: Int(bytesPerRaw * height))
        if let bytes = data.withUnsafeBytes({ $0.baseAddress }){
            replace(region: region, mipmapLevel: 0, withBytes: bytes, bytesPerRow: bytesPerRaw)
        }
    }
}

