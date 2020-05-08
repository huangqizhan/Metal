//
//  RootViewController.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/7.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

class Tmodel {
    var vale : Float = 1{
        didSet{
            print("didset")
        }
    }
}


class RootViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tmodel = Tmodel.init()
        print("vale = \(tmodel.vale)")
        tmodel.vale = 2.2;
        
        print("vale = \(tmodel.vale)")
        
    }
}
