//
//  MainChartRenderer.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class MainChartRenderer: BaseChartRenderer {

    var contentPadding: CGFloat = 20
    
    var isLine: Bool = false
    var state: MainState = .none
    
    init(maxValue: CGFloat,minValue: CGFloat,chartRect: CGRect,candleWidth: CGFloat,topPadding: CGFloat,isLine: Bool,state: MainState) {
        super.init(maxValue: maxValue, minValue: minValue, chartRect: chartRect, candleWidth: candleWidth,topPadding: topPadding)
        self.isLine = isLine
        self.state = state
        let diff = maxValue - minValue
        print(chartRect.height)
        let newScalY = (chartRect.height - contentPadding) / diff
        let newDiff = chartRect.height / newScalY
        let value = (newDiff - diff) / 2
        if newDiff > diff {
            scaleY = newScalY
            self.maxValue += value
            self.minValue -= value
        }
    }
    
    override func drawGrid(context: CGContext, gridRows: Int, gridColums: Int) {
        context.setStrokeColor(ChartColors.gridColor.cgColor)
        context.setLineWidth(0.5)
        let columsSpace = chartRect.width / CGFloat(gridColums)
        for index in 0..<gridColums {
            context.move(to: CGPoint(x: CGFloat(index) * columsSpace, y: 0))
            context.addLine(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.maxY))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
         let rowSpace = chartRect.height / CGFloat(gridRows)
        for index in 0...gridRows {
            context.move(to: CGPoint(x: 0, y: CGFloat(index) * rowSpace + ChartStyle.topPadding))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: CGFloat(index) * rowSpace + ChartStyle.topPadding))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    }
    
    
    override func drawChart(context: CGContext, lastPoint: KLineModel?, curPoint: KLineModel, curX: CGFloat) {
        if(!isLine) {
            drawCandle(context: context, curPoint: curPoint, curX: curX)
        }
        if let _lastPoint = lastPoint {
            if(isLine) {
                drawKLine(context: context, lastValue: _lastPoint.close, curValue: curPoint.close, curX: curX)
            } else if state == MainState.ma {
                drawMaLine(context: context, lastPoint: _lastPoint, curPoint: curPoint, curX: curX)
            } else if state == MainState.boll {
                drawBOLL(context: context, lastPoint: _lastPoint, curPoint: curPoint, curX: curX)
            }
        }
    }
    
    func drawKLine(context: CGContext,lastValue: CGFloat, curValue: CGFloat, curX: CGFloat) {
       let x1 = curX
       let y1 = getY(curValue)
       let x2 = curX + candleWidth + ChartStyle.canldeMargin
       let y2 = getY(lastValue)
        context.setLineWidth(1)
        context.setStrokeColor(ChartColors.kLineColor.cgColor)
        context.move(to: CGPoint(x: x1, y: y1))
        context.addCurve(to: CGPoint(x: x2, y: y2), control1: CGPoint(x: (x1 + x2) / 2, y: y1), control2: CGPoint(x: (x1 + x2) / 2, y: y2))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        //创建并设置路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x1, y: chartRect.maxY))
        path.addLine(to: CGPoint(x: x1, y: y1))
        path.addCurve(to: CGPoint(x: x2, y: y2), control1: CGPoint(x: (x1 + x2) / 2, y: y1), control2: CGPoint(x: (x1 + x2) / 2, y: y2))
        path.addLine(to: CGPoint(x: x2, y: chartRect.maxY))
        path.closeSubpath()
        //添加路径到图形上下文
        context.addPath(path)
        context.clip()
        
        //使用rgb颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //颜色数组（这里使用三组颜色作为渐变）fc6820
        let compoents:[CGFloat] = [0x4C/255, 0x86/255, 0xCD/255, 0x55/255,
                                   0x00/255, 0x00/255, 0x00/255, 0]
        //没组颜色所在位置（范围0~1)
        let locations:[CGFloat] = [0,1]
        //生成渐变色（count参数表示渐变个数）
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: compoents,
                                  locations: locations, count: locations.count)!
         
        //渐变开始位置
        let start = CGPoint(x: (x1 + x2) / 2, y: chartRect.minY)
        //渐变结束位置
        let end = CGPoint(x: (x1 + x2) / 2, y: chartRect.maxY)
        //绘制渐变
        context.drawLinearGradient(gradient, start: start, end: end,
                                   options: .drawsAfterEndLocation)
        context.resetClip()

        
    }
    
    func drawMaLine(context: CGContext,lastPoint: KLineModel, curPoint: KLineModel,curX: CGFloat) {
        if(curPoint.MA5Price != 0) {
            drawLine(context: context, lastValue: lastPoint.MA5Price, curValue: curPoint.MA5Price, curX: curX, color: ChartColors.ma5Color)
        }
        if(curPoint.MA10Price != 0) {
            drawLine(context: context, lastValue: lastPoint.MA10Price, curValue: curPoint.MA10Price, curX: curX, color: ChartColors.ma10Color)
        }
        if(curPoint.MA30Price != 0) {
            drawLine(context: context, lastValue: lastPoint.MA30Price, curValue: curPoint.MA30Price, curX: curX, color: ChartColors.ma30Color)
        }
    }
    
    func drawBOLL(context: CGContext,lastPoint: KLineModel, curPoint: KLineModel,curX: CGFloat) {
        if(curPoint.up != 0) {
            drawLine(context: context, lastValue: lastPoint.up, curValue: curPoint.up, curX: curX, color: ChartColors.ma5Color)
        }
        if(curPoint.mb != 0) {
            drawLine(context: context, lastValue: lastPoint.mb, curValue: curPoint.mb, curX: curX, color: ChartColors.ma10Color)
        }
        if(curPoint.dn != 0) {
            drawLine(context: context, lastValue: lastPoint.dn, curValue: curPoint.dn, curX: curX, color: ChartColors.ma30Color)
        }
    }
    
    func drawCandle(context: CGContext, curPoint: KLineModel,curX: CGFloat) {
        let high = getY(curPoint.high)
        let low = getY(curPoint.low)
        let open = getY(curPoint.open)
        let close = getY(curPoint.close)
         var  color = ChartColors.dnColor
        if open > close {
           color = ChartColors.upColor
        }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(ChartStyle.candleLineWidth)
        context.move(to: CGPoint(x: curX , y: high))
        context.addLine(to: CGPoint(x: curX, y: low))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(candleWidth)
        context.move(to: CGPoint(x: curX, y: open))
        context.addLine(to: CGPoint(x: curX, y: close))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
    
    override func drawRightText(context: CGContext, gridRows: Int, gridColums: Int) {
        let rowSpace = chartRect.height / CGFloat(gridRows)
        for i in 0...gridRows {
            var  position: CGFloat = 0;
            position = CGFloat(gridRows - i) * rowSpace
            let value = position / scaleY + minValue
            let valueStr = String(format: "%.2f", value)
            let rect = calculateTextRect(text: valueStr, fontSize: ChartStyle.reightTextSize)
            var y: CGFloat = 0
            if i == 0 {
                y = getY(value)
            } else {
                y = getY(value) - rect.height
            }
            valueStr.draw(at: CGPoint(x: chartRect.width - rect.width, y: y), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.reightTextSize), NSAttributedString.Key.foregroundColor: ChartColors.reightTextColor])
        }
    }
    
    override func drawTopText(context: CGContext, curPoint: KLineModel) {
        let topAttributeText = NSMutableAttributedString()
        if curPoint.MA5Price != 0 {
            let ma5Price  = String(format: "%.2f", curPoint.MA5Price)
            let ma5Attr = NSAttributedString(string: "MA5:\(ma5Price)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.ma5Color])
            topAttributeText.append(ma5Attr)
        }
        if curPoint.MA10Price != 0 {
            let ma10Price  = String(format: "%.2f", curPoint.MA5Price)
            let ma10Attr = NSAttributedString(string: "MA10:\(ma10Price)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.ma10Color])
            topAttributeText.append(ma10Attr)
        }
        
        if curPoint.MA30Price != 0 {
            let ma30Price  = String(format: "%.2f", curPoint.MA5Price)
            let ma30Attr = NSAttributedString(string: "MA30:\(ma30Price)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.ma30Color])
            topAttributeText.append(ma30Attr)
        }
        topAttributeText.draw(at: CGPoint(x: 5, y: 6))
    }
    
    override func getY(_ value: CGFloat) -> CGFloat {
        return scaleY * (maxValue - value) + chartRect.minY
    }
  
    
}
