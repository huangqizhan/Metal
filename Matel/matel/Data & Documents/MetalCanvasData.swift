//
//  CanvasData.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/11.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

public protocol MetalCanvasElement : Codable{
    var index : Int {get set}
    func drawSelf(on target: MetalRenderTarget?)
}

public struct MetalClearAction : MetalCanvasElement {
    
    public var index: Int = 0
    public func drawSelf(on target: MetalRenderTarget?) {
        target?.clear()
    }
}
/// 画布数据 （线条 / 图片 ）
open class MetalCanvasData  {
    open var clearedElements : [[MetalCanvasElement]] = []
    open var elements : [MetalCanvasElement] = []
    
    open var currentElement : MetalCanvasElement?
    final var dataObserves = MetalDataObservePool()
    private(set) var undoArray : [MetalCanvasElement] = []
    
    open func append(lines:[MetalLine],with brush : MetalBrush){
        guard lines.count > 0 else { return }
        
        if let linestripe = currentElement as? MetalLineStripe , linestripe.brush === brush {
            linestripe.append(lines: lines)
        }else{
            finishCurrentElement()
            
            let lineStrip = MetalLineStripe(lines: lines, brush: brush)
            currentElement = lineStrip
            undoArray.removeAll()
            
            dataObserves.lineStrip(lineStrip, didBeginOn: self)
        }
    }
    /// add a chartlet to elements
    open func append(chartlet: MetalChartlet) {
        finishCurrentElement()
        chartlet.index = lastElementIndex + 1
        elements.append(chartlet)
        undoArray.removeAll()
        
        dataObserves.element(chartlet, didFinishOn: self)
//        h_onElementFinish?(self)
    }
    
    open var lastElementIndex: Int {
        return elements.last?.index ?? 0
    }
    
    open func finishCurrentElement() {
        guard var element = currentElement else {
            return
        }
        element.index = lastElementIndex + 1
        elements.append(element)
        currentElement = nil
        undoArray.removeAll()
        
        dataObserves.element(element, didFinishOn: self)
//        h_onElementFinish?(self)
    }
    
    open func appendClearAction() {
        finishCurrentElement()
        
        guard elements.count > 0 else {
            return
        }
        clearedElements.append(elements)
        elements.removeAll()
        undoArray.removeAll()
        
        dataObserves.dataDidClear(self)
    }
    
    // MARK: - Undo & Redo
     public var canRedo: Bool {
         return undoArray.count > 0
     }
     
     public var canUndo: Bool {
         return elements.count > 0 || clearedElements.count > 0
     }
    
    internal func undo() -> Bool {
        finishCurrentElement()
        
        if let last = elements.last {
            undoArray.append(last)
            elements.removeLast()
        } else if let lastCleared = clearedElements.last {
            undoArray.append(MetalClearAction())
            elements = lastCleared
            clearedElements.removeLast()
        } else {
            return false
        }
        dataObserves.dataDidUndo(self)
//        h_onUndo?(self)
        return true
    }
    internal func redo()->Bool {
        guard currentElement == nil , let last =  undoArray.last else {
            return false
        }
        
        if let _ = last as? MetalClearAction {
            clearedElements.append(elements)
            elements.removeAll()
        }else{
            elements.append(last)
        }
        undoArray.removeLast()
        dataObserves.dataDidRedo(self)
        return true
    }
    open func addObserve(_ observe : MetalDataObserver){
        dataObserves.clean()
        dataObserves.addObserve(observe: observe)
    }
}

