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
    
    open private(set) var registerBrushs : [MetalBrush] = []
    
    open var paintingGesture: MetalPaintingGestureRecognizer?
    open var tapGesture : UITapGestureRecognizer?
    
    open private(set) var data : MetalCanvasData!
    
    private var bezierGenerator : MetalBezierGenerator?
    
    // MARK: 注册画笔
    @discardableResult
    open func registerBrush<T:MetalBrush>(name: String? = nil , from data : Data) throws ->T{
        let texture = try makeTexture(with: data, id: name)
        let brush = T(name: name, textureId: texture.id, target: self)
        registerBrushs.append(brush)
        return brush
    }
    @discardableResult
    open func registerBrush<T:MetalBrush>(name: String? = nil, from url : URL) throws ->T{
        let data = try Data(contentsOf: url)
        return try registerBrush(name: name, from: data)
    }
    
    open func registerBrush<T:MetalBrush>(name: String? = nil, textureId : String? = nil) throws ->T{
        let brush = T(name: name, textureId: textureId, target: self)
        registerBrushs.append(brush)
        return brush
    }
    
    // MARK: 创建纹理
    @discardableResult
    override func makeTexture(with data: Data, id: String? = nil) throws -> MetalTexture {
        if let id = id , let exist = findTexture(by: id) {
            return exist
        }
        let texture = try super.makeTexture(with: data, id: id)
        textures.append(texture)
        return texture
    }
    
    open func findTexture(by id : String) ->MetalTexture?{
        return textures.first(where: {$0.id == id })
    }
    
    open func findBrush(by name : String) ->MetalBrush?{
        return registerBrushs.first(where: { $0.name == name })
    }
    
    //MARK: zoom &scal
    open var scale : CGFloat {
        get{
            return screenRender?.scale ?? 1
        }set{
            screenRender?.scale = newValue
        }
    }
    
    open var zoom : CGFloat {
        get{
            return screenRender?.zoom ?? 1
        }set{
            screenRender?.zoom = newValue
        }
    }
    
    open var contentOffset : CGPoint{
        get{
            return screenRender?.contentOffset ?? .zero
        }set{
            screenRender?.contentOffset = newValue
        }
    }
    
    override func setup() {
        super.setup()
        
        defaultBrush = MetalBrush(name: "default brush", textureId: nil, target: self)
        currentBrush = defaultBrush
        
        
        printer = MetalPrinter(name: "default printer", textureId: nil, target: self)
        
        data = MetalCanvasData()
    }
    // 截屏
    open func snapshort()->UIImage?{
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, contentScaleFactor)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func clear(display: Bool = true) {
        super.clear()
        
        if display {
            data.appendClearAction()
        }
    }
    private func pushPoint(_ point : CGPoint , to bezier : MetalBezierGenerator , force : CGFloat , isend : Bool = false){
        
    }
    // MARK:render
    open func render(lines:[MetalLine]){
        data.append(lines: lines, with: currentBrush)
        MetalLineStripe(lines: lines, brush: currentBrush).drawSelf(on: screenRender)
        screenRender?.commitCommand()
    }
    open func renderTap(at point : CGPoint , to : CGPoint? = nil){
        guard renderingDelegate?.canvas(self, shouldRenderTapAt: point) ?? true else { return }
        
        let brush = defaultBrush!
        let lines = brush.makeLine(from: point, to: to ?? point)
        render(lines: lines)
    }
    
    open func renderChartlet(at point : CGPoint , size : CGSize , textureId: String,rotation : CGFloat = 0.0 ){
        #warning("chartlet")
        let chartlet = MetalChartlet( )
    }
    
}
