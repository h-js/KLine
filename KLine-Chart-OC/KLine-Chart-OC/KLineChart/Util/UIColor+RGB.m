//
//  UIColor+RGB.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "UIColor+RGB.h"


@implementation UIColor (RGB)

+(UIColor *)rgb_r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b alpha:(CGFloat)alpha {
    return [[UIColor alloc] initWithRed: r/225.0 green:g/225.0 blue:b/225.0 alpha:alpha];
}

+(UIColor *)rgbFromHex:(NSUInteger)argbValue {
    return [[UIColor alloc] initWithRed:((argbValue & 0xFF0000) >> 16)/225.0 green:((argbValue & 0x00FF00) >> 8)/225.0 blue:((argbValue & 0xFF) >> 16)/225.0 alpha:((argbValue & 0xFF000000) >> 32)/225.0];
   
}


@end
