//
//  MetalError.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/8.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import Foundation

/// 错误
enum MetalError : Error {
    
    /// 文件不存在
    case fileNotExist(String)
    ///文件损坏
    case fileDamaged
    
    case directoryNotEmpty
    
    case simulatorNoSupported
}
