//
//  MainChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "MainChartRenderer.h"
@interface MainChartRenderer()
@property(nonatomic,assign) BOOL isLine;
@property(nonatomic,assign) CGFloat contentPadding;
@property(nonatomic,assign) MainState state;

@end


@implementation MainChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue minValue:(CGFloat)minValue chartRect:(CGRect)chartRect candleWidth:(CGFloat)candleWidth topPadding:(CGFloat)topPadding isLine:(BOOL)isLine state:(MainState)state {
    if (self = [super initWithMaxValue:maxValue minValue:minValue chartRect:chartRect candleWidth:candleWidth topPadding:topPadding]) {
        self.isLine = isLine;
        self.state = state;
        CGFloat diff = maxValue - minValue;
        CGFloat newscaly = (chartRect.size.height - _contentPadding)/ diff;
        CGFloat newDiff = chartRect.size.height / newscaly;
        CGFloat value = (newDiff - diff) / 2;
        if(newDiff > diff) {
            self.scaleY = newscaly;
            self.maxValue += value;
            self.minValue -= value;
        }
    }
    return self;
}

@end
