//
//  RootViewController.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/7.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr : [String] = ["1","2","3","4","5"];
        let res = arr.first { (str ) -> Bool in
            let n = Int(str)!
            if n >= 4{
                return true
            }
            return false
        }
        
        guard let s = res  else {
            return
        }
        print("res = \(s)")
    }
}
