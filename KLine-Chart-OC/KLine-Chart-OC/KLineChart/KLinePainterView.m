//
//  KLinePainterView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLinePainterView.h"
#import "MainChartRenderer.h"
#import "VolChartRenderer.h"
#import "SecondaryChartRenderer.h"
#import "ChartStyle.h"

@interface KLinePainterView()
@property(nonatomic,assign) CGFloat displayHeight;
@property(nonatomic,strong) MainChartRenderer *mainRenderer;
@property(nonatomic,strong) VolChartRenderer *volRenderer;
@property(nonatomic,strong) SecondaryChartRenderer *seconderyRender;

@property(nonatomic,assign) CGRect mainRect;
@property(nonatomic,assign) CGRect volRect;
@property(nonatomic,assign) CGRect secondaryRect;
@property(nonatomic,assign) CGRect dateRect;

@property(nonatomic,assign) NSUInteger startIndex;
@property(nonatomic,assign) NSUInteger stopIndex;

@property(nonatomic,assign) NSUInteger mMainMaxIndex;
@property(nonatomic,assign) NSUInteger mMainMinIndex;

@property(nonatomic,assign) CGFloat mMainMaxValue;
@property(nonatomic,assign) CGFloat mMainMinValue;

@property(nonatomic,assign) CGFloat mVolMaxValue;
@property(nonatomic,assign) CGFloat mVolMinValue;

@property(nonatomic,assign) CGFloat mSecondaryMaxValue;
@property(nonatomic,assign) CGFloat mSecondaryMinValue;

@property(nonatomic,assign) CGFloat mMainHighMaxValue;
@property(nonatomic,assign) CGFloat mMainLowMinValue;

@property(nonatomic,assign) CGFloat candleWidth;

//var fromat: String = "yyyy-MM-dd"
@property(nonatomic,copy) NSString *fromat;

@end

@implementation KLinePainterView

- (instancetype)initWithFrame:(CGRect)frame
                        datas:(NSArray<KLineModel *> *)datas
                      scrollX:(CGFloat)scrollX
                       isLine:(BOOL)isLine
                       scaleX:(CGFloat)scaleX
                  isLongPress:(BOOL)isLongPress
                    mainState:(MainState)mainState
               secondaryState:(SecondaryState)secondaryState
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datas = datas;
        self.scrollX = scrollX;
        self.isLine = isLine;
        self.scaleX = scaleX;
        self.isLongPress = isLongPress;
        self.mainState = mainState;
        self.secondaryState = secondaryState;
        self.candleWidth = ChartStyle_candleWidth * self.scaleX;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    _displayHeight = rect.size.height - ChartStyle_topPadding - ChartStyle_bottomDateHigh;
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(context != NULL) {
        [self divisionRect];
        [self calculateValue];
        [self calculateFormats];
        [self initRenderer];
        [self drawBgColor:context rect:rect];
        [self drawGrid:context];
        if(self.datas.count == 0) { return; }
        [self drawGrid:context];
        [self drawRightText:context];
        [self drawDate:context];
        [self drawMaxAndMin:context];
        if(_isLongPress) {
            [self drawLongPressCrossLine:context];
        } else {
            [self drawTopText:context curPoint:self.datas.firstObject];
        }
        [self drawRealTimePrice:context];
    }
}

-(void)divisionRect {
    CGFloat mainHeight = self.displayHeight * 0.6;
    CGFloat volHeigt = self.displayHeight * 0.2;
    CGFloat secondaryHeight = self.displayHeight * 0.2;
    if(_volState == VolStateNONE && _secondaryState == SecondaryStateNONE) {
        mainHeight = self.displayHeight;
    } else if (_volState == VolStateNONE || _secondaryState == SecondaryStateNONE) {
        mainHeight = self.displayHeight * 0.8;
    }
    self.mainRect = CGRectMake(0, ChartStyle_topPadding, self.frame.size.width, mainHeight);
    if(_direction == KLineDirectionHorizontal) {
        self.dateRect = CGRectMake(0, CGRectGetMaxY(_mainRect), self.frame.size.width, ChartStyle_bottomDateHigh);
        if(_volState != VolStateNONE) {
            self.volRect = CGRectMake(0, CGRectGetMaxY(_dateRect), self.frame.size.width, volHeigt);
        }
        if(_secondaryState != SecondaryStateNONE) {
            CGFloat y =  CGRectGetMaxY(_volRect);
            self.secondaryRect = CGRectMake(0, y, self.frame.size.width, secondaryHeight);
        }
    } else {
       
        if(_volState != VolStateNONE) {
            self.volRect = CGRectMake(0, CGRectGetMaxY(_mainRect), self.frame.size.width, volHeigt);
        }
        if(_secondaryState != SecondaryStateNONE) {
            CGFloat y =  CGRectGetMaxY(_volRect);
            self.secondaryRect = CGRectMake(0, y, self.frame.size.width, secondaryHeight);
        }
        self.dateRect = CGRectMake(0,  self.displayHeight + ChartStyle_topPadding, self.frame.size.width, ChartStyle_bottomDateHigh);
    }
}

-(void)calculateValue {
    if(self.datas.count == 0) { return; }
    CGFloat itemWidth = _candleWidth + ChartStyle_canldeMargin;
    if(_scrollX <= 0) {
        self.startX = -_scrollX;
        self.startIndex = 0;
    } else {
        CGFloat start = _scrollX / itemWidth;
        CGFloat offsetX = 0;
        if(floor(start) == ceil(start)) {
            _startIndex = (NSUInteger)floor(start);
        } else {
            _startIndex = (NSUInteger)(floor(_scrollX / itemWidth));
            offsetX = (CGFloat)_startIndex * itemWidth - _scrollX;
        }
        self.startX = offsetX;
    }
    NSUInteger diffIndex = (NSUInteger)(ceil(self.frame.size.width - self.startX) / itemWidth);
    _stopIndex = MIN(_startIndex + diffIndex, self.datas.count - 1);
    _mMainMaxValue = -CGFLOAT_MAX;
    _mMainMinValue = CGFLOAT_MAX;
    _mMainHighMaxValue = -CGFLOAT_MAX;
    _mMainLowMinValue = CGFLOAT_MAX;
    _mVolMaxValue = -CGFLOAT_MAX;
    _mVolMinValue = CGFLOAT_MAX;
    _mSecondaryMaxValue = -CGFLOAT_MAX;
    _mSecondaryMinValue = CGFLOAT_MAX;
    for (NSUInteger index = _startIndex; index < _stopIndex; index++) {
        KLineModel *item = self.datas[index];
        [self getMianMaxMinValue:item i:index];
        [self getVolMaxMinValue:item];
        [self getSecondaryMaxMinValue:item];
    }
}

-(void)getMianMaxMinValue:(KLineModel *)item i:(NSUInteger)i {
    if (_isLine == true) {
      _mMainMaxValue = MAX(_mMainMaxValue, item.close);
      _mMainMinValue = MIN(_mMainMinValue, item.close);
    } else {
        CGFloat maxPrice = item.high;
        CGFloat minPrice = item.low;
        if (_mainState == MainStateMA) {
        if(item.MA5Price != 0){
          maxPrice = MAX(maxPrice, item.MA5Price);
          minPrice = MIN(minPrice, item.MA5Price);
        }
        if(item.MA10Price != 0){
          maxPrice = MAX(maxPrice, item.MA10Price);
          minPrice = MIN(minPrice, item.MA10Price);
        }
        if(item.MA20Price != 0){
          maxPrice = MAX(maxPrice, item.MA20Price);
          minPrice = MIN(minPrice, item.MA20Price);
        }
        if(item.MA30Price != 0){
          maxPrice = MAX(maxPrice, item.MA30Price);
          minPrice = MIN(minPrice, item.MA30Price);
        }
        } else if (_mainState == MainStateBOLL) {
        if(item.up != 0){
          maxPrice = MAX(item.up, item.high);
        }
        if(item.dn != 0){
          minPrice = MIN(item.dn, item.low);
        }
      }
      _mMainMaxValue = MAX(_mMainMaxValue, maxPrice);
      _mMainMinValue = MIN(_mMainMinValue, minPrice);

      if (_mMainHighMaxValue < item.high) {
        _mMainHighMaxValue = item.high;
        _mMainMaxIndex = i;
      }
      if (_mMainLowMinValue > item.low) {
        _mMainLowMinValue = item.low;
        _mMainMinIndex = i;
      }
    }
}
-(void)getVolMaxMinValue:(KLineModel *)item {
    _mVolMaxValue = MAX(_mVolMaxValue, MAX(item.vol, MAX(item.MA5Volume, item.MA10Volume)));
    _mVolMinValue = MIN(_mVolMinValue, MIN(item.vol, MIN(item.MA5Volume, item.MA10Volume)));
}

-(void)getSecondaryMaxMinValue:(KLineModel *)item {
    if (_secondaryState == SecondaryStateMacd) {
      _mSecondaryMaxValue = MAX(_mSecondaryMaxValue, MAX(item.macd, MAX(item.dif, item.dea)));
      _mSecondaryMinValue = MIN(_mSecondaryMinValue, MIN(item.macd, MIN(item.dif, item.dea)));
    } else if (_secondaryState == SecondaryStateKDJ) {
      _mSecondaryMaxValue = MAX(_mSecondaryMaxValue, MAX(item.k, MAX(item.d, item.j)));
      _mSecondaryMinValue = MIN(_mSecondaryMinValue, MIN(item.k, MIN(item.d, item.j)));
    } else if (_secondaryState == SecondaryStateRSI) {
      _mSecondaryMaxValue = MAX(_mSecondaryMaxValue, item.rsi);
      _mSecondaryMinValue = MIN(_mSecondaryMinValue, item.rsi);
    } else {
      _mSecondaryMaxValue = MAX(_mSecondaryMaxValue, item.r);
      _mSecondaryMinValue = MIN(_mSecondaryMinValue, item.r);
    }
}

-(void)calculateFormats {
    if(self.datas.count < 2) { return; }
    NSTimeInterval fristtime = 0;
    NSTimeInterval secondTime = 0;
    NSTimeInterval time = ABS(fristtime - secondTime);
    if(time >= 24 * 60 * 60 * 28) {
        self.fromat = @"yyyy-MM";
    } else if(time >= 24 * 60 * 60) {
        self.fromat = @"yyyy-MM-dd";
    } else {
        self.fromat = @"MM-dd HH:mm";
    }
}

-(void)initRenderer {
    _mainRenderer = [[MainChartRenderer alloc] initWithMaxValue:_mMainMaxValue minValue:_mMainMinValue chartRect:_mainRect candleWidth:_candleWidth topPadding:ChartStyle_topPadding isLine:_isLine state:_mainState];
    if(_volState != VolStateNONE) {
        _volRenderer = [[VolChartRenderer alloc] initWithMaxValue:_mVolMaxValue minValue:_mVolMinValue chartRect:_volRect candleWidth:_candleWidth topPadding:ChartStyle_childPadding];
    }
    if(_secondaryState != SecondaryStateNONE) {
        _seconderyRender = [[SecondaryChartRenderer alloc] initWithMaxValue:_mSecondaryMaxValue minValue:_mSecondaryMinValue chartRect:_secondaryRect candleWidth:_candleWidth topPadding:ChartStyle_childPadding state:_secondaryState];
    }
}

-(void)drawBgColor:(CGContextRef)context rect:(CGRect)rect {
      [_mainRenderer drawBg:context];
      if(_volRenderer != nil) {
          [_volRenderer drawBg:context];
      }
      if(_seconderyRender != nil) {
          [_seconderyRender drawBg:context];
      }
}
-(void)drawGrid:(CGContextRef)context {
    [_mainRenderer drawGrid:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridRows];
   if(_volRenderer != nil) {
       [_volRenderer drawGrid:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridRows];
   }
   if(_seconderyRender != nil) {
       [_seconderyRender drawGrid:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridRows];
   }
}
-(void)drawChart:(CGContextRef)context {
    for (NSUInteger index = _startIndex; index <= _stopIndex; index++) {
        KLineModel *curPoint = self.datas[index];
        CGFloat itemWidth = _candleWidth + ChartStyle_canldeMargin;
        CGFloat curX = (CGFloat)(index - _stopIndex) * itemWidth + _startX;
        KLineModel *lastPoint;
        if(index != _startIndex) {
            lastPoint = self.datas[index - 1];
        }
        [_mainRenderer drawChart:context lastPoit:lastPoint curPoint:curPoint curX:curX];
        if(_volRenderer != nil) {
            [_volRenderer drawChart:context lastPoit:lastPoint curPoint:curPoint curX:curX];
        }
        if(_seconderyRender != nil) {
            [_seconderyRender drawChart:context lastPoit:lastPoint curPoint:curPoint curX:curX];
        }
    }
}
-(void)drawRightText:(CGContextRef)context {
    [_mainRenderer drawRightText:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridColumns];
    if(_volRenderer != nil) {
        [_volRenderer drawRightText:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridColumns];
    }
    if(_seconderyRender != nil) {
        [_seconderyRender drawRightText:context gridRows:ChartStyle_gridRows gridColums:ChartStyle_gridColumns];
    }
}
-(void)drawDate:(CGContextRef)context {
    
}
-(void)drawMaxAndMin:(CGContextRef)context {
    
}
-(void)drawLongPressCrossLine:(CGContextRef)context {
    
}
-(void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    [_mainRenderer drawTopText:context curPoint:curPoint];
    if(_volRenderer != nil) {
        [_volRenderer drawTopText:context curPoint:curPoint];
    }
    if(_seconderyRender != nil) {
        [_seconderyRender drawTopText:context curPoint:curPoint];
    }
}
-(void)drawRealTimePrice:(CGContextRef)context {
    
}

-(NSUInteger)calculateIndexWithSelectX:(CGFloat)selectX {
    NSInteger index = (self.frame.size.width - _startX - selectX) / (_candleWidth + ChartStyle_canldeMargin) + _startIndex;
    return index;
}

-(BOOL)outRangeIndex:(NSUInteger)index {
    if(index < 0 && index >= self.datas.count) {
        return true;
    } else {
        return false;
    }
}


@end
