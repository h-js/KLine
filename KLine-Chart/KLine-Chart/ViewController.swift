//
//  ViewController.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let klineCharView = KLineChartView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width - 0, height: 450))
    
    let klinePeriodView = KLinePeriodView.linePeriodView()
    
    let lineIndicatorsView = KLineIndicatorsView.indicatorsView()
    
    let verticalIndicatorsView = KLineVerticalIndicatorsView.verticalIndicatorsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgb(r: 8, 23, 35)
//        let path =  Bundle.main.path(forResource: "kline", ofType: "json")!
//        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//        let dicts = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
//
//        let datas =  dicts.map { (dict) -> KLineModel in
//            return KLineModel(dict: dict)
//            }
//        DataUtil.calculate(dataList: datas.reversed())
        
//        KLineStateManger.manager.datas = []
        HTTPTool.tool.getData(period: KLineStateManger.manager.period) { (datas) in
            DataUtil.calculate(dataList: datas.reversed())
            KLineStateManger.manager.datas = datas
            
        }
        
        
        
        self.view.addSubview(klineCharView)
        self.view.addSubview(klinePeriodView)
        self.view.addSubview(lineIndicatorsView)
        self.view.addSubview(verticalIndicatorsView)

        self.verticalLayout()
        
        KLineStateManger.manager.klineChart = klineCharView
        NotificationCenter.default.addObserver(self, selector: #selector(chageRotate(noti:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        
    }
    
    @objc func chageRotate(noti: Notification) {
        if UIDevice.current.orientation == UIDeviceOrientation.portrait ||  UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            print("竖直屏幕")
            self.verticalLayout()
        } else {
            //
            print("横屏幕")
            self.horizontalLayout()
        }
    }
    func verticalLayout() {
        var topMargin: CGFloat = 50
           if #available(iOS 11.0, *) {
               topMargin = self.view.safeAreaInsets.top + topMargin
           }
        self.lineIndicatorsView.correctState()
        self.klineCharView.direction = .vertical
        self.klinePeriodView.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: 30)
        self.klineCharView.frame = CGRect(x: 0, y: self.klinePeriodView.frame.maxY, width: self.view.frame.width, height: 450)
        self.lineIndicatorsView.frame = CGRect(x: 0, y: klineCharView.frame.maxY + 20, width: klineCharView.frame.width, height: 80)
    }
    
    func horizontalLayout() {
         self.klineCharView.direction = .horizontal
         var rightMargin: CGFloat = 0
          if #available(iOS 11.0, *) {
              rightMargin = self.view.safeAreaInsets.right + rightMargin
          }
        self.verticalIndicatorsView.correctState()
        self.verticalIndicatorsView.frame = CGRect(x: self.view.frame.width - 50 - rightMargin, y: 0, width: 50, height: self.view.frame.height)
        self.klineCharView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 50 - rightMargin, height: self.view.frame.height - 30)
        self.klinePeriodView.frame = CGRect(x: 0, y: self.view.frame.height - 30, width: self.klineCharView.frame.width, height: 30)
    }

    
}

