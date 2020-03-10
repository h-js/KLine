//
//  KLineState.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    KLineDirectionVertical,
    KLineDirectionHorizontal,
} KLineDirection;

typedef enum : NSUInteger {
    MainStateMA,
    MainStateBOLL,
    MainStateNONE
} MainState;

typedef enum : NSUInteger {
    VolStateVOL,
    VolStateNONE,
} VolState;

typedef enum : NSUInteger {
    SecondaryStateMacd,
    SecondaryStateKDJ,
    SecondaryStateRSI,
    SecondaryStateWR,
    SecondaryStateNONE,
} SecondaryState;


@interface KLineState : NSObject

@end

NS_ASSUME_NONNULL_END
