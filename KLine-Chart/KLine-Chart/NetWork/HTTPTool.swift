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
    
   
    func getData(period: String,complationBlock: @escaping (([KLineModel]) -> Void)) {
        currentDataTask?.cancel()
        let url = URL(string: "https://api.huobi.pro/market/history/kline?period=\(period)&size=300&symbol=btcusdt")
        
        let requst = URLRequest(url: url!)
        
        let session: URLSession = URLSession.shared
        
        let dataTask: URLSessionDataTask = session.dataTask(with: requst) { (data, response, error) in
            if error == nil, let _data = data {
                let dict = try! JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                print(dict)
                if let dicts = dict["data"] as? [[String:Any]] {
                    let datas =  dicts.map { (dict) -> KLineModel in
                        return KLineModel(dict: dict)
                    }
                    DispatchQueue.main.async {
                         complationBlock(datas)
                    }
                    return
                }
            }
            let datas = self.getLocalData()
             DispatchQueue.main.async {
                  complationBlock(datas)
             }
            
        }
        self.currentDataTask = dataTask
        dataTask.resume()
    }
    
    func getLocalData() -> [KLineModel] {
        let path =  Bundle.main.path(forResource: "kline", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let dicts = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:Any]]
        let datas =  dicts.map { (dict) -> KLineModel in
             return KLineModel(dict: dict)
             }
        return datas
    }
    
}
