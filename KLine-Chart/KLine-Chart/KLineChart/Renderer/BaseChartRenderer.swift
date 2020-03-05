//
//  BaseChartRenderer.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class BaseChartRenderer {
    
    var maxValue: CGFloat!
    var minValue: CGFloat!
    var chartRect: CGRect!
    var candleWidth: CGFloat!
    var scaleY: CGFloat!
    var topPadding: CGFloat!
    
    init(maxValue: CGFloat,minValue: CGFloat,chartRect: CGRect,candleWidth: CGFloat,topPadding: CGFloat) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.chartRect = chartRect
        self.candleWidth = candleWidth
        self.topPadding = topPadding
        scaleY = (chartRect.height - topPadding) / (maxValue - minValue)
    }
    
    //画网格
    func drawGrid(context: CGContext, gridRows: Int , gridColums: Int) {
        
    }
    
    //画右边的文字
    func drawRightText(context: CGContext, gridRows: Int , gridColums: Int) {
        
    }
    
    func drawTopText(context: CGContext,curPoint: KLineModel) {
        
    }
    
    //绘制渐变背景
    func drawBg(context: CGContext) {
        context.clip(to: chartRect)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let compoents:[CGFloat] = [0x0E/255, 0x19/255, 0x25/255, 1,
        0x0E/255, 0x20/255, 0x34/255, 1]
        let locations:[CGFloat] = [0,1]
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: compoents, locations: locations, count: locations.count)
        //渐变开始位置
        let start = CGPoint(x: chartRect.width / 2, y: chartRect.minY)
        //渐变结束位置
        let end = CGPoint(x: chartRect.width / 2 , y: chartRect.maxY)
        context.drawLinearGradient(gradient!, start: start, end: end, options: .drawsBeforeStartLocation)
        context.resetClip()
    }
    
    
    //画图表
    func drawChart(context: CGContext, lastPoint: KLineModel?, curPoint: KLineModel, curX: CGFloat) {
        
    }
    
    func drawLine(context: CGContext, lastValue: CGFloat, curValue: CGFloat, curX: CGFloat, color: UIColor) {
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(1)
        let x1 = curX
        let y1 = getY(curValue)
        let x2 = curX + candleWidth + ChartStyle.canldeMargin
        let y2 = getY(lastValue)
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
    func getY(_ value: CGFloat) -> CGFloat {
        return scaleY * (maxValue - value) + chartRect.minY + topPadding
    }
}

