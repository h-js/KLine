//
//  UIColor+RGB.swift
//  KLine-Chart
//
//  Created by 何俊松 on 2020/3/1.
//  Copyright © 2020 hjs. All rights reserved.
//

import UIKit
//颜色转换
extension UIColor {
    
    static func rgb(r:CGFloat,_ g:CGFloat,_ b:CGFloat,alpha : CGFloat = 1) -> UIColor {
        return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: alpha)
    }
    
    //16进制转换
    static func rgbFromHex(_ argbValue: Int) -> (UIColor) {
        return UIColor(red: ((CGFloat)((argbValue & 0xFF0000) >> 16)) / 255.0,green: ((CGFloat)((argbValue & 0xFF00) >> 8)) / 255.0,blue: ((CGFloat)(argbValue & 0xFF)) / 255.0,alpha: ((CGFloat)((argbValue & 0xFF000000) >> 24)) / 255.0)
    }

}

func Color(_ value: Int) -> UIColor {
    return UIColor.rgbFromHex(value)
}
