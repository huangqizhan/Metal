//
//  TSwift.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/11.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

class TSwift {
    
    var valeu : CGFloat = 1.0
    
    public private(set) var name: String?

}




func *(lhs : TSwift , rhs: CGFloat) ->TSwift{
    lhs.valeu = lhs.valeu * rhs
    return lhs
}



