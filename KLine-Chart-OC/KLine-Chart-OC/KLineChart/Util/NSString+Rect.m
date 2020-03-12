//
//  NSString+Rect.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/12.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "NSString+Rect.h"



@implementation NSString (Rect)

-(CGRect)getRectWithFontSize:(CGFloat)fontSize {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil];
    return rect;
}

@end
