//
//  Utils.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/7.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit
import Metal
import simd

extension Bundle {
    static var metal : Bundle {
        var bundle = Bundle.main
        let frameWork = Bundle(for: MetalCanvas.self)
        if let path = frameWork.path(forResource: "Metal", ofType: "bundle") {
            bundle = Bundle(path: path) ?? Bundle.main
        }
        return bundle
    }
}

extension MTLDevice {
    /// default library
    func libraryForMetal() -> MTLLibrary? {
        let frameWork = Bundle.init(for: MetalCanvas.self)
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

// MARK: - Point Utils
extension CGPoint {
    
    func between(min: CGPoint, max: CGPoint) -> CGPoint {
        return CGPoint(x: x.valueBetween(min: min.x, max: max.x),
                       y: y.valueBetween(min: min.y, max: max.y))
    }
    
    // MARK: - Codable utils
    static func make(from ints: [Int]) -> CGPoint {
        return CGPoint(x: CGFloat(ints.first ?? 0) / 10, y: CGFloat(ints.last ?? 0) / 10)
    }
    
    func encodeToInts() -> [Int] {
        return [Int(x * 10), Int(y * 10)]
    }
}

extension CGSize {
    // MARK: - Codable utils
    static func make(from ints: [Int]) -> CGSize {
        return CGSize(width: CGFloat(ints.first ?? 0) / 10, height: CGFloat(ints.last ?? 0) / 10)
    }
    
    func encodeToInts() -> [Int] {
        return [Int(width * 10), Int(height * 10)]
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}

/// called when saving or reading finished
public typealias ResultHandler = (Result<Void, Error>) -> ()

/// called when saving or reading progress changed
public typealias ProgressHandler = (CGFloat) -> ()


// MARK: - Progress reporting
/// report progress via progresshander on main queue
internal func reportProgress(_ progress: CGFloat, on handler: ProgressHandler?) {
    DispatchQueue.main.async {
        handler?(progress)
    }
}

internal func reportProgress(base: CGFloat, unit: Int, total: Int, on handler: ProgressHandler?) {
    let progress = CGFloat(unit) / CGFloat(total) * (1 - base) + base
    reportProgress(progress, on: handler)
}
