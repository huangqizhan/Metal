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
    
    var brushs : [MetalBrush] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            let pen = canvas.defaultBrush!
            pen.name = "Pen"
            pen.opacity = 0.1
            pen.pointSize = 5
            pen.pointStep = 0.5
            pen.color = canvas.currentBrush.color
            
            
            let pencil = try registerBrush(with: "pencil")
            pencil.rotation = .random
            pencil.pointSize = 3
            pencil.pointStep = 2
            pencil.forceSensitive = 0.3
            pencil.opacity = 1
            
            
            let brush = try registerBrush(with: "brush")
            brush.rotation = .ahead
            brush.pointSize = 15
            brush.pointStep = 2
            brush.forceSensitive = 1
            brush.color = canvas.currentBrush.color
            brush.forceOnTap = 0.5
            
            brushs = [pen,pencil,brush]
        } catch  {
            
        }
    }
    @IBAction func segmengaction(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex < brushs.count else {
            return
        }
        let brush = brushs[sender.selectedSegmentIndex]
        brush.use()
    }
    private func registerBrush(with imageName: String) throws -> MetalBrush {
        let texture = try canvas.makeTexture(with: UIImage(named: imageName)!.pngData()!)
        return try canvas.registerBrush(name: imageName, textureId: texture.id);
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
