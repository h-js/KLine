//
//  HTTPTool.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/11.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KLineModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HTTPTool : NSObject
+(instancetype)tool;

-(void)getData:(NSString *)period
    complation:(void(^)(NSArray<KLineModel *> *models))complationBlock;
@end

NS_ASSUME_NONNULL_END
