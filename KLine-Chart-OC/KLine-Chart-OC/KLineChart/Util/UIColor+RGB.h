//
//  UIColor+RGB.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (RGB)

+(UIColor *)rgb_r:(CGFloat)r g:(CGFloat)g b:(CGFloat)b alpha:(CGFloat)alpha;

+(UIColor *)rgbFromHex:(NSUInteger)argbValue;

@end

NS_ASSUME_NONNULL_END
