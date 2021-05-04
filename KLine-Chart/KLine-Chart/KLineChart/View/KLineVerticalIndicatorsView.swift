//
//  KLineVerticalIndicatorsView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/4.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLineVerticalIndicatorsView: UIView {
    @IBOutlet var maButton: UIButton! // tag == 1
    @IBOutlet var bollButton: UIButton! // tag == 2

    @IBOutlet var macdButton: UIButton! // tag == 1
    @IBOutlet var kdjButton: UIButton! // tag == 2
    @IBOutlet var rsiButton: UIButton! // tag == 3
    @IBOutlet var wrButton: UIButton! // tag == 4

    static func verticalIndicatorsView() -> KLineVerticalIndicatorsView {
        guard let view = Bundle.main.loadNibNamed("KLineVerticalIndicatorsView", owner: self, options: nil)?.last as? KLineVerticalIndicatorsView else {
            fatalError()
        }
        view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: 80, height: UIScreen.main.bounds.width)
        view.backgroundColor = ChartColors.bgColor
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ChartColors.gridColor.cgColor
        return view
    }

    func correctState() {
        switch KLineStateManger.manager.mainState {
        case .ma:
            mainbuttonClick(maButton)
        case .boll:
            mainbuttonClick(bollButton)
        case .none:
            mainhideClick(UIButton())
        }

        switch KLineStateManger.manager.secondaryState {
        case .macd:
            vicebuttonClick(macdButton)
        case .kdj:
            vicebuttonClick(kdjButton)
        case .rsi:
            vicebuttonClick(rsiButton)
        case .wr:
            vicebuttonClick(wrButton)
        case .none:
            viceHideClick(UIButton())
        }
    }

    @IBAction func mainbuttonClick(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            maButton.isSelected = true
            bollButton.isSelected = false
            KLineStateManger.manager.setMainState(MainState.ma)
        case 2:
            maButton.isSelected = false
            bollButton.isSelected = true
            KLineStateManger.manager.setMainState(MainState.boll)
        default:
            break
        }
    }

    @IBAction func vicebuttonClick(_ sender: UIButton) {
        macdButton.isSelected = false
        kdjButton.isSelected = false
        rsiButton.isSelected = false
        wrButton.isSelected = false

        switch sender.tag {
        case 1:
            macdButton.isSelected = true
            KLineStateManger.manager.setSecondaryState(.macd)
        case 2:
            kdjButton.isSelected = true
            KLineStateManger.manager.setSecondaryState(.kdj)
        case 3:
            rsiButton.isSelected = true
            KLineStateManger.manager.setSecondaryState(.rsi)
        case 4:
            wrButton.isSelected = true
            KLineStateManger.manager.setSecondaryState(.wr)
        default:
            break
        }
    }

    @IBAction func mainhideClick(_: UIButton) {
        maButton.isSelected = false
        bollButton.isSelected = false
        KLineStateManger.manager.setMainState(MainState.none)
    }

    @IBAction func viceHideClick(_: Any) {
        macdButton.isSelected = false
        kdjButton.isSelected = false
        rsiButton.isSelected = false
        wrButton.isSelected = false
        KLineStateManger.manager.setSecondaryState(.none)
    }
}
