//
//  KLineStateManger.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/3.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLineStateManger {
    weak var klineChart: KLineChartView? {
        didSet {
            klineChart?.mainState = mainState
            klineChart?.secondaryState = secondaryState
            klineChart?.isLine = isLine
            klineChart?.datas = datas
        }
    }

    private init() {}

    static let manager = KLineStateManger()

    var period: String = "5min"
    var mainState: MainState = .ma
    var secondaryState: SecondaryState = .macd
    var isLine = false
    var datas: [KLineModel] = [] {
        didSet {
            klineChart?.datas = datas
        }
    }

    func setMainState(_ state: MainState) {
        mainState = state
        klineChart?.mainState = state
    }

    func setSecondaryState(_ state: SecondaryState) {
        secondaryState = state
        klineChart?.secondaryState = state
    }

    func setisLine(_ isLine: Bool) {
        self.isLine = isLine
        klineChart?.isLine = isLine
    }

    func setDatas(_ datas: [KLineModel]) {
        self.datas = datas
        klineChart?.datas = datas
    }

    func setPeriod(_ period: String) {
        // 需要重新请求数据
        self.period = period
        datas = []
        HTTPTool.tool.getData(period: period) { datas in
            DataUtil.calculate(dataList: datas)
            KLineStateManger.manager.datas = datas
        }
    }
}
