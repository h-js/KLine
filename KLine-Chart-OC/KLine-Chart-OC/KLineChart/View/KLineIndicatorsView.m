//
//  KLineIndicatorsView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineIndicatorsView.h"
#import "KLineStateManager.h"
#import "ChartStyle.h"
#import "DataUtil.h"

@interface KLineIndicatorsView()

@property (weak, nonatomic) IBOutlet UIButton *maButton;
@property (weak, nonatomic) IBOutlet UIButton *bollButton;

@property (weak, nonatomic) IBOutlet UIButton *macdButton;
@property (weak, nonatomic) IBOutlet UIButton *kdjButton;
@property (weak, nonatomic) IBOutlet UIButton *rsiButton;
@property (weak, nonatomic) IBOutlet UIButton *wrButton;

@end

@implementation KLineIndicatorsView

+(KLineIndicatorsView *)indicatorsView {
    
    KLineIndicatorsView *view = [[NSBundle mainBundle] loadNibNamed:@"KLineIndicatorsView" owner:self options:nil].lastObject;
      view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 80);
      view.backgroundColor = ChartColors_bgColor;
      view.layer.shadowColor =  [UIColor  blackColor].CGColor;
      view.layer.shadowOffset = CGSizeMake(0, 10);
      view.layer.shadowOpacity = 0.5;
      view.layer.shadowRadius = 5;
      return view;
}



- (IBAction)mainbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            _maButton.selected = true;
            _bollButton.selected = false;
            [KLineStateManager manager].mainState = MainStateMA;
            break;
        case 2:
            _maButton.selected = false;
           _bollButton.selected = true;
           [KLineStateManager manager].mainState = MainStateBOLL;
           break;
        default:
            break;
    }
}

- (IBAction)vicebuttonClick:(UIButton *)sender {
    _macdButton.selected = false;
    _kdjButton.selected = false;
    _rsiButton.selected = false;
    _wrButton.selected = false;
    switch (sender.tag) {
        case 1:
            _macdButton.selected = true;
            [KLineStateManager manager].secondaryState = SecondaryStateMacd;
            break;
        case 2:
            _kdjButton.selected = true;
            [KLineStateManager manager].secondaryState = SecondaryStateKDJ;
            break;
        case 3:
            _rsiButton.selected = true;
            [KLineStateManager manager].secondaryState = SecondaryStateRSI;
            break;
        case 4:
            _wrButton.selected = true;
            [KLineStateManager manager].secondaryState = SecondaryStateWR;
            break;
        default:
            break;
    }
}

- (IBAction)mainhideClick:(UIButton *)sender {
    _maButton.selected = false;
    _bollButton.selected = false;
    [KLineStateManager manager].mainState = MainStateNONE;
}
- (IBAction)viceHideClick:(UIButton *)sender {
    _macdButton.selected = false;
    _kdjButton.selected = false;
    _rsiButton.selected = false;
    _wrButton.selected = false;
    [KLineStateManager manager].secondaryState = SecondaryStateNONE;
}

-(void)correctState {
    switch ([KLineStateManager manager].mainState) {
        case MainStateMA:
            [self mainbuttonClick:self.maButton];
            break;
        case MainStateBOLL:
            [self mainbuttonClick:self.bollButton];
            break;
        case MainStateNONE:
            [self mainhideClick:[UIButton new]];
        default:
            break;
    }
    switch ([KLineStateManager manager].secondaryState) {
        case SecondaryStateMacd:
            [self vicebuttonClick:self.macdButton];
            break;

        case SecondaryStateKDJ:
            [self vicebuttonClick:self.kdjButton];
            break;
        case SecondaryStateRSI:
            [self vicebuttonClick:self.rsiButton];
            break;
        case SecondaryStateWR:
            [self vicebuttonClick:self.wrButton];
            break;
        case SecondaryStateNONE:
            [self viceHideClick:[UIButton new]];
            break;
        default:
            break;
    }
}

- (IBAction)addDataClick:(UIButton *)sender {
    KLineModel *model = [KLineStateManager manager].datas.firstObject;
    if(model != nil) {
        KLineModel *kLineEntity = [[KLineModel alloc] init];
        kLineEntity.id = model.id + 60 * 60 * 24;
        kLineEntity.open = model.close;
        int rand = (int)(arc4random() % 200);
        kLineEntity.close = model.close + (CGFloat)(rand) * (CGFloat)((rand % 3) - 1);
        kLineEntity.high = MAX(kLineEntity.open, kLineEntity.close) + 10;
        kLineEntity.low = MIN(kLineEntity.open, kLineEntity.close) - 10;
    
        kLineEntity.amount = model.amount + (CGFloat)(rand) * (CGFloat)((rand % 3) - 1);
        kLineEntity.count = model.count + (CGFloat)(rand) * (CGFloat)((rand % 3) - 1);
        kLineEntity.vol = model.vol +  (CGFloat)(rand) * (CGFloat)((rand % 3) - 1);
        
        NSArray  *models = [KLineStateManager manager].datas;
        [DataUtil addLastData:models data:model];
        
        NSMutableArray *newDatas = [NSMutableArray arrayWithArray:models];
        [newDatas insertObject:kLineEntity atIndex:0];
        [KLineStateManager manager].datas = [newDatas copy];
    }
    
}


@end
