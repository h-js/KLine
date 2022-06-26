//
//  KDrawPainterView.swift
//  KLine-Chart
//
//  Created by hjs on 2022/6/26.
//  Copyright © 2022 hjs. All rights reserved.
//

import UIKit

class KDrawPainterView: UIView {

    var graphicsModels: [KGraphicsModel] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        graphicsModels.map { $0.draw(context: context) }
    }
}
