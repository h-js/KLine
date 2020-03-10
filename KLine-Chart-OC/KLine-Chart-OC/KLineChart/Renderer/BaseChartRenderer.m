//
//  BaseChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "BaseChartRenderer.h"


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
    
}

@end
