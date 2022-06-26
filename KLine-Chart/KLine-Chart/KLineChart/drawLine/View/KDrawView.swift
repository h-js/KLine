//
//  KDrawView.swift
//  KLine-Chart
//
//  Created by hjs on 2022/6/26.
//  Copyright © 2022 hjs. All rights reserved.
//

import UIKit

class KDrawView: UIView {

    let painterView = KDrawPainterView()
    
    var graphicsModels: [KGraphicsModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(painterView)
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragEvent(gesture:))
        )
        painterView.addGestureRecognizer(panGesture)
        let tapGreture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapEvent(gesture:))
        )
        painterView.addGestureRecognizer(tapGreture)
        painterView.graphicsModels = graphicsModels
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        painterView.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        guard let point = touch?.location(in: self) else { return }
        self.graphicsModels.last?.startPoint = point
    }
    
    @objc func dragEvent(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
             let _ = self.graphicsModels.last?.canDargType()
        case .changed:
            if self.graphicsModels.last?.dargType == .none { return }
            let point = gesture.location(in: painterView)
            self.graphicsModels.last?.move(point: point)
            self.painterView.setNeedsDisplay()
        case .ended:
            self.graphicsModels.last?.dargType = .none
        default:
            print("拖动出现\(gesture.state)事件")
        }
    }
    
    @objc func tapEvent(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self.painterView)
        if let lastModel = graphicsModels.last {
            if lastModel.isComplete {
                lastModel.isActive = false
                let model = KGraphicsModel()
                model.isActive = true
                model.addPoint(point)
                graphicsModels.append(model)
                painterView.graphicsModels = graphicsModels
            } else {
                lastModel.addPoint(point)
                painterView.graphicsModels = graphicsModels
            }
        } else {
            let model = KGraphicsModel()
            model.addPoint(point)
            graphicsModels.append(model)
            painterView.graphicsModels = graphicsModels
        }
    }

}
