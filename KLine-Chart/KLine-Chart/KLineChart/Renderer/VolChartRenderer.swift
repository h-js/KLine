//
//  VolChartRenderer.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class VolChartRenderer: BaseChartRenderer {

    
    override func drawGrid(context: CGContext, gridRows: Int, gridColums: Int) {
        context.setStrokeColor(ChartColors.gridColor.cgColor)
        context.setLineWidth(0.5)
        let columsSpace = chartRect.width / CGFloat(gridColums)
        for index in 0..<gridColums {
            context.move(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.minY))
            context.addLine(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.maxY))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        context.move(to: CGPoint(x: 0, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        context.move(to: CGPoint(x: 0, y: chartRect.minY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.minY))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }

    override func drawChart(context: CGContext, lastPoint: KLineModel?, curPoint: KLineModel, curX: CGFloat) {
        drawVolChart(context: context, curPoint: curPoint, curX: curX)
        guard let _lastPoint = lastPoint else {
            return
        }
        if curPoint.MA5Volume != 0 {
            drawLine(context: context, lastValue: _lastPoint.MA5Volume, curValue: curPoint.MA5Volume, curX: curX, color: ChartColors.ma5Color)
        }
        if curPoint.MA10Volume != 0 {
            drawLine(context: context, lastValue: _lastPoint.MA10Volume, curValue: curPoint.MA10Volume, curX: curX, color: ChartColors.ma10Color)
        }
    }
    
    override func drawTopText(context: CGContext, curPoint: KLineModel) {
        let topAttributeText = NSMutableAttributedString()
       let vol = volFormat(value: curPoint.vol)
       let volAttr = NSAttributedString(string: "VOL:\(vol)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.volColor])
       topAttributeText.append(volAttr)
        
        let ma5 = volFormat(value: curPoint.MA5Volume)
        let ma5Attr = NSAttributedString(string: "MA5:\(ma5)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.ma5Color])
        topAttributeText.append(ma5Attr)
        
        let ma10 = volFormat(value: curPoint.MA10Volume)
        let ma10Attr = NSAttributedString(string: "MA10:\(ma10)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.ma10Color])
        topAttributeText.append(ma10Attr)
        topAttributeText.draw(at: CGPoint(x: 5, y: chartRect.minY))
    }
    
    override func drawRightText(context: CGContext, gridRows: Int, gridColums: Int) {
        let text = volFormat(value: maxValue)
        let rect = calculateTextRect(text: text, fontSize: ChartStyle.reightTextSize)
        (text as NSString).draw(at: CGPoint(x: chartRect.width - rect.width, y: chartRect.minY), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.reightTextSize),NSAttributedString.Key.foregroundColor: ChartColors.reightTextColor])
    }
    
    func drawVolChart(context: CGContext, curPoint: KLineModel, curX: CGFloat) {
        let top = getY(curPoint.vol)
        context.setLineWidth(candleWidth)
        if curPoint.close > curPoint.open {
            context.setStrokeColor(ChartColors.upColor.cgColor)
        } else {
             context.setStrokeColor(ChartColors.dnColor.cgColor)
        }
        context.move(to: CGPoint(x: curX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: curX, y: top))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
    
}
