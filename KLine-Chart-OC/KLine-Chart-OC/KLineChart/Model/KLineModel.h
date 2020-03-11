//
//  KLineModel.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KLineModel : NSObject

@property(nonatomic,assign) CGFloat open;
@property(nonatomic,assign) CGFloat high;
@property(nonatomic,assign) CGFloat low;
@property(nonatomic,assign) CGFloat close;

@property(nonatomic,assign) CGFloat vol;
@property(nonatomic,assign) CGFloat amount;
@property(nonatomic,assign) CGFloat count;
@property(nonatomic,assign) double id;

@property(nonatomic,assign) CGFloat MA5Price;
@property(nonatomic,assign) CGFloat MA10Price;
@property(nonatomic,assign) CGFloat MA20Price;
@property(nonatomic,assign) CGFloat MA30Price;

@property(nonatomic,assign) CGFloat mb;
@property(nonatomic,assign) CGFloat up;
@property(nonatomic,assign) CGFloat dn;

@property(nonatomic,assign) CGFloat dif;
@property(nonatomic,assign) CGFloat dea;
@property(nonatomic,assign) CGFloat macd;
@property(nonatomic,assign) CGFloat ema12;
@property(nonatomic,assign) CGFloat ema26;

@property(nonatomic,assign) CGFloat MA5Volume;
@property(nonatomic,assign) CGFloat MA10Volume;

@property(nonatomic,assign) CGFloat rsi;
@property(nonatomic,assign) CGFloat rsiABSEma;
@property(nonatomic,assign) CGFloat rsiMaxEma;

@property(nonatomic,assign) CGFloat k;
@property(nonatomic,assign) CGFloat d;
@property(nonatomic,assign) CGFloat j;
@property(nonatomic,assign) CGFloat r;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
