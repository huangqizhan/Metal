//
//  RootViewController.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/7.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

class Tmodel {
    
    var name : String = "123"
    
    init() {
    }
    
    static func ac1(){
        
    }
    class func ac2(){
        
    }
    
}



class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Tmodel.ac1()
        Tmodel.ac2()
        
        
//        let scale = UIScreen.main.scale
//        print("scale \(scale)")
//        let scaleFactor = UIScreen.main.nativeScale
//        print("scale \(scaleFactor)")
        
    }
}
