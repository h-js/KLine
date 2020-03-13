//
//  KLineInfoView.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KLineInfoView : UIView
@property(nonatomic,strong) KLineModel *model;
+(instancetype)lineInfoView;
@end

NS_ASSUME_NONNULL_END
