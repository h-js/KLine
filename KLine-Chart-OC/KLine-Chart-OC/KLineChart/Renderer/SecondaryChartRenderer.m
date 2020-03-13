//
//  SecondaryChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "SecondaryChartRenderer.h"
#import "ChartStyle.h"
#import "NSString+Rect.h"

@interface SecondaryChartRenderer()

@property(nonatomic,assign) SecondaryState state;
@property(nonatomic,assign) CGFloat mMACDWidth;
@end

@implementation SecondaryChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue
                        minValue:(CGFloat)minValue
                       chartRect:(CGRect)chartRect
                     candleWidth:(CGFloat)candleWidth
                      topPadding:(CGFloat)topPadding
                           state:(SecondaryState)state
{
    if(self = [super initWithMaxValue:maxValue minValue:minValue chartRect:chartRect candleWidth:candleWidth topPadding:topPadding]) {
        self.state = state;
        self.mMACDWidth = 5;
    }
    return self;
}

- (void)drawGrid:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    CGContextSetStrokeColorWithColor(context, ChartColors_gridColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGFloat columsSpace = self.chartRect.size.width / (CGFloat)(gridColums);
    for (int index = 0;  index < gridColums; index++) {
        CGContextMoveToPoint(context, index * columsSpace, 0);
        CGContextAddLineToPoint(context, index * columsSpace, CGRectGetMaxY(self.chartRect));
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}


- (void)drawChart:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    if(_state == SecondaryStateMacd) {
        [self drawMACD:context lastPoit:lastPoint curPoint:curPoint curX:curX];
    } else if (_state == SecondaryStateKDJ) {
        if(lastPoint != nil) {
            if(curPoint.k != 0) {
                [self drawLine:context lastValue:lastPoint.k curValue:curPoint.k curX:curX color:ChartColors_kColor];
            }
            if(curPoint.d != 0) {
                [self drawLine:context lastValue:lastPoint.d curValue:curPoint.d curX:curX color:ChartColors_dColor];
            }
            if(curPoint.j != 0) {
                [self drawLine:context lastValue:lastPoint.j curValue:curPoint.j curX:curX color:ChartColors_jColor];
            }
        }
    } else if (_state == SecondaryStateRSI) {
        if(lastPoint != nil) {
            if(curPoint.rsi != 0) {
                [self drawLine:context lastValue:lastPoint.rsi curValue:curPoint.rsi curX:curX color:ChartColors_rsiColor];
            }
        }
    } else if (_state == SecondaryStateWR) {
           if(lastPoint != nil) {
               if(curPoint.r != 0) {
                   [self drawLine:context lastValue:lastPoint.r curValue:curPoint.r curX:curX color:ChartColors_rsiColor];
               }
           }
    }
}

- (void)drawMACD:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    CGFloat maxdY = [self getY:curPoint.macd];
    CGFloat zeroy = [self getY:0];
    if(curPoint.macd > 0) {
         CGContextSetStrokeColorWithColor(context, ChartColors_upColor.CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, ChartColors_dnColor.CGColor);
    }
    CGContextSetLineWidth(context, self.mMACDWidth);
    CGContextMoveToPoint(context, curX, maxdY);
    CGContextAddLineToPoint(context, curX, zeroy);
    CGContextDrawPath(context, kCGPathStroke);
    if(lastPoint != nil) {
        if(curPoint.dif != 0) {
             [self drawLine:context lastValue:lastPoint.dif curValue:curPoint.dif curX:curX color:ChartColors_difColor];
        }
        if(curPoint.dea != 0) {
             [self drawLine:context lastValue:lastPoint.dea curValue:curPoint.dea curX:curX color:ChartColors_deaColor];
        }
    }
}
- (void)drawRightText:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    NSString *text = [self volFormat:self.maxValue];
    CGRect rect = [text getRectWithFontSize:ChartStyle_reightTextSize];
    [self drawText:text atPoint:CGPointMake(self.chartRect.size.width - rect.size.width, CGRectGetMinY(self.chartRect)) fontSize:ChartStyle_reightTextSize textColor:ChartColors_reightTextColor];
}

- (void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    NSMutableAttributedString *topAttributeText = [[NSMutableAttributedString alloc] init];
    
    switch (_state) {
        case SecondaryStateMacd:
        {
            {
                NSString *str = @"MACD(12,26,9)    ";
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_yAxisTextColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.macd != 0) {
                 NSString *str = [NSString stringWithFormat:@"MACD:%.2f    ", curPoint.macd];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_macdColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.dif != 0) {
                 NSString *str = [NSString stringWithFormat:@"DIF:%.2f    ", curPoint.dif];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_difColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.dea != 0) {
                 NSString *str = [NSString stringWithFormat:@"DEA:%.2f    ", curPoint.dea];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_deaColor}];
                 [topAttributeText appendAttributedString:attr];
             }
        } break;
        case SecondaryStateRSI:
        {
            NSString *str = [NSString stringWithFormat:@"RSI(14):%.2f    ", curPoint.rsi];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_rsiColor}];
            [topAttributeText appendAttributedString:attr];
        } break;
        case SecondaryStateWR:
        {
            NSString *str = [NSString stringWithFormat:@"WR(14):%.2f    ", curPoint.r];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_wrColor}];
            [topAttributeText appendAttributedString:attr];
        } break;
        case SecondaryStateKDJ:
        {
            {
                NSString *str = @"KDJ(14,1,3)    ";
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_yAxisTextColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.k != 0) {
                 NSString *str = [NSString stringWithFormat:@"K:%.2f    ", curPoint.k];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_kColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.d != 0) {
                 NSString *str = [NSString stringWithFormat:@"D:%.2f    ", curPoint.d];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_dColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.j != 0) {
                 NSString *str = [NSString stringWithFormat:@"J:%.2f    ", curPoint.j];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_jColor}];
                 [topAttributeText appendAttributedString:attr];
             }
        } break;
        default:
            break;
    }
    [topAttributeText drawAtPoint:CGPointMake(5, CGRectGetMinY(self.chartRect))];
}



@end
