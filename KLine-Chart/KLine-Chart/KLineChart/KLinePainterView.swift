//
//  KLineChartView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLinePainterView: UIView {
    
    var datas: [KLineModel] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var scrollX: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    //距离右边的距离
    var startX: CGFloat = 0
    var isLine = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var scaleX: CGFloat = 1.0 {
        didSet {
        self.candleWidth = scaleX * ChartStyle.candleWidth
        self.setNeedsDisplay()
        }
    }
    var isLongPress: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var longPressX: CGFloat = 0 
    
    
    var mainRect: CGRect!
    var volRect: CGRect?
    var secondaryRect: CGRect?
    var dateRect: CGRect!
    
    var mainState: MainState = .none {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var volState: VolState = .vol {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var secondaryState: SecondaryState = .none {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var displayHeight: CGFloat = 0
    
    var mainRenderer: MainChartRenderer!
    var volRenderer: VolChartRenderer?
    var seconderyRender: SecondaryChartRenderer?
    
    //需要绘制的开始和结束下标
    var startIndex: Int = 0
    var stopIndex: Int = 0
    
    var mMainMaxIndex: Int = 0
    var mMainMinIndex: Int = 0
    
    var mMainMaxValue: CGFloat = 0
    var mMainMinValue: CGFloat = CGFloat(MAXFLOAT)
    
    var mVolMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mVolMinValue: CGFloat = CGFloat(MAXFLOAT)
    
    var mSecondaryMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mSecondaryMinValue: CGFloat = CGFloat(MAXFLOAT)
    
    var mMainHighMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mMainLowMinValue: CGFloat = CGFloat(MAXFLOAT)
    
    var fromat: String = "yyyy-MM-dd"
    
    var showInfoBlock: ((KLineModel,Bool) -> Void)?
   
    var candleWidth: CGFloat!
    
    var direction: KLineDirection = .vertical
    
    var fuzzylayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        layer.backgroundColor = UIColor.rgb(r: 0, 0, 0, alpha: 0.3).cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        return layer
    }()
    
     init(frame: CGRect,datas:  [KLineModel], scrollX: CGFloat,isLine: Bool, scaleX: CGFloat, isLongPress: Bool, mainState: MainState, secondaryState: SecondaryState) {
        super.init(frame: frame)
        self.datas = datas
        self.scrollX = scrollX
        self.isLine = isLine
        self.scaleX = scaleX
        self.isLongPress = isLongPress
        self.mainState = mainState
        self.secondaryState = secondaryState
        self.candleWidth = self.scaleX * ChartStyle.candleWidth
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        displayHeight = rect.height - ChartStyle.topPadding - ChartStyle.bottomDateHigh;
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        divisionRect()
        calculateValue()
        calculateFormats()
        initRenderer()
        drawBgColor(context: context, rect: rect)
        drawGrid(context: context)
        if datas.count == 0 { return }
        drawChart(context: context)
        drawRightText(context: context)
        drawDate(context: context)
        drawMaxAndMin(context: context)
        if isLongPress {
            drawLongPressCrossLine(context: context)
        } else {
            drawTopText(context: context, curPoint: datas.first!)
        }
        drawRealTimePrice(context: context)
        UIGraphicsPopContext()
    }

    func calculateValue() {
        if datas.count == 0 { return }
        let itemWidth = candleWidth + ChartStyle.canldeMargin
        if(scrollX <= 0) {
            self.startX = -scrollX
            startIndex = 0
        } else {
            let start: CGFloat = scrollX / itemWidth
            var offsetX: CGFloat = 0
            if floor(start) == ceil(start) {
                startIndex = Int(floor(start))
            } else {
                startIndex = Int(floor((scrollX / itemWidth)))
                offsetX = CGFloat(startIndex) * CGFloat(itemWidth) - scrollX
            }
            self.startX = offsetX
        }
        let diffIndex = Int(ceil((self.frame.width - self.startX)/itemWidth))
        print(diffIndex)
        self.stopIndex = min(startIndex + diffIndex, datas.count - 1)
        print("startIndex=\(startIndex)   endIndex=\(self.stopIndex)")
       mMainMaxValue = 0
       mMainMinValue = CGFloat(MAXFLOAT)
       mMainHighMaxValue = -CGFloat(MAXFLOAT)
       mMainLowMinValue = CGFloat(MAXFLOAT)
       mVolMaxValue = -CGFloat(MAXFLOAT)
       mVolMinValue = CGFloat(MAXFLOAT)
       mSecondaryMaxValue = -CGFloat(MAXFLOAT)
       mSecondaryMinValue = CGFloat(MAXFLOAT)
        for i in startIndex...stopIndex {
            let item = datas[i]
            getMianMaxMinValue(item: item, i: i)
            getVolMaxMinValue(item: item)
            getSecondaryMaxMinValue(item: item)
        }
        print("mainMaxValue=\(mMainMaxValue)  mainMinValue=\(mMainMinValue)")
    }
    

    func drawChart(context: CGContext) {
        for index in startIndex...stopIndex {
            let curpoint = datas[index]
            let itemWidth = candleWidth + ChartStyle.canldeMargin
            let curX = CGFloat(index - startIndex) * itemWidth + startX
            let _curX = self.frame.width - curX - candleWidth / 2
            var lastPoint: KLineModel?
            if(index != startIndex) {
                lastPoint = datas[index - 1]
            }
            mainRenderer.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
            volRenderer?.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
            seconderyRender?.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
        }
    }
    
    func drawRightText(context: CGContext) {
        mainRenderer.drawRightText(context: context, gridRows: ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
        volRenderer?.drawRightText(context: context, gridRows: ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
        seconderyRender?.drawRightText(context: context, gridRows: ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
    }
    
    func drawTopText(context: CGContext, curPoint: KLineModel) {
        mainRenderer.drawTopText(context: context, curPoint: curPoint)
        volRenderer?.drawTopText(context: context, curPoint: curPoint)
        seconderyRender?.drawTopText(context: context, curPoint: curPoint)
    }
    
    func drawBgColor(context: CGContext, rect: CGRect) {
        context.setFillColor(ChartColors.bgColor.cgColor)
        context.fill(rect)
        mainRenderer.drawBg(context: context)
        volRenderer?.drawBg(context: context)
        seconderyRender?.drawBg(context: context)
    }
    
    func drawGrid(context: CGContext) {
        context.setStrokeColor(ChartColors.gridColor.cgColor)
        context.setLineWidth(1)
        context.addRect(self.bounds)
        context.drawPath(using: CGPathDrawingMode.stroke)
        mainRenderer.drawGrid(context: context, gridRows: ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
        volRenderer?.drawGrid(context: context, gridRows:  ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
        seconderyRender?.drawGrid(context: context, gridRows: ChartStyle.gridRows, gridColums: ChartStyle.gridColumns)
    }
    
    func drawDate(context: CGContext) {
        let columSpace = self.frame.width / CGFloat(ChartStyle.gridColumns)
        for i in 0..<ChartStyle.gridColumns {
            let index = calculateIndex(selectX: CGFloat(i)*columSpace)
            if outRangeIndex(index) { continue }
            let data = datas[index]
            
            let dateStr = calculateDateText(timestamp: data.id, dateFormat: fromat) as NSString
            let rect = calculateTextRect(text: dateStr as String, fontSize: ChartStyle.bottomDatefontSize)
            let y = self.dateRect.minY + (ChartStyle.bottomDateHigh - rect.height) / 2 //- rect.height
            dateStr.draw(at: CGPoint(x: CGFloat(columSpace * CGFloat(i)) - rect.width / 2, y: y), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.bottomDatefontSize),NSAttributedString.Key.foregroundColor: ChartColors.bottomDateTextColor])
        }
    }
    
    func drawLongPressCrossLine(context: CGContext) {
        let index = calculateIndex(selectX: longPressX)
        if(outRangeIndex(index)) { return }
        let point = datas[index]
        let itemWidth = candleWidth + ChartStyle.canldeMargin
        let curX = self.frame.width - (CGFloat(index - startIndex) * itemWidth + startX + candleWidth / 2)
        
        context.setStrokeColor(ChartColors.crossHlineColor.cgColor)
        context.setLineWidth(candleWidth)
        context.move(to: CGPoint(x: curX, y: 0))
        context.addLine(to: CGPoint(x: curX, y: self.frame.height - ChartStyle.bottomDateHigh))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        let y = mainRenderer.getY(point.close);
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 0, y: y))
        context.addLine(to: CGPoint(x: self.frame.width, y: y))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        context.setFillColor(UIColor.white.cgColor)
        context.addArc(center: CGPoint(x: curX, y: y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        drawLongPressCrossLineText(context: context, curPoint: point, curX: curX, y: y)
    }
    
    func drawLongPressCrossLineText(context: CGContext, curPoint: KLineModel, curX: CGFloat, y: CGFloat) {
        let text = String(format: "%.2f", curPoint.close)
        let rect = calculateTextRect(text: text, fontSize: ChartStyle.defaultTextSize)
        let padding: CGFloat = 3
        let textHeight = rect.height + padding * 2
        let textWidth = rect.width
        var isLeft = false
        if curX > self.frame.width / 2 {
            isLeft = true
            context.move(to: CGPoint(x: self.frame.width, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: self.frame.width, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: self.frame.width - textWidth, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: self.frame.width - textWidth - 10, y: y))
            context.addLine(to: CGPoint(x: self.frame.width - textWidth, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: self.frame.width, y: y - textHeight / 2))
            context.setLineWidth(1)
            context.setStrokeColor(ChartColors.markerBorderColor.cgColor)
            context.setFillColor(ChartColors.markerBgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            (text as NSString).draw(at: CGPoint(x: self.frame.width - textWidth - 2 , y: y - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),  NSAttributedString.Key.foregroundColor : UIColor.white
            ])
        } else {
            isLeft = false
            context.move(to: CGPoint(x: 0, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: 0, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: textWidth, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: textWidth + 10, y: y))
            context.addLine(to: CGPoint(x: textWidth, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: 0, y: y - textHeight / 2))
            context.setLineWidth(1)
            context.setStrokeColor(ChartColors.markerBorderColor.cgColor)
            context.setFillColor(ChartColors.markerBgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            (text as NSString).draw(at: CGPoint(x: 2, y: y - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),  NSAttributedString.Key.foregroundColor : UIColor.white
            ])
        }
        let dateText = calculateDateText(timestamp: curPoint.id, dateFormat: fromat)
        let dateRect = calculateTextRect(text: dateText, fontSize: ChartStyle.defaultTextSize)
        let datepadding: CGFloat = 3
        context.setStrokeColor(UIColor.white.cgColor)
        context.setFillColor(ChartColors.bgColor.cgColor)
        context.addRect(CGRect(x: curX - dateRect.width / 2 - datepadding, y: self.dateRect.minY, width: dateRect.width + 2 * datepadding, height: dateRect.height + datepadding * 2))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        (dateText as NSString).draw(at: CGPoint(x: curX - dateRect.width / 2, y: self.dateRect.minY + datepadding), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize),NSAttributedString.Key.foregroundColor : UIColor.white])
        
        showInfoBlock?(curPoint,isLeft)
        self.drawTopText(context: context, curPoint: curPoint)
    }
    
    func drawMaxAndMin(context: CGContext) {
        if isLine { return }
        let itemWidth = candleWidth + ChartStyle.canldeMargin
        let y1 = mainRenderer.getY(mMainHighMaxValue)
        let x1 = self.frame.width - (CGFloat(mMainMaxIndex - startIndex) * itemWidth + startX + candleWidth / 2)
        if x1 < self.frame.width / 2 {
            let text = "——" + String(format: "%.2f", mMainHighMaxValue)
            let rect = calculateTextRect(text: text, fontSize: ChartStyle.defaultTextSize)
            (text as NSString).draw(at: CGPoint(x: x1, y: y1 - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize), NSAttributedString.Key.foregroundColor : UIColor.white])
        } else {
            let text = String(format: "%.2f", mMainHighMaxValue) + "——"
            let rect = calculateTextRect(text: text, fontSize: ChartStyle.defaultTextSize)
            (text as NSString).draw(at: CGPoint(x: x1 - rect.width, y: y1 - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize), NSAttributedString.Key.foregroundColor : UIColor.white])
        }
        let y2 = mainRenderer.getY(mMainLowMinValue)
        let x2 = self.frame.width - (CGFloat(mMainMinIndex - startIndex) * itemWidth + startX + candleWidth / 2)
        if x2 < self.frame.width / 2 {
            let text = "——" + String(format: "%.2f", mMainLowMinValue)
            let rect = calculateTextRect(text: text, fontSize: ChartStyle.defaultTextSize)
            (text as NSString).draw(at: CGPoint(x: x2, y: y2 - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize), NSAttributedString.Key.foregroundColor : UIColor.white])
        } else {
            let text = String(format: "%.2f", mMainLowMinValue) + "——"
            let rect = calculateTextRect(text: text, fontSize: ChartStyle.defaultTextSize)
            (text as NSString).draw(at: CGPoint(x: x2 - rect.width, y: y2 - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: ChartStyle.defaultTextSize), NSAttributedString.Key.foregroundColor : UIColor.white])
        }
    }
    
    func drawRealTimePrice(context: CGContext) {
        guard let point = datas.first else { return }
        let text = String(format: "%.2f", point.close)
        let fontSize : CGFloat = 10
        let rect = calculateTextRect(text: text, fontSize: fontSize)
        var y =  mainRenderer.getY(point.close)
        if point.close > mMainMaxValue {
            y = mainRenderer.getY(mMainMaxValue)
        } else if point.close < mMainMinValue {
            y = mainRenderer.getY(mMainMinValue)
        }
        if (-scrollX - rect.width) > 0 {
            
            context.setStrokeColor(ChartColors.realTimeLongLineColor.cgColor)
            context.setLineWidth(0.5)
            context.setLineDash(phase: 0, lengths: [5,5])
            context.move(to: CGPoint(x: self.frame.width + scrollX, y: y))
            context.addLine(to: CGPoint(x: self.frame.width, y: y))
            context.drawPath(using: CGPathDrawingMode.stroke)
            
            context.addRect(CGRect(x: self.frame.width - rect.width, y: y - rect.height / 2, width: rect.width, height: rect.height))
            context.setFillColor(ChartColors.bgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fill)
            (text as NSString).draw(at: CGPoint(x: self.frame.width - rect.width, y: y - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : ChartColors.reightTextColor])
            if isLine {
                context.setFillColor(UIColor.white.cgColor)
                context.addArc(center: CGPoint(x: self.frame.width + scrollX - candleWidth / 2, y: y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                context.drawPath(using: CGPathDrawingMode.fill)
                
                context.setFillColor(UIColor(white: 255, alpha: 0.3).cgColor)
                context.addArc(center: CGPoint(x: self.frame.width + scrollX - candleWidth / 2, y: y), radius: 6, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                               context.drawPath(using: CGPathDrawingMode.fill)
//                self.fuzzylayer.frame = CGRect(x: self.frame.width + scrollX - candleWidth / 2 - 10, y: y - 10, width: 20, height: 20)
//                self.layer.addSublayer(self.fuzzylayer)
            }
        } else {
            context.setStrokeColor(ChartColors.realTimeLongLineColor.cgColor)
            context.setLineWidth(0.5)
            context.setLineDash(phase: 0, lengths: [10,5])
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: self.frame.width, y: y))
            context.drawPath(using: CGPathDrawingMode.stroke)
            
            let r: CGFloat = 8
            let w: CGFloat = rect.width + 16
            context.setLineWidth(0.8)
            context.setLineDash(phase: 0, lengths: [])
            context.setFillColor(ChartColors.bgColor.cgColor)
            context.move(to: CGPoint(x: self.frame.width * 0.8, y: y - r))
            let curX = self.frame.width * 0.8
            let arcRect = CGRect(x: curX - w / 2, y:  y - r, width: w, height: 2 * r)
            let minX = arcRect.minX
            let midX = arcRect.midX
            let maxX = arcRect.maxX
            
            let minY = arcRect.minY
            let midY = arcRect.midY
            let maxY = arcRect.maxY
            context.move(to: CGPoint(x: minX, y: midY))
            context.addArc(tangent1End: CGPoint(x: minX, y: minY), tangent2End: CGPoint(x: midX, y: minY), radius: r)
            context.addArc(tangent1End: CGPoint(x: maxX, y: minY), tangent2End: CGPoint(x: maxX, y: midY), radius: r)
            context.addArc(tangent1End: CGPoint(x: maxX, y: maxY), tangent2End: CGPoint(x: midX, y: maxY), radius: r)
            context.addArc(tangent1End: CGPoint(x: minX, y: maxY), tangent2End: CGPoint(x: minX, y: midY), radius: r)
            context.closePath()
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            
            let _startX = arcRect.maxX - 4
            context.setFillColor(ChartColors.reightTextColor.cgColor)
            context.move(to: CGPoint(x: _startX, y: y))
            context.addLine(to: CGPoint(x: _startX - 3, y: y - 3))
             context.addLine(to: CGPoint(x: _startX - 3, y: y + 3))
            context.closePath()
            context.drawPath(using: CGPathDrawingMode.fill)
            (text as NSString).draw(at: CGPoint(x: curX - rect.width / 2 - 4, y: y - rect.height / 2), withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : ChartColors.reightTextColor])
        }
    }
    
    func initRenderer() {
        mainRenderer = MainChartRenderer(maxValue: mMainMaxValue, minValue: mMainMinValue, chartRect: mainRect, candleWidth: candleWidth,topPadding: ChartStyle.topPadding, isLine: self.isLine,state: mainState)
        if let rect = volRect {
            volRenderer = VolChartRenderer(maxValue: mVolMaxValue, minValue: mVolMinValue, chartRect: rect, candleWidth: candleWidth, topPadding: ChartStyle.childPadding)
        }
        if let rect = secondaryRect {
            seconderyRender = SecondaryChartRenderer(maxValue: mSecondaryMaxValue, minValue: mSecondaryMinValue, chartRect: rect, candleWidth: candleWidth, topPadding:  ChartStyle.childPadding, state: secondaryState)
        }
    }
    
    //区分三大区域
    func divisionRect() {
        var mainHeight = displayHeight * 0.6
        let volHeight = displayHeight * 0.2
        let secondaryHeight = displayHeight * 0.2
        if volState == .none && secondaryState == .none {
            mainHeight = displayHeight
        } else if volState == .none || secondaryState == .none {
            mainHeight = displayHeight * 0.8
        }
        mainRect =  CGRect(x: 0, y: ChartStyle.topPadding, width: self.frame.width, height: mainHeight)
        if direction == .horizontal {
            dateRect = CGRect(x: 0, y: mainRect.maxY, width:self.frame.width   , height: ChartStyle.bottomDateHigh)
            if volState != .none {
                volRect = CGRect(x: 0, y: dateRect.maxY, width: self.frame.width, height: volHeight)
            }
            if secondaryState != .none {
                secondaryRect = CGRect(x: 0, y: (volRect?.maxY ?? 0), width: self.frame.width, height: secondaryHeight)
            }
        } else {
            if volState != .none {
                volRect = CGRect(x: 0, y: mainRect.maxY, width: self.frame.width, height: volHeight)
            }
            if secondaryState != .none {
                secondaryRect = CGRect(x: 0, y: (volRect?.maxY ?? 0), width: self.frame.width, height: secondaryHeight)
            }
            dateRect = CGRect(x: 0, y: self.displayHeight + ChartStyle.topPadding, width:self.frame.width   , height: ChartStyle.bottomDateHigh)
        }
    }
    
    func getMianMaxMinValue(item: KLineModel,i: Int) {
        if (isLine == true) {
          mMainMaxValue = max(mMainMaxValue, item.close);
          mMainMinValue = min(mMainMinValue, item.close);
        } else {
            var maxPrice = item.high;
            var minPrice = item.low;
            if (mainState == MainState.ma) {
            if(item.MA5Price != 0){
              maxPrice = max(maxPrice, item.MA5Price);
              minPrice = min(minPrice, item.MA5Price);
            }
            if(item.MA10Price != 0){
              maxPrice = max(maxPrice, item.MA10Price);
              minPrice = min(minPrice, item.MA10Price);
            }
            if(item.MA20Price != 0){
              maxPrice = max(maxPrice, item.MA20Price);
              minPrice = min(minPrice, item.MA20Price);
            }
            if(item.MA30Price != 0){
              maxPrice = max(maxPrice, item.MA30Price);
              minPrice = min(minPrice, item.MA30Price);
            }
            } else if (mainState == MainState.boll) {
            if(item.up != 0){
              maxPrice = max(item.up, item.high);
            }
            if(item.dn != 0){
              minPrice = min(item.dn, item.low);
            }
          }
          mMainMaxValue = max(mMainMaxValue, maxPrice);
          mMainMinValue = min(mMainMinValue, minPrice);

          if (mMainHighMaxValue < item.high) {
            mMainHighMaxValue = item.high;
            mMainMaxIndex = i;
          }
          if (mMainLowMinValue > item.low) {
            mMainLowMinValue = item.low;
            mMainMinIndex = i;
          }
        }
    }
    
    func getVolMaxMinValue(item: KLineModel) {
      mVolMaxValue = max(mVolMaxValue, max(item.vol, max(item.MA5Volume, item.MA10Volume)))
      mVolMinValue = min(mVolMinValue, min(item.vol, min(item.MA5Volume, item.MA10Volume)))
    }
    
    func getSecondaryMaxMinValue(item: KLineModel) {
      if (secondaryState == SecondaryState.macd) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.macd, max(item.dif, item.dea)));
        mSecondaryMinValue = min(mSecondaryMinValue, min(item.macd, min(item.dif, item.dea)));
      } else if (secondaryState == SecondaryState.kdj) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.k, max(item.d, item.j)));
        mSecondaryMinValue = min(mSecondaryMinValue, min(item.k, min(item.d, item.j)));
      } else if (secondaryState == SecondaryState.rsi) {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.rsi);
        mSecondaryMinValue = min(mSecondaryMinValue, item.rsi);
      } else {
        mSecondaryMaxValue = max(mSecondaryMaxValue, item.r);
        mSecondaryMinValue = min(mSecondaryMinValue, item.r);
      }
    }
    
    func calculateFormats() {
       if datas.count < 2 { return }
       let fristTime = datas.first?.id ?? 0
       let secondTime = datas[1].id
       let time = abs(fristTime - secondTime)
       if time >= 24 * 60 * 60 * 28 {
           fromat = "yyyy-MM"
       } else if time >= 24 * 60 * 60 {
           fromat = "yyyy-MM-dd"
       } else {
           fromat = "MM-dd HH:mm"
       }
   }
    
    func calculateIndex(selectX : CGFloat) -> Int {
        let index = Int((self.frame.width - startX - selectX) / (candleWidth + ChartStyle.canldeMargin)) + startIndex
        return index
    }
    
    func outRangeIndex(_ index: Int) -> Bool {
      if(index < 0 || index >= datas.count) {
        return true;
      } else {
        return false;
      }
    }
    
}
