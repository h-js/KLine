//
//  ChartStyle.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import Foundation
import UIKit

class ChartColors {
    // 背景颜色
    static let bgColor = Color(0xFF06_141D)
    static let kLineColor = Color(0xFF4C_86CD)
    static let gridColor = Color(0xFF4C_5C74)
    static let ma5Color = Color(0xFFC9_B885)
    static let ma10Color = Color(0xFF6C_B0A6)
    static let ma30Color = Color(0xFF99_79C6)
    static let upColor = Color(0xFF4D_AA90)
    static let dnColor = Color(0xFFC1_5466)
    static let volColor = Color(0xFF47_29AE)

    static let macdColor = Color(0xFF47_29AE)
    static let difColor = Color(0xFFC9_B885)
    static let deaColor = Color(0xFF6C_B0A6)

    static let kColor = Color(0xFFC9_B885)
    static let dColor = Color(0xFF6C_B0A6)
    static let jColor = Color(0xFF99_79C6)
    static let rsiColor = Color(0xFFC9_B885)

    static let wrColor = Color(0xFFD2_D2B4)

    static let yAxisTextColor = Color(0xFF70_839E) // 右边y轴刻度
    static let xAxisTextColor = Color(0xFF60_738E) // 下方时间刻度

    static let maxMinTextColor = Color(0xFFFF_FFFF) // 最大最小值的颜色

    // 深度颜色
    static let depthBuyColor = Color(0xFF60_A893)
    static let depthSellColor = Color(0xFFC1_5866)

    // 选中后显示值边框颜色
    static let markerBorderColor = Color(0xFFFF_FFFF)

    // 选中后显示值背景的填充颜色
    static let markerBgColor = Color(0xFF0D_1722)

    // 实时线颜色等
    static let realTimeBgColor = Color(0xFF0D_1722)
    static let rightRealTimeTextColor = Color(0xFF4C_86CD)
    static let realTimeTextBorderColor = Color(0xFFFF_FFFF)
    static let realTimeTextColor = Color(0xFFFF_FFFF)

    // 实时线
    static let realTimeLineColor = Color(0xFFFF_FFFF)
    static let realTimeLongLineColor = Color(0xFF4C_86CD)

    // 表格右边文字颜色
    static let reightTextColor = Color(0xFF70_839E)
    static let bottomDateTextColor = Color(0xFF70_839E)

    static let crossHlineColor = Color(0x1FFF_FFFF)
}

class ChartStyle {
    // 点与点的距离（）不用这种方式实现
    static let pointWidth: CGFloat = 11.0

    // 蜡烛之间的间距
    static let canldeMargin: CGFloat = 3

    // 蜡烛默认宽度
    static let defaultcandleWidth: CGFloat = 8.5

    // 蜡烛宽度
    static let candleWidth: CGFloat = 8.5

    // 蜡烛中间线的宽度
    static let candleLineWidth: CGFloat = 1.5

    // vol柱子宽度
    static let volWidth: CGFloat = 8.5

    // macd柱子宽度
    static let macdWidth: CGFloat = 3.0

    // 垂直交叉线宽度
    static let vCrossWidth: CGFloat = 8.5

    // 水平交叉线宽度
    static let hCrossWidth: CGFloat = 0.5

    // 网格
    static let gridRows: Int = 4

    static let gridColumns: Int = 5

    static let topPadding: CGFloat = 30.0

    static let bottomDateHigh: CGFloat = 20.0

    static let childPadding: CGFloat = 25.0

    static let defaultTextSize: CGFloat = 10

    static let bottomDatefontSize: CGFloat = 10

    // 表格右边文字价格
    static let reightTextSize: CGFloat = 10
}
