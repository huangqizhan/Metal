//
//  MetalColor.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/8.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit
import Foundation
import simd


// Metal 颜色
public struct MetalColor : Codable{
    
    public internal(set) var red : Float
    public internal(set) var green : Float
    public internal(set) var blue : Float
    public internal(set) var alpha : Float
    
    public static var black = UIColor.black.toMetalColor()
    public static var white = UIColor.white.toMetalColor()
    
    
    public func toFloat4() -> vector_float4{
        return vector_float4(red, green, blue, alpha)
    }
    
    public init(red: Float ,green: Float , blue: Float , alphe: Float){
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alphe
    }
    
    /// 解码16进制  分配每个分量
    public init(from decoder: Decoder) throws{
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        var int = UInt32()
        Scanner(string: hexString).scanHexInt32(&int)
        let a, r, g, b: UInt32
        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        (alpha, red, green, blue) = (Float(a) / 255.0, Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0)
    }
    
    /// 编码成16进制  
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let aInt = Int(alpha * 255) << 24
        let rInt = Int(red * 255) << 16
        let gInt = Int(green * 255) << 8
        let bInt = Int(blue * 255)
        let argb = aInt | rInt | gInt | bInt
        let hex = String(format:"%08x", argb)
        try container.encode(hex)
    }
    
    
}


extension UIColor {
    func toMetalColor(opacity: CGFloat = 1) -> MetalColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return MetalColor(red: Float(r), green: Float(g), blue: Float(b), alphe: Float(opacity * a))
    }
    
    func toMetalClearColor() -> MTLClearColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return MTLClearColorMake(Double(r), Double(g), Double(b), Double(a))
    }
}



