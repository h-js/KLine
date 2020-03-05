//
//  KLinePeriodView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/3.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLinePeriodView: UIView {

    
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint!
    @IBOutlet weak var periodfenButton: UIButton!   // tag == 1
    @IBOutlet weak var period5fenButton: UIButton!  // tag == 2
    @IBOutlet weak var period30fenButton: UIButton! // tag == 3
    @IBOutlet weak var period1hourButton: UIButton! // tag == 4
    @IBOutlet weak var period4hourButton: UIButton! // tag == 5
    @IBOutlet weak var period1dayButton: UIButton!  // tag == 6
    @IBOutlet weak var period1weakButton: UIButton! // tag == 7
    
    var currentButton: UIButton?
    
    override func awakeFromNib() {
       super.awakeFromNib()
       self.currentButton = self.period5fenButton
    }
    
    override var frame: CGRect {
        didSet {
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.periodfenButton != nil {
            self.centerXConstraint.constant = (self.currentButton?.center.x ?? 0) - self.periodfenButton.center.x
        }
    }
    
    static func linePeriodView() -> KLinePeriodView {
        let view = Bundle.main.loadNibNamed("KLinePeriodView", owner: self, options: nil)?.last as! KLinePeriodView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
        view.backgroundColor = ChartColors.bgColor
        view.layer.shadowColor =  UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 5
       return view
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.centerXConstraint.constant =  sender.center.x - self.periodfenButton.center.x
        }
        self.currentButton = sender
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
