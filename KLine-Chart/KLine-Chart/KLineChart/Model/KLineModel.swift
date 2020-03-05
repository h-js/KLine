//
//  KLineModel.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class KLineModel {
    var open: CGFloat = 0
    var high: CGFloat = 0
    var low: CGFloat = 0
    var close: CGFloat = 0
    var vol: CGFloat = 0
    var amount: CGFloat = 0
    var count: Int64 = 0
    var id: Int64 = 0
    
    var MA5Price: CGFloat = 0
    var MA10Price: CGFloat = 0
    var MA20Price: CGFloat = 0
    var MA30Price: CGFloat = 0
    
    var mb: CGFloat = 0
    var up: CGFloat = 0
    var dn: CGFloat = 0
    
    
    var dif: CGFloat = 0
    var dea: CGFloat = 0
    var macd: CGFloat = 0
    var ema12: CGFloat = 0
    var ema26: CGFloat = 0
    
    var MA5Volume: CGFloat = 0
    var MA10Volume: CGFloat = 0
    
    
    var rsi: CGFloat = 0
    var rsiABSEma: CGFloat = 0
    var rsiMaxEma: CGFloat = 0
    
    
    var k: CGFloat = 0
    var d: CGFloat = 0
    var j: CGFloat = 0
    
    var r: CGFloat = 0
    
    
    
    
    init() {
        
    }
    
    init(dict: [String: Any]) {
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
