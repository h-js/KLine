//
//  KLinePeriodView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/3.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLinePeriodView: UIView {
    @IBOutlet var centerXConstraint: NSLayoutConstraint!
    @IBOutlet var periodfenButton: UIButton! // tag == 1
    @IBOutlet var period5fenButton: UIButton! // tag == 2
    @IBOutlet var period30fenButton: UIButton! // tag == 3
    @IBOutlet var period1hourButton: UIButton! // tag == 4
    @IBOutlet var period4hourButton: UIButton! // tag == 5
    @IBOutlet var period1dayButton: UIButton! // tag == 6
    @IBOutlet var period1weakButton: UIButton! // tag == 7

    var currentButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        currentButton = period5fenButton
    }

    override var frame: CGRect {
        didSet {}
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if periodfenButton != nil {
            centerXConstraint.constant = (currentButton?.center.x ?? 0) - periodfenButton.center.x
        }
    }

    static func linePeriodView() -> KLinePeriodView {
        guard let view = Bundle.main.loadNibNamed("KLinePeriodView", owner: self, options: nil)?.last as? KLinePeriodView else {
            fatalError()
        }
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
        view.backgroundColor = ChartColors.bgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 5
        return view
    }

    @IBAction func buttonClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.centerXConstraint.constant = sender.center.x - self.periodfenButton.center.x
        }
        currentButton = sender
        var period = "1min"
        switch sender.tag {
        case 1:
            period = "1min"
        case 2:
            period = "5min"
        case 3:
            period = "30min"
        case 4:
            period = "1hour"
        case 5:
            period = "4hour"
        case 6:
            period = "1day"
        case 7:
            period = "1week"
        default:
            print("defalut")
        }
        KLineStateManger.manager.setPeriod(period)
        if period == "1min" {
            KLineStateManger.manager.setisLine(true)
        } else {
            KLineStateManger.manager.setisLine(false)
        }
    }
}
