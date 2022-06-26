//
//  BrokenRender.swift
//  KLine-Chart
//
//  Created by hjs on 2022/6/26.
//  Copyright © 2022 hjs. All rights reserved.
//

import UIKit

protocol DrawRendererInterface  {
    var shapePaths: [UIBezierPath] { get }
  
    func draw(context: CGContext, isActive: Bool, points: [CGPoint])
    
}


class BrokenRender: DrawRendererInterface {
    
    private var points: [CGPoint] = []
    
    var shapePaths: [UIBezierPath] {
        var paths: [UIBezierPath] = []
        for idx in 0..<points.count {
            let point = points[idx]
            let lineWidth: CGFloat = 10
            if idx > 0 {
                let prePoint = points[idx - 1]
                let xspacing = point.x - prePoint.x
                let yspacing = point.y - prePoint.y
                let l = sqrt(xspacing * xspacing + yspacing * yspacing)
                let proportion = (lineWidth * 0.5) / l
                let point1 = CGPoint(x: prePoint.x - proportion * yspacing, y: prePoint.y + proportion * xspacing)
                let point2 = CGPoint(x: prePoint.x + proportion * yspacing, y: prePoint.y - proportion * xspacing)
                let point3 = CGPoint(x: point.x + proportion * yspacing, y: point.y - proportion * xspacing)
                let point4 = CGPoint(x: point.x - proportion * yspacing, y: point.y + proportion * xspacing)
                let path = UIBezierPath()
                path.move(to: point1)
                path.addLine(to: point2)
                path.addLine(to: point3)
                path.addLine(to: point4)
                path.close()
                paths.append(path)
            }
        }
        return paths
    }
    
    
    func draw(context: CGContext, isActive: Bool, points: [CGPoint]) {
        self.points = points
        guard points.count > 0 else { return }
        for idx in 0..<points.count {
            let point = points[idx]
            context.setLineWidth(1)
            context.setStrokeColor(UIColor.white.cgColor)
            if idx > 0 {
                context.drawPath(using: .stroke)
                context.move(to: points[idx - 1])
                context.addLine(to: point)
                context.drawPath(using: CGPathDrawingMode.stroke)
            }
        }
        if !isActive { return }
        for idx in 0..<points.count {
            let point = points[idx]
            context.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            context.addArc(center: CGPoint(x: point.x, y: point.y), radius: 6, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context.drawPath(using: CGPathDrawingMode.fill)

            context.setFillColor(UIColor.white.withAlphaComponent(1).cgColor)
            context.addArc(center: CGPoint(x: point.x, y: point.y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context.drawPath(using: CGPathDrawingMode.fill)
        }
    }

}

class RectRender: DrawRendererInterface {
    
    private var points: [CGPoint] = []
    
    var shapePaths: [UIBezierPath] {
        if points.count >= 2 {
            let point1 = points[0]
            let point3 = points[1]
            let point2 = CGPoint(x: point1.x, y: point3.y)
            let point4 = CGPoint(x: point3.x, y: point1.y)
            let path = UIBezierPath()
            path.move(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.close()
           return [path]
        }
        return []
    }
    
    func draw(context: CGContext, isActive: Bool, points: [CGPoint]) {
        self.points = points
        guard points.count > 0 else { return }
        if points.count >= 2 {
            let point1 = points[0]
            let point3 = points[1]
            let point2 = CGPoint(x: point1.x, y: point3.y)
            let point4 = CGPoint(x: point3.x, y: point1.y)
            context.setStrokeColor(UIColor.white.cgColor)
            let path = UIBezierPath()
            path.move(to: point1)
            path.addLine(to: point2)
            path.addLine(to: point3)
            path.addLine(to: point4)
            path.close()
            path.stroke()
            
        }
        if !isActive { return }
        for idx in 0..<points.count {
            let point = points[idx]
            context.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            context.addArc(center: CGPoint(x: point.x, y: point.y), radius: 6, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context.drawPath(using: CGPathDrawingMode.fill)

            context.setFillColor(UIColor.white.withAlphaComponent(1).cgColor)
            context.addArc(center: CGPoint(x: point.x, y: point.y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
            context.drawPath(using: CGPathDrawingMode.fill)
        }
    }
    
    
}
