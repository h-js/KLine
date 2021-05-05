//
//  KLineModel.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

public class KLineModel {
    public var open: CGFloat = 0
    public var high: CGFloat = 0
    public var low: CGFloat = 0
    public var close: CGFloat = 0
    public var vol: CGFloat = 0
    public var amount: CGFloat = 0
    public var count: Int64 = 0
    public var id: Int64 = 0

    public var MA5Price: CGFloat = 0
    public var MA10Price: CGFloat = 0
    public var MA20Price: CGFloat = 0
    public var MA30Price: CGFloat = 0

    public var mb: CGFloat = 0
    public var up: CGFloat = 0
    public var dn: CGFloat = 0

    public var dif: CGFloat = 0
    public var dea: CGFloat = 0
    public var macd: CGFloat = 0
    public var ema12: CGFloat = 0
    public var ema26: CGFloat = 0

    public var MA5Volume: CGFloat = 0
    public var MA10Volume: CGFloat = 0

    public var rsi: CGFloat = 0
    public var rsiABSEma: CGFloat = 0
    public var rsiMaxEma: CGFloat = 0

    public var k: CGFloat = 0
    public var d: CGFloat = 0
    public var j: CGFloat = 0

    public var r: CGFloat = 0

    public init() {}

    public init(dict: [String: Any]) {
        open = dict["open"] as? CGFloat ?? 0.0
        high = dict["high"] as? CGFloat ?? 0.0
        low = dict["low"] as? CGFloat ?? 0.0
        close = dict["close"] as? CGFloat ?? 0.0
        vol = dict["vol"] as? CGFloat ?? 0.0
        amount = dict["amount"] as? CGFloat ?? 0.0
        count = dict["count"] as? Int64 ?? 0
        id = dict["id"] as? Int64 ?? 0
    }
}
