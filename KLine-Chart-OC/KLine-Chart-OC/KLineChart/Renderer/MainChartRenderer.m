//
//  MainChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "MainChartRenderer.h"
#import "ChartStyle.h"
#import "NSString+Rect.h"
@interface MainChartRenderer()
@property(nonatomic,assign) BOOL isLine;
@property(nonatomic,assign) CGFloat contentPadding;
@property(nonatomic,assign) MainState state;

@end


@implementation MainChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue minValue:(CGFloat)minValue chartRect:(CGRect)chartRect candleWidth:(CGFloat)candleWidth topPadding:(CGFloat)topPadding isLine:(BOOL)isLine state:(MainState)state {
    if (self = [super initWithMaxValue:maxValue minValue:minValue chartRect:chartRect candleWidth:candleWidth topPadding:topPadding]) {
        self.contentPadding = 20;
        self.isLine = isLine;
        self.state = state;
        CGFloat diff = maxValue - minValue;
        CGFloat newscaly = 1;
        CGFloat newDiff = 0;
        CGFloat value = 0;
        if(diff != 0) {
            newscaly = (chartRect.size.height - _contentPadding)/ diff;
            newDiff = chartRect.size.height / newscaly;
            value = (newDiff - diff) / 2;
        }
        if(newDiff > diff) {
            self.scaleY = newscaly;
            self.maxValue += value;
            self.minValue -= value;
        }
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
    CGFloat rowSpace = self.chartRect.size.height / (CGFloat)gridRows;
    for (int index = 0;  index < gridRows; index++) {
         CGContextMoveToPoint(context, 0, index * rowSpace + ChartStyle_topPadding);
         CGContextAddLineToPoint(context, CGRectGetMaxX(self.chartRect), index * rowSpace + ChartStyle_topPadding);
         CGContextDrawPath(context, kCGPathFillStroke);
     }
    CGContextAddRect(context, self.chartRect);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawChart:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    if(!_isLine) {
        [self drawCandle:context curPoint:curPoint curX:curX];
    }
    if (lastPoint != nil) {
        if(_isLine) {
            [self drawKLine:context lastValue:lastPoint.close curValue:curPoint.close curX:curX];
        } else if (_state == MainStateMA) {
            [self drawMaLine:context lastPoit:lastPoint curPoint:curPoint curX:curX];
        } else if (_state == MainStateBOLL) {
            [self drawBollLine:context lastPoit:lastPoint curPoint:curPoint curX:curX];
        }
    }
}

- (void)drawKLine:(CGContextRef)context lastValue:(CGFloat)lastValue curValue:(CGFloat)curValue curX:(CGFloat)curX  {
    CGFloat x1 = curX;
    CGFloat y1 = [self getY:curValue];
    CGFloat x2 = curX + self.candleWidth + ChartStyle_canldeMargin;
    CGFloat y2 = [self getY:lastValue];
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, ChartColors_kLineColor.CGColor);
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddCurveToPoint(context, (x1 + x2) / 2.0, y1,  (x1 + x2) / 2.0, y2, x2, y2);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, x1, CGRectGetMaxY(self.chartRect));
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, x1, y1);
    CGPathAddCurveToPoint(path, &CGAffineTransformIdentity, (x1 + x2) / 2.0, y1, (x1 + x2) / 2.0, y2, x2, y2);
    CGPathAddLineToPoint(path,  &CGAffineTransformIdentity, x2, CGRectGetMaxY(self.chartRect));
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    
    CGContextClip(context);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0,1};
    NSArray *colors = @[(__bridge id)[UIColor rgb_r:0x4c g:0x86 b:0xCD alpha:1].CGColor, (__bridge id)[UIColor rgb_r:0x00 g:0x00 b:0x00 alpha:0].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    CGColorSpaceRelease(colorSpace);
    CGPoint start = CGPointMake((x1 + x2) / 2, CGRectGetMinY(self.chartRect));
    CGPoint end = CGPointMake((x1 + x2) / 2, CGRectGetMaxY(self.chartRect));
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    CGContextResetClip(context);
    
    CGColorSpaceRelease(colorSpace);
    CGPathRelease(path);
    CGGradientRelease(gradient);
    
}

- (void)drawMaLine:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    if(curPoint.MA5Price != 0) {
        [self drawLine:context lastValue:lastPoint.MA5Price curValue:curPoint.MA5Price curX:curX color:ChartColors_ma5Color];
    }
    if(curPoint.MA10Price != 0) {
           [self drawLine:context lastValue:lastPoint.MA10Price curValue:curPoint.MA10Price curX:curX color:ChartColors_ma10Color];
    }
    if(curPoint.MA30Price != 0) {
           [self drawLine:context lastValue:lastPoint.MA30Price curValue:curPoint.MA30Price curX:curX color:ChartColors_ma30Color];
    }
}


- (void)drawBollLine:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    if(curPoint.up != 0) {
        [self drawLine:context lastValue:lastPoint.up curValue:curPoint.up curX:curX color:ChartColors_ma5Color];
    }
    if(curPoint.mb != 0) {
           [self drawLine:context lastValue:lastPoint.mb curValue:curPoint.mb curX:curX color:ChartColors_ma10Color];
    }
    if(curPoint.dn != 0) {
           [self drawLine:context lastValue:lastPoint.dn curValue:curPoint.dn curX:curX color:ChartColors_ma30Color];
    }
}


- (void)drawCandle:(CGContextRef)context curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    CGFloat high = [self getY:curPoint.high];
    CGFloat low = [self getY:curPoint.low];
    CGFloat open = [self getY:curPoint.open];
    CGFloat close = [self getY:curPoint.close];
    UIColor *color = ChartColors_dnColor;
    
    if(open > close) {
        color = ChartColors_upColor;
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, ChartStyle_candleLineWidth);
    CGContextMoveToPoint(context, curX, high);
    CGContextAddLineToPoint(context, curX, low);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, self.candleWidth);
    CGContextMoveToPoint(context, curX, open);
    CGContextAddLineToPoint(context, curX, close);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

- (void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    NSMutableAttributedString *topAttributeText = [[NSMutableAttributedString alloc] init];
    if(curPoint.MA5Price != 0) {
        NSString *str = [NSString stringWithFormat:@"MA5:%.2f   ",curPoint.MA5Price];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_ma5Color}];
        [topAttributeText appendAttributedString:attr];
    }
    if(curPoint.MA10Price != 0) {
        NSString *str = [NSString stringWithFormat:@"MA10:%.2f    ",curPoint.MA10Price];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_ma10Color}];
        [topAttributeText appendAttributedString:attr];
    }
    if(curPoint.MA30Price != 0) {
        NSString *str = [NSString stringWithFormat:@"MA30:%.2f   ",curPoint.MA30Price];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:ChartStyle_defaultTextSize],NSForegroundColorAttributeName: ChartColors_ma30Color}];
        [topAttributeText appendAttributedString:attr];
    }
    [topAttributeText drawAtPoint:CGPointMake(5, 6)];
}

- (void)drawRightText:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    CGFloat rowSpace = self.chartRect.size.height / (CGFloat)gridRows;
    for (int i = 0; i <= gridRows; i++) {
        CGFloat position = 0;
        position = (CGFloat)(gridRows - i) * rowSpace;
        CGFloat value = position / self.scaleY + self.minValue;
        NSString *valueStr = [NSString stringWithFormat:@"%.2f",value];
        CGRect rect = [valueStr getRectWithFontSize:ChartStyle_reightTextSize];
        CGFloat y = 0;
        if(i == 0) {
            y = [self getY:value];
        } else {
            y = [self getY:value] - rect.size.height;
        }
        [self drawText:valueStr atPoint:CGPointMake(self.chartRect.size.width - rect.size.width, y) fontSize:ChartStyle_reightTextSize textColor:ChartColors_reightTextColor];
    }
}


- (CGFloat)getY:(CGFloat)value {
    return self.scaleY * (self.maxValue - value) + CGRectGetMinY(self.chartRect);
}

@end
