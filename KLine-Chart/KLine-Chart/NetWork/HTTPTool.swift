//
//  HTTPTool.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/4.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit

class HTTPTool: NSObject {
    static let tool = HTTPTool()

    var currentDataTask: URLSessionDataTask?

    func getData(period: String, complationBlock: @escaping (([KLineModel]) -> Void)) {
        currentDataTask?.cancel()
        let url = URL(string: "https://api.huobi.pro/market/history/kline?period=\(period)&size=2000&symbol=btcusdt")

        let requst = URLRequest(url: url!)

        let session: URLSession = URLSession.shared

        let dataTask: URLSessionDataTask = session.dataTask(with: requst) { data, _, error in
            if error == nil, let _data = data {
                guard let dict = try? JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                    fatalError()
                }
                print(dict)
                if let dicts = dict["data"] as? [[String: Any]] {
                    let datas = dicts.map { (dict) -> KLineModel in
                        KLineModel(dict: dict)
                    }
                    var addDatas: [KLineModel] = []
                    var newDatas: [KLineModel] = []
                    for idx in 0 ..< datas.count {
                        if idx < 100 {
                            addDatas.append(datas[idx])
                        } else {
                            newDatas.append(datas[idx])
                        }
                    }
                    KLineStateManger.manager.addDatas = addDatas
                    DispatchQueue.main.async {
                        complationBlock(newDatas)
                    }
                    return
                }
            }
            let datas = self.getLocalData()
            DispatchQueue.main.async {
                complationBlock(datas)
            }
        }
        currentDataTask = dataTask
        dataTask.resume()
    }

    func getLocalData() -> [KLineModel] {
        guard let path = Bundle.main.path(forResource: "kline", ofType: "json") else {
            fatalError()
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError()
        }
        guard let dicts = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: Any]] else {
            fatalError()
        }
        let datas = dicts.map { (dict) -> KLineModel in
            KLineModel(dict: dict)
        }
        return datas
    }
}
