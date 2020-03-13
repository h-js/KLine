//
//  KLineInfoView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineInfoView.h"
#import "ChartStyle.h"

@interface KLineInfoView()
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (weak, nonatomic) IBOutlet UILabel *openLable;
@property (weak, nonatomic) IBOutlet UILabel *highLable;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *clsoeLabel;
@property (weak, nonatomic) IBOutlet UILabel *IncreaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLable;

@end

@implementation KLineInfoView

+(instancetype)lineInfoView {
    KLineInfoView *view = [[NSBundle mainBundle] loadNibNamed:@"KLineInfoView" owner:self options:nil].lastObject;
    view.frame = CGRectMake(0, 0, 120, 145);
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = ChartColors_bgColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = ChartColors_gridColor.CGColor;
}

- (void)setModel:(KLineModel *)model {
    _model = model;
//    _timeLable.text =
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.id];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yy-MM-dd HH:mm";
    _timeLable.text = [formater stringFromDate:date];
    
    _openLable.text = [NSString stringWithFormat:@"%.2f",model.open];
     _highLable.text = [NSString stringWithFormat:@"%.2f",model.high];
     _lowLabel.text = [NSString stringWithFormat:@"%.2f",model.low];
     _clsoeLabel.text = [NSString stringWithFormat:@"%.2f",model.close];
    CGFloat upDown = model.close - model.open;
    NSString *symbol = @"-";
    if(upDown > 0) {
        symbol = @"+";
        self.IncreaseLabel.textColor = ChartColors_upColor;
        self.amplitudeLabel.textColor = ChartColors_upColor;
    } else {
        self.IncreaseLabel.textColor = ChartColors_dnColor;
        self.amplitudeLabel.textColor = ChartColors_dnColor;
    }
    CGFloat upDownPercent = upDown / model.open * 100;
    _IncreaseLabel.text = [NSString stringWithFormat:@"%@%.2f",symbol,ABS(upDown)];
    _amplitudeLabel.text = [NSString stringWithFormat:@"%@%.2f%%",symbol,ABS(upDownPercent)];
    _amountLable.text = [NSString stringWithFormat:@"%.2f",model.vol];
    
}

@end
