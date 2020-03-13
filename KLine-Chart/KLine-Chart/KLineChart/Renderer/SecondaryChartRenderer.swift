//
//  SecondaryChartRenderer.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class SecondaryChartRenderer: BaseChartRenderer {

    var mMACDWidth: CGFloat = 5
    var state: SecondaryState = .none
    
    init(maxValue: CGFloat,minValue: CGFloat,chartRect: CGRect,candleWidth: CGFloat,topPadding: CGFloat,state: SecondaryState) {
           super.init(maxValue: maxValue, minValue: minValue, chartRect: chartRect, candleWidth: candleWidth,topPadding: topPadding)
            self.state = state
       }
    
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
    }
    
    override func drawChart(context: CGContext, lastPoint: KLineModel?, curPoint: KLineModel, curX: CGFloat) {
        if state == SecondaryState.macd {
            drawMACD(context: context, lastPoint: lastPoint, curPoint: curPoint, curX: curX)
        } else if (state == SecondaryState.kdj) {
            if let _lastPoint = lastPoint {
                if curPoint.k != 0 {
                    drawLine(context: context, lastValue: _lastPoint.k, curValue: curPoint.k, curX: curX, color: ChartColors.kColor)
                }
                if curPoint.d != 0 {
                    drawLine(context: context, lastValue: _lastPoint.d, curValue: curPoint.d, curX: curX, color: ChartColors.dColor)
                }
                if curPoint.j != 0 {
                    drawLine(context: context, lastValue: _lastPoint.j, curValue: curPoint.j, curX: curX, color: ChartColors.jColor)
                }
            }
        } else if (state == SecondaryState.rsi) {
             if let _lastPoint = lastPoint {
                if curPoint.rsi != 0 {
                    drawLine(context: context, lastValue: _lastPoint.rsi, curValue: curPoint.rsi, curX: curX, color: ChartColors.rsiColor)
                }
            }
        } else if (state == SecondaryState.wr) {
             if let _lastPoint = lastPoint {
                if curPoint.r != 0 {
                    drawLine(context: context, lastValue: _lastPoint.r, curValue: curPoint.r, curX: curX, color: ChartColors.wrColor)
                }
            }
        }
    }
    
    override func drawTopText(context: CGContext, curPoint: KLineModel) {
        let topAttributeText = NSMutableAttributedString()
        switch state {
        case .macd:
            let valueAttr = NSAttributedString(string: "MACD(12,26,9)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.yAxisTextColor])
            topAttributeText.append(valueAttr)
            if curPoint.macd != 0 {
                let value  = String(format: "%.2f", curPoint.macd)
                let valueAttr = NSAttributedString(string: "MACD:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.macdColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.dif != 0 {
                let value  = String(format: "%.2f", curPoint.dif)
                let valueAttr = NSAttributedString(string: "DIF:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.difColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.dea != 0 {
                let value  = String(format: "%.2f", curPoint.dea)
                let valueAttr = NSAttributedString(string: "DEA:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.deaColor])
                topAttributeText.append(valueAttr)
            }
        case .rsi:
            let value  = String(format: "%.2f", curPoint.rsi)
            let valueAttr = NSAttributedString(string: "RSI(14):\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.rsiColor])
            topAttributeText.append(valueAttr)
        case .wr:
            let value  = String(format: "%.2f", curPoint.r)
            let valueAttr = NSAttributedString(string: "WR(14):\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.wrColor])
            topAttributeText.append(valueAttr)
        case .kdj:
            let valueAttr = NSAttributedString(string: "KDJ(14,1,3)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.yAxisTextColor])
            topAttributeText.append(valueAttr)
            if curPoint.k != 0 {
                let value  = String(format: "%.2f", curPoint.macd)
                let valueAttr = NSAttributedString(string: "K:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.kColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.d != 0 {
                let value  = String(format: "%.2f", curPoint.d)
                let valueAttr = NSAttributedString(string: "D:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.dColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.j != 0 {
                let value  = String(format: "%.2f", curPoint.j)
                let valueAttr = NSAttributedString(string: "J:\(value)    ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor: ChartColors.jColor])
                topAttributeText.append(valueAttr)
            }
        case .none:
            break
        }
        topAttributeText.draw(at: CGPoint(x: 5, y: chartRect.minY))
    }
    
    override func drawRightText(context: CGContext, gridRows: Int, gridColums: Int) {
        let text = volFormat(value: maxValue)
        let rect = calculateTextRect(text: text, fontSize: ChartStyle.reightTextSize)
        (text as NSString).draw(at: CGPoint(x: chartRect.width - rect.width, y: chartRect.minY), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.reightTextSize),NSAttributedString.Key.foregroundColor: ChartColors.reightTextColor])
    }
    
    func drawMACD(context: CGContext, lastPoint: KLineModel?, curPoint: KLineModel, curX: CGFloat) {
        let maxdY = getY(curPoint.macd)
        let zeroy = getY(0)
        if curPoint.macd > 0 {
            context.setStrokeColor(ChartColors.upColor.cgColor)
        } else {
            context.setStrokeColor(ChartColors.dnColor.cgColor)
        }
        context.setLineWidth(mMACDWidth)
        context.move(to: CGPoint(x:curX, y: maxdY))
        context.addLine(to: CGPoint(x: curX, y: zeroy))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        if let _lastPoint = lastPoint {
            if curPoint.dif != 0 {
                drawLine(context: context, lastValue: _lastPoint.dif, curValue: curPoint.dif, curX: curX, color: ChartColors.difColor)
            }
            if curPoint.dea != 0 {
                 drawLine(context: context, lastValue: _lastPoint.dea, curValue: curPoint.dea, curX: curX, color: ChartColors.deaColor)
            }
        }
    }
    
    
    
}
