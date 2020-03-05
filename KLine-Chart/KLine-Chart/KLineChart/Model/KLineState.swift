//
//  KLineState.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import Foundation
enum KLineDirection: Int {
    case vertical   //竖屏布局
    case horizontal //横屏布局
}

enum MainState: Int {
    case ma
    case boll
    case none
}

enum VolState: Int {
    case vol
    case none
}

enum SecondaryState: Int {
    case macd
    case kdj
    case rsi
    case wr
    case none
}
