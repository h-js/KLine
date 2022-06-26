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
    
    var drawView = KDrawView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(r: 8, 23, 35)
        HTTPTool.tool.getData(period: KLineStateManger.manager.period) { datas in
            DataUtil.calculate(dataList: datas)
            KLineStateManger.manager.datas = datas
        }

        view.addSubview(klineCharView)
        view.addSubview(klinePeriodView)
        view.addSubview(lineIndicatorsView)
        view.addSubview(verticalIndicatorsView)
        view.addSubview(drawView)
        

        verticalLayout()
        drawView.frame = klineCharView.frame

        KLineStateManger.manager.klineChart = klineCharView
        NotificationCenter.default.addObserver(self, selector: #selector(chageRotate(noti:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }

    @objc func chageRotate(noti _: Notification) {
        if UIDevice.current.orientation == UIDeviceOrientation.portrait || UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            print("竖直屏幕")
            verticalLayout()
        } else {
            //
            print("横屏幕")
            horizontalLayout()
        }
    }

    func verticalLayout() {
        var topMargin: CGFloat = 50
        if #available(iOS 11.0, *) {
            topMargin = self.view.safeAreaInsets.top + topMargin
        }
        lineIndicatorsView.correctState()
        klineCharView.direction = .vertical
        klinePeriodView.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: 30)
        klineCharView.frame = CGRect(x: 0, y: klinePeriodView.frame.maxY, width: view.frame.width, height: 450)
        lineIndicatorsView.frame = CGRect(x: 0, y: klineCharView.frame.maxY + 20, width: klineCharView.frame.width, height: 80)
    }

    func horizontalLayout() {
        klineCharView.direction = .horizontal
        var rightMargin: CGFloat = 0
        if #available(iOS 11.0, *) {
            rightMargin = self.view.safeAreaInsets.right + rightMargin
        }
        verticalIndicatorsView.correctState()
        verticalIndicatorsView.frame = CGRect(x: view.frame.width - 50 - rightMargin, y: 0, width: 50, height: view.frame.height)
        klineCharView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 50 - rightMargin, height: view.frame.height - 30)
        klinePeriodView.frame = CGRect(x: 0, y: view.frame.height - 30, width: klineCharView.frame.width, height: 30)
    }
}
