//
//  KDotNode.swift
//  KLine-Chart
//
//  Created by hjs on 2022/6/26.
//  Copyright © 2022 hjs. All rights reserved.
//

import UIKit

enum DarwLineType {
    case broken
    case rect
}


enum DarwDargType {
    case point
    case shape
    case none
}

class DarwLineInfo {
    var type: DarwLineType = .broken
    var pointNum: Int = 2
}




class KGraphicsModel {
    var renderer: DrawRendererInterface = RectRender()
    
    var isActive: Bool = true
    var isComplete: Bool = true
    
    var info = DarwLineInfo()
    
    var points: [CGPoint] = []
   
    var orginPoints: [CGPoint] = []
    
    var shapePaths: [UIBezierPath] = []
    
    var dargType: DarwDargType = .none
    
    // 开始拖动的point，用来计算拖动的距离
    var startPoint: CGPoint = CGPoint.zero
    // 拖动的第几个点
    var dargIndex: Int?
   // 当前拖动的点的起始位置
    var dargPoint: CGPoint = CGPoint.zero
    
    func draw(context: CGContext) {
        renderer.draw(context: context, isActive: isActive, points: points)
    }
    
    func addPoint(_ point: CGPoint) {
        if points.count < info.pointNum {
            points.append(point)
        }
        isComplete = points.count == info.pointNum
    }
    
    func canDargType() -> DarwDargType {
        if let dargIndex = canDargPoint() {
            self.dargType = .point
            self.dargIndex = dargIndex
            self.dargPoint = self.points[dargIndex]
            self.orginPoints = points
        } else if canDargShape() {
            self.dargType = .shape
            self.orginPoints = points
        } else {
            self.dargType = .none
            self.orginPoints = []
            self.dargIndex = nil
        }
        return self.dargType
        
    }
    
    func canDargPoint() -> Int? {
        for (idx, point) in points.enumerated() {
           let rect = pointToRect(point: point)
            print("rect-----\(rect) ---- \(startPoint)")
            if rect.contains(startPoint) {
                return idx
            }
        }
        return nil
    }
    
   private func pointToRect(point: CGPoint) -> CGRect {
        let r: CGFloat = 4
        return CGRect(x: point.x - r , y: point.y - r, width: r * 2, height: r * 2)
    }
    
   private func canDargShape() -> Bool {
       for (_, path) in renderer.shapePaths.enumerated() {
            if path.contains(startPoint) {
                return true
            }
        }
        return false
    }
    
    private func move(movX: CGFloat, movY: CGFloat) {
       points = orginPoints.map {
            return CGPoint(x: $0.x + movX, y: $0.y + movY)
        }
    }
    
    func move(point: CGPoint) {
        let movX = point.x - startPoint.x
        let movY = point.y - startPoint.y
        switch dargType {
        case .point:
            guard let index = self.dargIndex else { return }
            let newPoint = CGPoint(x: dargPoint.x + movX, y: dargPoint.y + movY)
            self.points.insert(newPoint, at: index)
            self.points.remove(at: index + 1)
        case .shape:
            move(movX: movX, movY: movY)
        case .none:
            break
        }
    }
}
