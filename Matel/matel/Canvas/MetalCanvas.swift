//
//  Cancas.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/7.
//  Copyright © 2020 黄麒展. All rights reserved.
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
    
    private var bezierGenerator = MetalBezierGenerator()
    
    private var lastRenderedPan : MetalPan?
    
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }
    
    open func resetData(redraw: Bool = true){
        let oldData = data!
        let newData = MetalCanvasData()
        newData.dataObserves = data.dataObserves
        data = newData
        if redraw {
            self.redraw()
        }
        data.dataObserves.data(oldData, didResetTo: data)
    }
    
    public func undo(){
        if let data = data , data.undo(){
            redraw()
        }
    }
    public func redo(){
        if let data = data , data.redo() {
            redraw()
        }
    }
    
    open func redraw(on target : MetalRenderTarget? = nil ){
        guard let targrt = target ?? screenRender else { return }
        data.finishCurrentElement()
        
        target?.updateBuffer(width: drawableSize)
        target?.clear()
        data.elements.forEach({ $0.drawSelf(on: targrt) })
        target?.commitCommand()
        actionObserves.canvas(self, didRedrawOn: targrt)
    }
    
    private func pushPoint(_ point : CGPoint , to bezier : MetalBezierGenerator , force : CGFloat , isEnd : Bool = false) {
        var lines : [MetalLine] = []
        let vertecies = bezier.pushPoint(point)
        guard vertecies.count >= 2 else {
            return
        }
        var lastPan = lastRenderedPan ?? MetalPan(point: vertecies[0], force: force)
        let deltaForce = (force - (lastRenderedPan?.force ?? force)) / CGFloat(vertecies.count)
        for i in 1 ..< vertecies.count {
            let p = vertecies[i]
            let pointStep = currentBrush.pointStep
            if  // end point of line
                (isEnd && i == vertecies.count - 1) ||
                    // ignore step
                    pointStep <= 1 ||
                    // distance larger than step
                    (pointStep > 1 && lastPan.point.distance(to: p) >= pointStep)
            {
                let force = lastPan.force + deltaForce
                let pan = MetalPan(point: p, force: force)
                let line = currentBrush.makeLine(from: lastPan, to: pan)
                lines.append(contentsOf: line)
                lastPan = pan
                lastRenderedPan = pan
            }
        }
        render(lines: lines)
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
        let chartlet = MetalChartlet()
    }
    
    // MARK: TOUCHES
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = firstAvaliableTouch(from: touches)  else { return }
        let pan = MetalPan(touch: touch, on: self)
        lastRenderedPan = pan
        guard renderingDelegate?.canvas(self, shouldBeginLineAt: pan.point, force: pan.force) ?? true else { return }
        bezierGenerator.begin(with: pan.point)
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObserves.canvas(self, didBeginLineAt: pan.point, force: pan.force)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = firstAvaliableTouch(from: touches) else { return }
        guard bezierGenerator.points.count > 0 else { return }
        let pan = MetalPan(touch: touch, on: self)
        guard pan.point != lastRenderedPan?.point else { return }
        pushPoint(pan.point, to: bezierGenerator, force: pan.force)
        actionObserves.canvas(self, didMoveLineTo: pan.point, force: pan.force)
        
//        print("move x : \(pan.point.x) y : \(pan.point.y)")

    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = firstAvaliableTouch(from: touches) else { return }
        
        defer {
            bezierGenerator.finish()
            lastRenderedPan = nil
            data.finishCurrentElement()
        }
        
        let pan = MetalPan(touch: touch, on: self)
        let count = bezierGenerator.points.count
        
        if count >= 3 {
            pushPoint(pan.point, to: bezierGenerator, force: pan.force, isEnd: true)
        }else if count > 0{
            renderTap(at: bezierGenerator.points.first!, to: bezierGenerator.points.last!)
        }
        
        let unfinishlines = currentBrush.finishLineStripe(at: MetalPan(point: pan.point, force: pan.force))
        if unfinishlines.count > 0 {
            render(lines: unfinishlines)
        }
        actionObserves.canvas(self, didFinishLineAt: pan.point, force: pan.force)
    }
    
    private func firstAvaliableTouch(from touches : Set<UITouch>) -> UITouch? {
        if #available(iOS 9.1, *) , isPencilMode{
            return touches.first { (t) -> Bool in
                return t.type == .pencil
            }
        }else{
            return touches.first
        }
    }
    
    
}
