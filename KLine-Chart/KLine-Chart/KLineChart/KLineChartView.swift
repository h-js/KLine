//
//  KLineChartView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLineChartView: UIView {
    
    var painterView: KLinePainterView?
    var isLine = false {
        didSet {
            painterView?.isLine = isLine
        }
    }
    var isScale = false
    var isDrag = false
    var isLongPress = false {
        didSet {
            painterView?.isLongPress = isLongPress
            if !isLongPress {
                self.infoView.removeFromSuperview()
            }
        }
    }
    var scrollX: CGFloat = 0.0  {
        didSet{
            painterView?.scrollX = scrollX
        }
    }
    var maxScroll: CGFloat = 0.0
    var minScroll: CGFloat = 0.0
    var scaleX: CGFloat = 1.0 {
        didSet {
            initIndicators()
            painterView?.scaleX = scaleX
        }
    }
    var selectX: CGFloat = 0.0
    var datas: [KLineModel] = [] {
        didSet {
            initIndicators()
            painterView?.datas = datas
        }
    }
    var mainState: MainState = .none {
        didSet {
            painterView?.mainState = mainState
        }
    }
    var secondaryState: SecondaryState = .none {
        didSet {
           painterView?.secondaryState = secondaryState
        }
    }
    
    var lastScrollX: CGFloat = 0.0
    var dragbeginX: CGFloat = 0
    
    var lastscaleX: CGFloat = 1
    
    var longPressX: CGFloat = 0 {
        didSet {
            painterView?.longPressX = longPressX
        }
    }
    var direction: KLineDirection = .vertical {
        didSet {
            painterView?.direction = direction
        }
    }
    
    var speedX: CGFloat = 0
    
    var displayLink: CADisplayLink?
    
    lazy var infoView: KLineInfoView = {
        let view = KLineInfoView.lineInfoView()
        return view
    }()
    override var frame: CGRect {
        didSet {
            self.painterView?.frame = self.bounds
            initIndicators()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollX = -self.frame.width / 5 + ChartStyle.candleWidth / 2;
        initIndicators()
        painterView = KLinePainterView.init(frame: self.bounds, datas: self.datas, scrollX: self.scrollX, isLine: self.isLine, scaleX: self.scaleX, isLongPress: self.isLongPress, mainState: self.mainState, secondaryState: self.secondaryState)
        addSubview(painterView!)
        painterView?.showInfoBlock = {
            [weak self]  (point,isleft) in
            guard let strongSelf = self else { return }
            strongSelf.infoView.model = point
            strongSelf.addSubview(strongSelf.infoView)
            let padding: CGFloat = 5
            if isleft {
                strongSelf.infoView.frame = CGRect(x: padding, y: 30, width: strongSelf.infoView.frame.width, height: strongSelf.infoView.frame.height)
            } else {
                strongSelf.infoView.frame = CGRect(x: strongSelf.frame.width - strongSelf.infoView.frame.width - padding, y: 30, width: strongSelf.infoView.frame.width, height: strongSelf.infoView.frame.height)
            }
        }
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(dragKlineEvent(gesture:)))
        painterView?.addGestureRecognizer(panGesture)
        let longPressGreture = UILongPressGestureRecognizer(target: self, action: #selector(longPressKlineEvent(gesture:)))
        painterView?.addGestureRecognizer(longPressGreture)
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(secalXEvent(gesture:)))
        painterView?.addGestureRecognizer(pinGesture)
    }
    
    func initIndicators() {
       let dataLength : CGFloat = CGFloat(datas.count) * (ChartStyle.candleWidth * scaleX + ChartStyle.canldeMargin) - ChartStyle.canldeMargin
       if dataLength > self.frame.width {
        //感觉没必要用if else 一样的效果
           maxScroll = dataLength - self.frame.width
       } else {
           maxScroll = -(self.frame.width - dataLength)
       }
       let dataScroll = self.frame.width - dataLength
       let normalminScroll = -self.frame.width / 5 + (ChartStyle.candleWidth * scaleX) / 2
       minScroll = min(normalminScroll, -dataScroll)
       scrollX = clamp(value: scrollX, min: minScroll, max: maxScroll)
       lastScrollX = scrollX
       print(scrollX)
    }
    
    //拖动k线处理事件
    @objc func dragKlineEvent(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
             let point = gesture.location(in: self.painterView)
             dragbeginX = point.x
            print("dragKlineEvent began")
            isDrag = true
        case .changed:
           let point = gesture.location(in: self.painterView)
           let dragX = point.x - dragbeginX
           scrollX = clamp(value: self.lastScrollX + dragX, min: minScroll, max: maxScroll)
           print(scrollX)
        case .ended:
            let speed = gesture.velocity(in: gesture.view)
            self.speedX = speed.x
            print("speed=\(speed)")
            isDrag = false
            self.lastScrollX = self.scrollX
            if speed.x != 0 {
                displayLink = CADisplayLink(target: self, selector: #selector(refreshEvent))
                displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            }
        default:
            print("拖动k线出现\(gesture.state)事件")
        }
    }
    //长按手势处理
    @objc func longPressKlineEvent(gesture: UILongPressGestureRecognizer) {
        print("longPressKlineEvent")
        switch gesture.state {
        case .began:
             let point = gesture.location(in: self.painterView)
             longPressX = point.x
             isLongPress = true
        case .changed:
            let point = gesture.location(in: self.painterView)
            longPressX = point.x
            isLongPress = true
        case .ended:
            isLongPress = false
        default:
             print("长按k线出现\(gesture.state)事件")
        }
    }
    
    @objc func secalXEvent(gesture: UIPinchGestureRecognizer) {
        print("longPressKlineEvent")
           switch gesture.state {
           case .began:
               isScale = true
           case .changed:
            isScale = true
            print(gesture.scale)
            scaleX = clamp(value: self.lastscaleX * gesture.scale, min: 0.5, max: 2)
           case .ended:
                isScale = false
                self.lastscaleX = scaleX
           default:
                print("长按k线出现\(gesture.state)事件")
           }
    }
    
    @objc func refreshEvent(_ displaylink: CADisplayLink) {
        let space: CGFloat = 100
        if self.speedX < 0 {
            self.speedX = min(self.speedX + space, 0)
            self.scrollX = clamp(value: self.scrollX - 5, min: minScroll, max: maxScroll)
            self.lastScrollX = self.scrollX
        } else if self.speedX > 0 {
            self.speedX = max(self.speedX - space, 0)
            self.scrollX = clamp(value: self.scrollX + 5, min: minScroll, max: maxScroll)
            self.lastScrollX = self.scrollX
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
