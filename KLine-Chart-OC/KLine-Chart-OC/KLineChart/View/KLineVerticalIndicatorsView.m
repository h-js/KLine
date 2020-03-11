//
//  KLineVerticalIndicatorsView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineVerticalIndicatorsView.h"
#import "KLineStateManager.h"
#import "ChartStyle.h"

@interface KLineVerticalIndicatorsView()


@property (weak, nonatomic) IBOutlet UIButton *maButton;
@property (weak, nonatomic) IBOutlet UIButton *bollButton;

@property (weak, nonatomic) IBOutlet UIButton *macdButton;
@property (weak, nonatomic) IBOutlet UIButton *kdjButton;
@property (weak, nonatomic) IBOutlet UIButton *rsiButton;
@property (weak, nonatomic) IBOutlet UIButton *wrButton;

@end

@implementation KLineVerticalIndicatorsView

+(KLineVerticalIndicatorsView *)verticalIndicatorsView {
    
    KLineVerticalIndicatorsView *view = [[NSBundle mainBundle] loadNibNamed:@"KLineVerticalIndicatorsView" owner:self options:nil].lastObject;
      view.frame = CGRectMake(0, 0, 80, UIScreen.mainScreen.bounds.size.height);
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
            _macdButton.selected = true;
            _bollButton.selected = false;
            [KLineStateManager manager].mainState = MainStateMA;
            break;
        case 2:
            _macdButton.selected = false;
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
            [self mainhideClick:self.maButton];
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

@end
