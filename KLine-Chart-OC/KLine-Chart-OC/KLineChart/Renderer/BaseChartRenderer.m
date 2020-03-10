//
//  BaseChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "BaseChartRenderer.h"
#import "ChartStyle.h"


@implementation BaseChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue
                        minValue:(CGFloat)minValue
                       chartRect:(CGRect)chartRect
                     candleWidth:(CGFloat)candleWidth
                      topPadding:(CGFloat)topPadding
{
    self = [super init];
    if (self) {
        self.maxValue = maxValue;
        self.minValue = minValue;
        self.chartRect = chartRect;
        self.candleWidth = candleWidth;
        self.topPadding = topPadding;
        _scaleY = (chartRect.size.height - topPadding) / (maxValue - minValue);
    }
    return self;
}

-(void)drawGrid:(CGContextRef)context
       gridRows:(NSUInteger)gridRows
     gridColums:(NSUInteger)gridColums {
    
}

-(void)drawRightText:(CGContextRef)context
            gridRows:(NSUInteger)gridRows
          gridColums:(NSUInteger)gridColums {
    
}

-(void)drawTopText:(CGContextRef)context
          curPoint:(KLineModel *)curPoint {
    
}
-(void)drawBg:(CGContextRef)context {
    CGContextClipToRect(context, _chartRect);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat compoents[] = {(0x0E/255), (0x19/255), (0x25/255), 1,
        (0x0E/255), (0x20/255), (0x34/255), 1};
    CGFloat locations[] = {0,1};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);
    CGPoint start = CGPointMake(_chartRect.size.width / 2, CGRectGetMinY(_chartRect));
    CGPoint end = CGPointMake(_chartRect.size.width / 2, CGRectGetMaxY(_chartRect));
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation);
    CGContextResetClip(context);
}

-(void)drawChart:(CGContextRef)context
        lastPoit:(KLineModel *)lastPoint
        curPoint:(KLineModel *)curPoint
            curX:(CGFloat)curX {
    
}
-(void)drawLine:(CGContextRef)context
      lastValue:(CGFloat)lastValue
       curValue:(CGFloat)curValue
           curX:(CGFloat)curX
          color:(UIColor *)color {
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGFloat x1 = curX;
    CGFloat y1 = [self getY:curValue];
    CGFloat x2 = curX + _candleWidth + ChartStyle_canldeMargin;
    CGFloat y2 = [self getY:lastValue];
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(CGFloat)getY:(CGFloat)value {
    return _scaleY * (_maxValue - value) + CGRectGetMinY(_chartRect) + _topPadding;
}

@end
