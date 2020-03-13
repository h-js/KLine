//
//  KLinePeriodView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLinePeriodView.h"
#import "KLineStateManager.h"
#import "ChartStyle.h"
@interface KLinePeriodView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerXConstraint;

@property (weak, nonatomic) IBOutlet UIButton *periodfenButton;

@property (weak, nonatomic) IBOutlet UIButton *period5fenButton;
@property (weak, nonatomic) IBOutlet UIButton *period30fenButton;
@property (weak, nonatomic) IBOutlet UIButton *period1hourButton;
@property (weak, nonatomic) IBOutlet UIButton *period4hourButton;
@property (weak, nonatomic) IBOutlet UIButton *period1dayButton;
@property (weak, nonatomic) IBOutlet UIButton *period1weakButton;


@property (weak, nonatomic)  UIButton *currentButton;

@end

@implementation KLinePeriodView

+(KLinePeriodView *)linePeriodView {
    KLinePeriodView *view = [[NSBundle mainBundle] loadNibNamed:@"KLinePeriodView" owner:self options:nil].lastObject;
    view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 30);
    view.backgroundColor = ChartColors_bgColor;
    view.layer.shadowColor =  [UIColor  blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 10);
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 5;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentButton = self.period5fenButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.periodfenButton != nil) {
        self.centerXConstraint.constant = self.currentButton.center.x - self.periodfenButton.center.x;
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.centerXConstraint.constant = sender.center.x - self.periodfenButton.center.x;
    }];
    self.currentButton = sender;
    NSString *period = @"1min";
    if(sender.tag == 1) {
        period = @"1min";
    } else if (sender.tag == 2) {
         period = @"5min";
    } else if (sender.tag == 3) {
         period = @"30min";
    } else if (sender.tag == 4) {
         period = @"1hour";
    } else if (sender.tag == 5) {
         period = @"4hour";
    } else if (sender.tag == 6) {
         period = @"1day";
    } else if (sender.tag == 7) {
         period = @"1week";
    }
    [KLineStateManager manager].period = period;
    if([period isEqualToString:@"1min"]) {
        [KLineStateManager manager].isLine = YES;
    } else {
        [KLineStateManager manager].isLine = NO;
    }
}


@end
