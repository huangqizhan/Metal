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
    
    
    required init(name: String) {
        self.name = name
    }
    
    required init(n1 : CGFloat , n2 : CGFloat) {
        
    }
    
    init() {
        
    }
    

    convenience init(sf:[String]){
        self.init()
    }
}

extension TSwift{

}


class TSubSwift: TSwift {
    
    required init(name: String) {
        super.init(name: name)
    }
//
//    required init(n1: CGFloat, n2: CGFloat) {
//        fatalError("init(n1:n2:) has not been implemented")
//    }
    
    required init(n1: CGFloat, n2: CGFloat) {
        super.init(n1: n1, n2: n2)
    }
    
    override init() {
        super.init()
    }
}





func *(lhs : TSwift , rhs: CGFloat) ->TSwift{
    lhs.valeu = lhs.valeu * rhs
    return lhs
}



