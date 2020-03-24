//
//  KLineIndicatorsView.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/3.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLineIndicatorsView: UIView {

    @IBOutlet weak var maButton: UIButton!  // tag == 1
    @IBOutlet weak var bollButton: UIButton! // tag == 2
    
    @IBOutlet weak var macdButton: UIButton! // tag == 1
    @IBOutlet weak var kdjButton: UIButton! // tag == 2
    @IBOutlet weak var rsiButton: UIButton! // tag == 3
    @IBOutlet weak var wrButton: UIButton! // tag == 4
    
    
    static func indicatorsView() -> KLineIndicatorsView {
        let view = Bundle.main.loadNibNamed("KLineIndicatorsView", owner: self, options: nil)?.last as! KLineIndicatorsView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        view.backgroundColor = ChartColors.bgColor
        view.layer.shadowColor =  UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 5
       return view
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
    
    @IBAction func mainhideClick(_ sender: UIButton) {
        maButton.isSelected = false
        bollButton.isSelected = false
        KLineStateManger.manager.setMainState(MainState.none)
    }
    
    @IBAction func viceHideClick(_ sender: Any) {
        macdButton.isSelected = false
        kdjButton.isSelected = false
        rsiButton.isSelected = false
        wrButton.isSelected = false
        KLineStateManger.manager.setSecondaryState(.none)
    }
    
    func correctState() {
        switch  KLineStateManger.manager.mainState {
        case .ma:
            mainbuttonClick(self.maButton)
        case .boll:
            mainbuttonClick(self.bollButton)
        case .none:
            mainhideClick(UIButton())
        }
        
        switch KLineStateManger.manager.secondaryState {
        case .macd:
            vicebuttonClick(self.macdButton)
        case .kdj:
            vicebuttonClick(self.kdjButton)
        case .rsi:
            vicebuttonClick(self.rsiButton)
        case .wr:
            vicebuttonClick(self.wrButton)
        case .none:
            viceHideClick(UIButton())
        }
    }
    
    @IBAction func addDataClick(_ sender: UIButton) {
        if let model = KLineStateManger.manager.datas.first {
               //拷贝一个对象，修改数据
               let kLineEntity = KLineModel()
               kLineEntity.id = model.id + 60 * 60 * 24;
               kLineEntity.open = model.close;
               let rand = Int(arc4random() % 200)
               kLineEntity.close = model.close + CGFloat(rand) * CGFloat((rand % 3) - 1)
               kLineEntity.high = max(kLineEntity.open, kLineEntity.close) + 10
               kLineEntity.low = min(kLineEntity.open, kLineEntity.close) - 10
               
               kLineEntity.amount = model.amount + CGFloat(rand) * CGFloat((rand % 3) - 1)
               kLineEntity.count = model.count + Int64(rand) * Int64((rand % 3) - 1)
               kLineEntity.vol = model.vol +  CGFloat(rand) * CGFloat((rand % 3) - 1)
               
               
               var models = KLineStateManger.manager.datas
               DataUtil.addLastData(dataList: models, data: kLineEntity)
               models.insert(kLineEntity, at: 0)
               KLineStateManger.manager.datas = models
        }
    }
    
    
}
