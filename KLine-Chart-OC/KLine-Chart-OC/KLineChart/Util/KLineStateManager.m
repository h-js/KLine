//
//  KLineStateManager.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineStateManager.h"
#import "HTTPTool.h"
#import "DataUtil.h"

static KLineStateManager *_manager = nil;
@implementation KLineStateManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mainState = MainStateMA;
        _secondaryState = SecondaryStateMacd;
        _isLine = false;
    }
    return self;
}

+(instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)setKlineChart:(KLineChartView *)klineChart {
    _klineChart = klineChart;
    _klineChart.mainState = _mainState;
    _klineChart.secondaryState = _secondaryState;
    _klineChart.isLine = _isLine;
    _klineChart.datas = _datas;
}

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    _klineChart.datas = datas;
}

- (void)setMainState:(MainState)mainState {
    _mainState = mainState;
    _klineChart.mainState = mainState;
}
-(void)setSecondaryState:(SecondaryState)secondaryState {
    _secondaryState = secondaryState;
    _klineChart.secondaryState = secondaryState;
}

-(void)setIsLine:(BOOL)isLine {
    _isLine = isLine;
    _klineChart.isLine = isLine;
}

-(void)setPeriod:(NSString *)period {
    _period = period;
    self.datas = [NSArray array];
    [[HTTPTool tool] getData:period complation:^(NSArray<KLineModel *> * _Nonnull models) {
        [DataUtil calculate:models];
        self.datas = models;
    }];
}



@end
