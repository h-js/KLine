//
//  KLineChartView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

public class KLineChartView: UIView {
    var painterView: KLinePainterView!
    var isLine = false {
        didSet {
            painterView.isLine = isLine
        }
    }

    var isScale = false
    var isDrag = false
    var isLongPress = false {
        didSet {
            painterView.isLongPress = isLongPress
            if !isLongPress {
                infoView.removeFromSuperview()
            }
        }
    }

    var scrollX: CGFloat = 0.0 {
        didSet {
            painterView.scrollX = scrollX
        }
    }

    var maxScroll: CGFloat = 0.0
    var minScroll: CGFloat = 0.0
    var scaleX: CGFloat = 1.0 {
        didSet {
            painterView?.scaleX = scaleX
        }
    }

    var selectX: CGFloat = 0.0
    var datas: [KLineModel] = [] {
        didSet {
            initIndicators()
            painterView.datas = datas
        }
    }

    var mainState: MainState = .none {
        didSet {
            painterView.mainState = mainState
        }
    }

    var secondaryState: SecondaryState = .none {
        didSet {
            painterView.secondaryState = secondaryState
        }
    }

    // 拖动相关参数
    var lastScrollX: CGFloat = 0.0
    var dragbeginX: CGFloat = 0

    /// 上一次缩放的比例
    var lastscaleX: CGFloat = 1
    /// 缩放的中心点
    var scaleStartX: CGFloat = 0
    /// 缩放中心点对应的index
    var scaleIndex: Int = 0

    // k线初始位置
    var minTrailing: CGFloat = 0
    var maxTrailing: CGFloat = 0

    var longPressX: CGFloat = 0 {
        didSet {
            painterView.longPressX = longPressX
        }
    }

    var direction: KLineDirection = .vertical {
        didSet {
            painterView.direction = direction
        }
    }

    var speedX: CGFloat = 0

    var displayLink: CADisplayLink?

    lazy var infoView: KLineInfoView = {
        let view = KLineInfoView.lineInfoView()
        return view
    }()

    public override var frame: CGRect {
        didSet {
            self.painterView?.frame = self.bounds
            initIndicators()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        painterView = KLinePainterView(
            frame: bounds,
            datas: datas,
            scrollX: scrollX,
            isLine: isLine,
            scaleX: scaleX,
            isLongPress: isLongPress,
            mainState: mainState,
            secondaryState: secondaryState
        )
        initTrailing()
        scrollX = -self.frame.width / 5 + ChartStyle.candleWidth / 2
        initIndicators()
        addSubview(painterView)
        painterView.showInfoBlock = {
            [weak self] point, isleft in
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
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragKlineEvent(gesture:))
        )
        painterView.addGestureRecognizer(panGesture)
        let longPressGreture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressKlineEvent(gesture:))
        )
        painterView.addGestureRecognizer(longPressGreture)
        let pinGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(secalXEvent(gesture:))
        )
        painterView.addGestureRecognizer(pinGesture)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initTrailing() {
        minTrailing = frame.width * 0.2
        maxTrailing = frame.width * 0.2
    }

    func initScrollWidth() {
        let dataLength: CGFloat = CGFloat(datas.count) * (ChartStyle.candleWidth * scaleX + ChartStyle.canldeMargin) - ChartStyle.canldeMargin
        if dataLength > frame.width {
            maxScroll = dataLength - frame.width
        } else {
            maxScroll = -(frame.width - dataLength)
        }
        let dataScroll = frame.width - dataLength
        let normalminScroll = -maxTrailing + (ChartStyle.candleWidth * scaleX) / 2
        minScroll = min(normalminScroll, -dataScroll)
    }

    func secalXIndicators(trailing: CGFloat) {
        initScrollWidth()
        let selectIndexOffset = CGFloat(scaleIndex) * (ChartStyle.candleWidth * scaleX + ChartStyle.canldeMargin) - ChartStyle.canldeMargin
        scrollX = clamp(
            value: selectIndexOffset - trailing,
            min: minScroll,
            max: maxScroll
        )
        print(scrollX)
    }

    func initIndicators() {
        if datas.count == 0 { return }
        initScrollWidth()
        scrollX = clamp(value: scrollX, min: minScroll, max: maxScroll)
        lastScrollX = scrollX
    }

    // 拖动k线处理事件
    @objc func dragKlineEvent(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: painterView)
            dragbeginX = point.x
            print("dragKlineEvent began")
            isDrag = true
        case .changed:
            let point = gesture.location(in: painterView)
            let dragX = point.x - dragbeginX
            scrollX = clamp(
                value: lastScrollX + dragX,
                min: minScroll,
                max: maxScroll
            )
            print(scrollX)
        case .ended:
            let speed = gesture.velocity(in: gesture.view)
            speedX = speed.x
            print("speed=\(speed)")
            isDrag = false
            lastScrollX = scrollX
            if speed.x != 0 {
                displayLink = CADisplayLink(
                    target: self,
                    selector: #selector(refreshEvent)
                )
                displayLink?.add(
                    to: RunLoop.current,
                    forMode: RunLoop.Mode.common
                )
            }
        default:
            print("拖动k线出现\(gesture.state)事件")
        }
    }

    // 长按手势处理
    @objc func longPressKlineEvent(gesture: UILongPressGestureRecognizer) {
        print("longPressKlineEvent")
        switch gesture.state {
        case .began:
            let point = gesture.location(in: painterView)
            longPressX = point.x
            isLongPress = true
        case .changed:
            let point = gesture.location(in: painterView)
            longPressX = point.x
            isLongPress = true
        case .ended:
            isLongPress = false
        default:
            print("长按k线出现\(gesture.state)事件")
        }
    }

    @objc func secalXEvent(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isScale = true
            let point = gesture.location(in: self)
            scaleStartX = point.x
            guard let index = calculateIndex(selectX: scaleStartX) else { return }
            scaleIndex = index
        case .changed:
            isScale = true
            let newscaleX = clamp(value: lastscaleX * gesture.scale, min: 0.1, max: 5)
            if newscaleX == scaleX { return }
            scaleX = newscaleX
            let rightWidth = frame.width - scaleStartX
            secalXIndicators(trailing: rightWidth)

        case .ended, .cancelled:
            isScale = false
            lastscaleX = scaleX
            lastScrollX = scrollX
        default:
            print("长按k线出现\(gesture.state)事件")
        }
    }

    @objc func refreshEvent(_: CADisplayLink) {
        let space: CGFloat = 100
        if speedX < 0 {
            speedX = min(speedX + space, 0)
            scrollX = clamp(
                value: scrollX - 5,
                min: minScroll,
                max: maxScroll
            )
            lastScrollX = scrollX
        } else if speedX > 0 {
            speedX = max(speedX - space, 0)
            scrollX = clamp(
                value: scrollX + 5,
                min: minScroll,
                max: maxScroll
            )
            lastScrollX = scrollX
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    private func calculateIndex(selectX _: CGFloat) -> Int? {
        return painterView?.calculateIndex(selectX: scaleStartX)
    }
}
