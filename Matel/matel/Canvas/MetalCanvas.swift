//
//  Cancas.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/7.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

open class MetalCanvas : MetalView {
    
    open var defaultBrush : MetalBrush!
    
    open private(set) var printer : MetalPrinter!
    
    open var isPencilMode : Bool = false {
        didSet{
            isMultipleTouchEnabled = isPencilMode
        }
    }
    open var useFingersToErase = false
    
    open var size : CGSize {
        return drawableSize / contentScaleFactor
    }
    
    open weak var renderingDelegate : MetalRenderingDelegate?
    internal var actionObserves = MetalActionObserverPool()
    
    open func addObderve(observe : MetalActionObserver){
        actionObserves.clean()
        actionObserves.addObserver(observe)
    }
    
    
    open private(set) var textures: [MetalTexture] = []
    
    open internal(set) var currentBrush : MetalBrush!
    
    open func findTexture(by id : String) ->MetalTexture?{
        return textures.first(where: {$0.id == id })
    }
}
