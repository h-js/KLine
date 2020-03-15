//
//  VolChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "VolChartRenderer.h"
#import "ChartStyle.h"
#import "NSString+Rect.h"

@implementation VolChartRenderer

- (void)drawGrid:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    CGContextSetStrokeColorWithColor(context, ChartColors_gridColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGFloat columsSpace = self.chartRect.size.width / (CGFloat)(gridColums);
    for (int index = 0;  index < gridColums; index++) {
        CGContextMoveToPoint(context, index * columsSpace, 0);
        CGContextAddLineToPoint(context, index * columsSpace, CGRectGetMaxY(self.chartRect));
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    CGContextAddRect(context, self.chartRect);
    CGContextDrawPath(context, kCGPathStroke);
    
}
- (void)drawChart:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    [self drawVolChat:context curPoint:curPoint curX:curX];
    if(lastPoint != nil){
        if(curPoint.MA5Volume != 0) {
            [self drawLine:context lastValue:lastPoint.MA5Volume curValue:curPoint.MA5Volume curX:curX color:ChartColors_ma5Color];
        }
        if(curPoint.MA10Volume != 0) {
            [self drawLine:context lastValue:lastPoint.MA10Volume curValue:curPoint.MA10Volume curX:curX color:ChartColors_ma10Color];
        }
    }
}

- (void)drawVolChat:(CGContextRef)context curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    CGFloat top = [self getY:curPoint.vol];
    CGContextSetLineWidth(context, self.candleWidth);
    if(curPoint.close > curPoint.open) {
        CGContextSetStrokeColorWithColor(context, ChartColors_upColor.CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, ChartColors_dnColor.CGColor);
    }
    CGContextMoveToPoint(context, curX, CGRectGetMaxY(self.chartRect));
    CGContextAddLineToPoint(context, curX, top);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    NSMutableAttributedString *topAttributeText = [[NSMutableAttributedString alloc] init];
    {
        NSString *str = [NSString stringWithFormat:@"VOL:%@   ", [self volFormat:curPoint.vol]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_volColor}];
        [topAttributeText appendAttributedString:attr];
    }
    {
        NSString *str = [NSString stringWithFormat:@"MA5:%@    ", [self volFormat:curPoint.MA5Volume]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_ma5Color}];
        [topAttributeText appendAttributedString:attr];
    }
   {
        NSString *str = [NSString stringWithFormat:@"MA10:%@   ",[self volFormat:curPoint.MA10Volume]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_ma10Color}];
        [topAttributeText appendAttributedString:attr];
    }
    [topAttributeText drawAtPoint:CGPointMake(5, CGRectGetMinY(self.chartRect))];
}

- (void)drawRightText:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    NSString *text = [self volFormat:self.maxValue];
    CGRect rect = [text getRectWithFontSize:ChartStyle_reightTextSize];
    [self drawText:text atPoint:CGPointMake(self.chartRect.size.width - rect.size.width, CGRectGetMinY(self.chartRect)) fontSize:ChartStyle_reightTextSize textColor:ChartColors_reightTextColor];
}

@end
