//
//  DataUtil.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit
class DataUtil {
    
    static func calculate(dataList: [KLineModel]) {
      let _dataList = dataList.reversed() as [KLineModel]
      calcMA(_dataList);
      calcBOLL(_dataList);
      calcVolumeMA(_dataList);
      calcKDJ(_dataList);
      calcMACD(_dataList);
      calcRSI(_dataList);
      calcWR(_dataList);
    }
    
    //增量更新时计算最后一个数据
    static func addLastData(dataList: [KLineModel], data: KLineModel) {
         var _dataList = dataList.reversed() as [KLineModel]
        _dataList.append(data)
        calcMA(_dataList, isLast: true);
        calcBOLL(_dataList, isLast: true);
        calcVolumeMA(_dataList, isLast: true);
        calcKDJ(_dataList, isLast: true);
        calcMACD(_dataList, isLast: true);
        calcRSI(_dataList, isLast: true);
        calcWR(_dataList, isLast: true);
     }
    
    
    static func calcMA(_ dataList: [KLineModel],isLast: Bool = false) {
        var ma5: CGFloat = 0;
        var ma10: CGFloat = 0;
        var ma20: CGFloat = 0;
        var ma30: CGFloat = 0;
        var start_index: Int = 0
        if isLast && dataList.count > 1 {
            start_index = dataList.count - 1;
            let data = dataList[dataList.count - 2];
            ma5 = data.MA5Price * 5;
            ma10 = data.MA10Price * 10;
            ma20 = data.MA20Price * 20;
            ma30 = data.MA30Price * 30;
        }
        
        for i in start_index..<dataList.count {
             let entity = dataList[i]
             let closePrice = entity.close;
             ma5 += closePrice;
             ma10 += closePrice;
             ma20 += closePrice;
             ma30 += closePrice;
            if (i == 4) {
              entity.MA5Price = ma5 / 5;
            } else if (i >= 5) {
              ma5 -= dataList[i - 5].close;
              entity.MA5Price = ma5 / 5;
            } else {
              entity.MA5Price = 0;
            }
            if (i == 9) {
              entity.MA10Price = ma10 / 10;
            } else if (i >= 10) {
              ma10 -= dataList[i - 10].close;
              entity.MA10Price = ma10 / 10;
            } else {
              entity.MA10Price = 0;
            }
            if (i == 19) {
              entity.MA20Price = ma20 / 20;
            } else if (i >= 20) {
              ma20 -= dataList[i - 20].close;
              entity.MA20Price = ma20 / 20;
            } else {
              entity.MA20Price = 0;
            }
            if (i == 29) {
              entity.MA30Price = ma30 / 30;
            } else if (i >= 30) {
              ma30 -= dataList[i - 30].close;
              entity.MA30Price = ma30 / 30;
            } else {
              entity.MA30Price = 0;
            }
        }
    }
    
    static func calcBOLL(_ dataList: [KLineModel],isLast: Bool = false)  {
        var startIndex: Int = 0;
        if (isLast && dataList.count > 1) {
          startIndex = dataList.count - 1
        }
       for i in startIndex..<dataList.count {
            let entity = dataList[i]
            if (i < 19) {
              entity.mb = 0;
              entity.up = 0;
              entity.dn = 0;
            } else {
                let n: Int = 20
                var md: CGFloat = 0;
                for j in (i - n + 1)...i {
                    let c: CGFloat = dataList[j].close;
                    let m: CGFloat = entity.MA20Price;
                    let value: CGFloat = c - m;
                    md += value * value;
                }
              md = md / CGFloat(n - 1);
              md = sqrt(md);
              entity.mb = entity.MA20Price;
              entity.up = entity.mb + 2.0 * md;
              entity.dn = entity.mb - 2.0 * md;
            }
        }
    }
    
     static func calcMACD(_ dataList: [KLineModel],isLast: Bool = false)  {
        var ema12: CGFloat = 0;
        var ema26: CGFloat = 0;
        var dif: CGFloat = 0;
        var dea: CGFloat = 0;
        var macd: CGFloat = 0;
        
        var i = 0
        if isLast && dataList.count > 1 {
            i = dataList.count - 1;
            let data = dataList[dataList.count - 2];
            dif = data.dif;
            dea = data.dea;
            macd = data.macd;
            ema12 = data.ema12;
            ema26 = data.ema26;
        }
       for index in i..<dataList.count  {
            let entity = dataList[index];
            let closePrice = entity.close;
            if (index == 0) {
              ema12 = closePrice;
              ema26 = closePrice;
            } else {
              // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
              ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
              // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
              ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
            }
            // DIF = EMA（12） - EMA（26） 。
            // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
            // 用（DIF-DEA）*2即为MACD柱状图。
            dif = ema12 - ema26;
            dea = dea * 8 / 10 + dif * 2 / 10;
            macd = (dif - dea) * 2;
            entity.dif = dif;
            entity.dea = dea;
            entity.macd = macd;
            entity.ema12 = ema12;
            entity.ema26 = ema26;
        }
    }
    
    static func calcVolumeMA(_ dataList: [KLineModel],isLast: Bool = false)  {
        var  volumeMa5: CGFloat = 0;
        var  volumeMa10: CGFloat = 0;
        var starti: Int = 0;
        if isLast && dataList.count > 1 {
            starti = dataList.count - 1;
            let data = dataList[dataList.count - 2];
            volumeMa5 = data.MA5Volume * 5;
            volumeMa10 = data.MA10Volume * 10;
        }
        for i in starti..<dataList.count{
            let entry = dataList[i];
            volumeMa5 += entry.vol;
            volumeMa10 += entry.vol;
            if (i == 4) {
              entry.MA5Volume = (volumeMa5 / 5);
            } else if (i > 4) {
              volumeMa5 -= dataList[i - 5].vol;
              entry.MA5Volume = volumeMa5 / 5;
            } else {
              entry.MA5Volume = 0;
            }
            if (i == 9) {
              entry.MA10Volume = volumeMa10 / 10;
            } else if (i > 9) {
              volumeMa10 -= dataList[i - 10].vol;
              entry.MA10Volume = volumeMa10 / 10;
            } else {
              entry.MA10Volume = 0;
            }
        }
    }
    
    static func calcRSI(_ dataList: [KLineModel],isLast: Bool = false)  {
        var rsi: CGFloat = 0;
        var rsiABSEma: CGFloat = 0;
        var rsiMaxEma: CGFloat = 0;
        var startIndex = 0;
        if (isLast && dataList.count > 1) {
          startIndex = dataList.count - 1;
          let data = dataList[dataList.count - 2];
          rsi = data.rsi;
          rsiABSEma = data.rsiABSEma;
          rsiMaxEma = data.rsiMaxEma;
        }
        for i in startIndex..<dataList.count {
            let entity = dataList[i];
            let closePrice = entity.close;
            if (i == 0) {
              rsi = 0;
              rsiABSEma = 0;
              rsiMaxEma = 0;
            } else {
              let Rmax = max(0, closePrice - dataList[i - 1].close);
              let RAbs = abs((closePrice - dataList[i - 1].close));
              rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
              rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
              rsi = (rsiMaxEma / rsiABSEma) * 100;
            }
            if (i < 13) { rsi = 0; }
            if (rsi.isNaN) { rsi = 0; }
            entity.rsi = rsi;
            entity.rsiABSEma = rsiABSEma;
            entity.rsiMaxEma = rsiMaxEma;
        }
    }
    
    static func calcKDJ(_ dataList: [KLineModel],isLast: Bool = false)  {
        var k: CGFloat = 0;
        var d: CGFloat = 0;
        var _startIndex: Int = 0;
        if (isLast && dataList.count > 1) {
          _startIndex = dataList.count - 1;
          let data = dataList[dataList.count - 2];
          k = data.k;
          d = data.d;
        }
        for i in _startIndex..<dataList.count {
            let entity = dataList[i];
            let closePrice = entity.close;
            var startIndex = i - 13;
            if (startIndex < 0) {
              startIndex = 0;
            }
            var max14 = CGFloat(-MAXFLOAT);
            var min14 = CGFloat(MAXFLOAT);
//            for (int index = startIndex; index <= i; index++) {
//              max14 = max(max14, dataList[index].high);
//              min14 = min(min14, dataList[index].low);
//            }
            for index in startIndex...i {
                max14 = max(max14, dataList[index].high);
                min14 = min(min14, dataList[index].low);
            }
            var rsv = 100 * (closePrice - min14) / (max14 - min14);
            if (rsv.isNaN) {
              rsv = 0;
            }
            if (i == 0) {
              k = 50;
              d = 50;
            } else {
              k = (rsv + 2 * k) / 3;
              d = (k + 2 * d) / 3;
            }
            if (i < 13) {
              entity.k = 0;
              entity.d = 0;
              entity.j = 0;
            } else if (i == 13 || i == 14) {
              entity.k = k;
              entity.d = 0;
              entity.j = 0;
            } else {
              entity.k = k;
              entity.d = d;
              entity.j = 3 * k - 2 * d;
            }
        }
    }
    
    
    static func calcWR(_ dataList: [KLineModel],isLast: Bool = false)  {
         var i_index = 0;
         if (isLast && dataList.count > 1) {
           i_index = dataList.count - 1;
         }
        for i in i_index..<dataList.count {
            let entity = dataList[i];
            var startIndex: Int = i - 14;
            if (startIndex < 0) {
              startIndex = 0;
            }
            var max14 = CGFloat(-MAXFLOAT);
            var min14 = CGFloat(MAXFLOAT);
            
//            for (int index = startIndex; index <= i; index++) {
//              max14 = max(max14, dataList[index].high);
//              min14 = min(min14, dataList[index].low);
//            }
            for index in startIndex...i {
                max14 = max(max14, dataList[index].high);
                min14 = min(min14, dataList[index].low);
            }
            if (i < 13) {
              entity.r = 0;
            } else {
              if ((max14 - min14) == 0) {
                entity.r = 0;
              } else {
                entity.r = 100 * (max14 - dataList[i].close) / (max14 - min14);
              }
            }
        }
    }
    
    
}
