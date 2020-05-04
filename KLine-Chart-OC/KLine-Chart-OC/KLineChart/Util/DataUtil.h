//
//  DataUtil.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataUtil : NSObject
+(void)calculate:(NSArray<KLineModel *> *)dataList;
+(void)addLastData:(NSArray<KLineModel *> *)dataList data:(KLineModel *)model;
@end

NS_ASSUME_NONNULL_END
