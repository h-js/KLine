//
//  KLineStateManager.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineChartView.h"
#import "KLineState.h"

NS_ASSUME_NONNULL_BEGIN

@interface KLineStateManager : NSObject

+(instancetype)manager;

@property(nonatomic,weak) KLineChartView *klineChart;

@property(nonatomic,copy) NSString *period;
@property(nonatomic,assign) MainState mainState;
@property(nonatomic,assign) SecondaryState secondaryState;
@property(nonatomic,assign) BOOL isLine;

@property(nonatomic,strong) NSArray *datas;



@end

NS_ASSUME_NONNULL_END
