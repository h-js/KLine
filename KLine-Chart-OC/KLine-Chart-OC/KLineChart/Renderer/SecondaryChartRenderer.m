//
//  SecondaryChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "SecondaryChartRenderer.h"
@interface SecondaryChartRenderer()
@property(nonatomic,assign) SecondaryState state;

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
    }
    return self;
}


@end
