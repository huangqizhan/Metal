//
//  SingleViewController.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/7.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

class SingleViewController: UIViewController {

    
    @IBOutlet weak var canvas: MetalCanvas!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    @IBOutlet weak var colorBgView: UIView!
    
    @IBAction func rSliderAction(_ sender: UISlider) {
        r = CGFloat(sender.value)
        colorBgView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1);
        canvas.currentBrush.color = colorBgView.backgroundColor ?? UIColor.white
    }
    
    @IBAction func gSliderAction(_ sender: UISlider) {
        g = CGFloat(sender.value)
        colorBgView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1);
        canvas.currentBrush.color = colorBgView.backgroundColor ?? UIColor.white
    }
    
    @IBAction func bSliderAction(_ sender: UISlider) {
        b = CGFloat(sender.value)
        colorBgView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1);
        canvas.currentBrush.color = colorBgView.backgroundColor ?? UIColor.white
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
