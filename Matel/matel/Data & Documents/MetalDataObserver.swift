//
//  MetalDataObserver.swift
//  Matel
//
//  Created by 8km_mac_mini on 2020/5/11.
//  Copyright © 2020 8km_mac_mini. All rights reserved.
//

import UIKit

public protocol MetalDataObserver : AnyObject {
    /// 线条开始绘制
    func lineStrip(_ strip: MetalLineStripe, didBeginOn data: MetalCanvasData)
    /// 每次绘制结束
    func element(_ element: MetalCanvasElement, didFinishOn data: MetalCanvasData)
    /// 清空花瓣数据
    func dataDidClear(_ data: MetalCanvasData)
    /// undo
    func dataDidUndo(_ data: MetalCanvasData)
    /// redo
    func dataDidRedo(_ data: MetalCanvasData)
    /// called when data of canvas have been reseted
    func data(_ data: MetalCanvasData, didResetTo newData: MetalCanvasData)
    
}


extension MetalDataObserver{
    /// 线条开始绘制
    func lineStrip(_ strip: MetalLineStripe, didBeginOn data: MetalCanvasData){}
    /// 每次绘制结束
    func element(_ element: MetalCanvasElement, didFinishOn data: MetalCanvasData){}
    /// 清空花瓣数据
    func dataDidClear(_ data: MetalCanvasData){}
    /// undo
    func dataDidUndo(_ data: MetalCanvasData){}
    /// redo
    func dataDidRedo(_ data: MetalCanvasData){}
    /// called when data of canvas have been reseted
    func data(_ data: MetalCanvasData, didResetTo newData: MetalCanvasData){}
}

final class MetalDataObservePool : MetalWeakObjectsPool {
    public func addObserve(observe : MetalDataObserver)  {
        super.addObjec(object: observe)
    }
    
    public var aliveObserves : [MetalDataObserver]{
        return aliveObjects.compactMap({ $0 as? MetalDataObserver })
    }
}

extension MetalDataObservePool{
    /// 线条开始绘制
    func lineStrip(_ strip: MetalLineStripe, didBeginOn data: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.lineStrip(strip, didBeginOn: data)
        }
    }
    /// 每次绘制结束
    func element(_ element: MetalCanvasElement, didFinishOn data: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.element(element, didFinishOn: data)
        }
    }
    /// 清空花瓣数据
    func dataDidClear(_ data: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.dataDidClear(data)
        }
    }
    /// undo
    func dataDidUndo(_ data: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.dataDidUndo(data)
        }
    }
    /// redo
    func dataDidRedo(_ data: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.dataDidRedo(data)
        }
    }
    /// called when data of canvas have been reseted
    func data(_ data: MetalCanvasData, didResetTo newData: MetalCanvasData){
        aliveObserves.forEach { (observe: MetalDataObserver) in
            observe.data(data, didResetTo: newData)
        }
    }
}

