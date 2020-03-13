//
//  ViewController.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "ViewController.h"
#import "KLineChartView.h"
#import "KLinePeriodView.h"
#import "KLineIndicatorsView.h"
#import "KLineVerticalIndicatorsView.h"
#import "UIColor+RGB.h"
#import "HTTPTool.h"
#import "DataUtil.h"
#import "KLineStateManager.h"

@interface ViewController ()

@property(nonatomic,strong) KLineChartView *klineCharView;
@property(nonatomic,strong) KLinePeriodView *klinePeriodView;
@property(nonatomic,strong) KLineIndicatorsView *lineIndicatorsView;
@property(nonatomic,strong) KLineVerticalIndicatorsView *verticalIndicatorsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor rgb_r:8 g:23 b:35 alpha:1];
    [KLineStateManager manager].klineChart = self.klineCharView;
    [[HTTPTool tool] getData:@"" complation:^(NSArray<KLineModel *> * _Nonnull models) {
        [DataUtil calculate:models];
        [KLineStateManager manager].datas = models;
    }];
    
     [self.view addSubview:self.klineCharView];
     [self.view addSubview:self.klinePeriodView];
     [self.view addSubview:self.lineIndicatorsView];
     [self.view addSubview:self.verticalIndicatorsView];
    
    [self verticalLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chageRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
}

-(void)chageRotate:(NSNotification *)noti {
    if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
        [self  verticalLayout];
    } else {
        [self horizontalLayout];
    }
}

-(void)verticalLayout {
    CGFloat topMargin = 50;
    self.verticalIndicatorsView.hidden = true;
    self.lineIndicatorsView.hidden = false;
    [self.lineIndicatorsView correctState];
    self.klineCharView.direction = KLineDirectionVertical;
    self.klinePeriodView.frame = CGRectMake(0, topMargin, self.view.frame.size.width, 30);
    self.klineCharView.frame = CGRectMake(0, CGRectGetMaxY(self.klinePeriodView.frame), self.view.frame.size.width, 450);
    self.lineIndicatorsView.frame = CGRectMake(0, CGRectGetMaxY(self.klineCharView.frame) + 20, self.klineCharView.frame.size.width, 80);
}

-(void)horizontalLayout {
    CGFloat rightMargin = 10;
    self.verticalIndicatorsView.hidden = false;
    self.lineIndicatorsView.hidden = true;
    
   [self.verticalIndicatorsView correctState];
   self.klineCharView.direction = KLineDirectionHorizontal;
    self.verticalIndicatorsView.frame = CGRectMake(self.view.frame.size.width - 50 - rightMargin,0, 60, self.klineCharView.frame.size.height);
   self.klineCharView.frame = CGRectMake(0, 0, self.view.frame.size.width - 60- rightMargin, self.view.frame.size.height - 30);
   self.klinePeriodView.frame = CGRectMake(0, self.view.frame.size.height - 30 , self.klineCharView.frame.size.width, 30);
    
}

-(KLineChartView *)klineCharView {
    if(_klineCharView == nil) {
        _klineCharView = [[KLineChartView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 450)];
    }
    return _klineCharView;
}

-(KLinePeriodView *)klinePeriodView {
    if(_klinePeriodView == nil) {
        _klinePeriodView = [KLinePeriodView linePeriodView];
    }
    return _klinePeriodView;
}
-(KLineIndicatorsView *)lineIndicatorsView {
    if(_lineIndicatorsView == nil) {
        _lineIndicatorsView = [KLineIndicatorsView indicatorsView];
    }
    return _lineIndicatorsView;
}
-(KLineVerticalIndicatorsView *)verticalIndicatorsView {
    if(_verticalIndicatorsView == nil) {
        _verticalIndicatorsView = [KLineVerticalIndicatorsView verticalIndicatorsView];
    }
    return _verticalIndicatorsView;
}


@end
