//
//  MetalActionIObserve.swift
//  Matel
//
//  Created by 黄麒展 on 2020/5/11.
//  Copyright © 2020 黄麒展. All rights reserved.
//

import UIKit

/// Delegate for rendering
public protocol MetalRenderingDelegate: AnyObject {
    func canvas(_ canvas: MetalCanvas, shouldRenderTapAt point: CGPoint) -> Bool
    func canvas(_ canvas: MetalCanvas, shouldRenderChartlet chartlet: MetalChartlet) -> Bool
    // if returns false, the whole line strip will be skiped
    func canvas(_ canvas: MetalCanvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool
}

public extension MetalRenderingDelegate {
    func canvas(_ canvas: MetalCanvas, shouldRenderTapAt point: CGPoint) -> Bool {
        return true
    }
    
    func canvas(_ canvas: MetalCanvas, shouldRenderChartlet chartlet: MetalChartlet) -> Bool {
        return true
    }
    
    func canvas(_ canvas: MetalCanvas, shouldBeginLineAt point: CGPoint, force: CGFloat) -> Bool {
        return true
    }
}

/// Observer for canvas actions
public protocol MetalActionObserver: AnyObject {
    
    func canvas(_ canvas: MetalCanvas, didRenderTapAt point: CGPoint)
    func canvas(_ canvas: MetalCanvas, didRenderChartlet chartlet: MetalChartlet)

    func canvas(_ canvas: MetalCanvas, didBeginLineAt point: CGPoint, force: CGFloat)
    func canvas(_ canvas: MetalCanvas, didMoveLineTo point: CGPoint, force: CGFloat)
    func canvas(_ canvas: MetalCanvas, didFinishLineAt point: CGPoint, force: CGFloat)
    
    func canvas(_ canvas: MetalCanvas, didRedrawOn target: MetalRenderTarget)
    
    // Only called on ScrollableCanvas
    
//    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat)
//    func canvasDidScroll(_ canvas: ScrollableCanvas)
}

/// Observer for canvas actions
public extension MetalActionObserver {
    
    func canvas(_ canvas: MetalCanvas, didRenderTapAt point: CGPoint) {}
    func canvas(_ canvas: MetalCanvas, didRenderChartlet chartlet: MetalChartlet) {}
    
    func canvas(_ canvas: MetalCanvas, didBeginLineAt point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: MetalCanvas, didMoveLineTo point: CGPoint, force: CGFloat) {}
    func canvas(_ canvas: MetalCanvas, didFinishLineAt point: CGPoint, force: CGFloat) {}
    
    func canvas(_ canvas: MetalCanvas, didRedrawOn target: MetalRenderTarget) {}
    
    // Only called on ScrollableCanvas
    
//    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat) {}
//    func canvasDidScroll(_ canvas: ScrollableCanvas) {}
}

final class MetalActionObserverPool: MetalWeakObjectsPool {
    
    func addObserver(_ observer: MetalActionObserver) {
        super.addObjec(object: observer)
    }
    
    // return unreleased objects
    var aliveObservers: [MetalActionObserver] {
        return aliveObjects.compactMap { $0 as? MetalActionObserver }
    }
}

extension MetalActionObserverPool : MetalActionObserver {
    
    func canvas(_ canvas: MetalCanvas, didRenderTapAt point: CGPoint) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderTapAt: point) }
    }
    func canvas(_ canvas: MetalCanvas, didRenderChartlet chartlet: MetalChartlet) {
        aliveObservers.forEach { $0.canvas(canvas, didRenderChartlet: chartlet) }
    }
    
    func canvas(_ canvas: MetalCanvas, didBeginLineAt point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didBeginLineAt: point, force: force) }
    }
    
    func canvas(_ canvas: MetalCanvas, didMoveLineTo point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didMoveLineTo: point, force: force) }
    }
    
    func canvas(_ canvas: MetalCanvas, didFinishLineAt point: CGPoint, force: CGFloat) {
        aliveObservers.forEach { $0.canvas(canvas, didFinishLineAt: point, force: force) }
    }

    func canvas(_ canvas: MetalCanvas, didRedrawOn target: MetalRenderTarget) {
        aliveObservers.forEach { $0.canvas(canvas, didRedrawOn: target) }
    }
    
    // Only called on ScrollableCanvas
    
//    func canvas(_ canvas: ScrollableCanvas, didZoomTo zoomLevel: CGFloat) {
//        aliveObservers.forEach { $0.canvas(canvas, didZoomTo: zoomLevel) }
//    }
//
//    func canvasDidScroll(_ canvas: ScrollableCanvas) {
//        aliveObservers.forEach { $0.canvasDidScroll(canvas) }
//    }
}
