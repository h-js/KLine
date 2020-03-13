//
//  KLineChartView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineChartView.h"
#import "ChartStyle.h"
#import "KLinePainterView.h"
#import "KLineInfoView.h"

@interface KLineChartView()
@property(nonatomic,strong) KLinePainterView *painterView;
@property(nonatomic,strong) KLineInfoView *infoView;

@property(nonatomic,assign) CGFloat maxScroll;
@property(nonatomic,assign) CGFloat minScroll;

@property(nonatomic,assign) CGFloat lastScrollX;


@property(nonatomic,assign) CGFloat dragbeginX;
@property(nonatomic,assign) BOOL isDrag;
@property(nonatomic,assign) CGFloat speedX;
@property(nonatomic,strong) CADisplayLink *displayLink;

@property(nonatomic,assign) BOOL isScale;
@property(nonatomic,assign) CGFloat lastscaleX;

@end


@implementation KLineChartView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.painterView.frame = self.bounds;
    [self initIndicatirs];
}

- (void)setDatas:(NSArray<KLineModel *> *)datas {
    _datas = datas;
    [self initIndicatirs];
    self.painterView.datas = datas;
}

- (void)setIsLine:(BOOL)isLine {
    _isLine = isLine;
    self.painterView.isLine = isLine;
}

- (void)setIsLongPress:(BOOL)isLongPress {
    _isLongPress = isLongPress;
    self.painterView.isLongPress = isLongPress;
    if(!isLongPress) {
        [self.infoView removeFromSuperview];
    }
}

-(void)setScrollX:(CGFloat)scrollX {
    _scrollX = scrollX;
    self.painterView.scrollX = scrollX;
}

- (void)setScaleX:(CGFloat)scaleX {
    _scaleX = scaleX;
    [self initIndicatirs];
    self.painterView.scaleX = scaleX;
}

- (void)setMainState:(MainState)mainState {
    _mainState = mainState;
    self.painterView.mainState = mainState;
}

-(void)setSecondaryState:(SecondaryState)secondaryState {
    _secondaryState = secondaryState;
    self.painterView.secondaryState = secondaryState;
}

-(void)setLongPressX:(CGFloat)longPressX {
    _longPressX = longPressX;
    self.painterView.longPressX = longPressX;
}

-(void)setDirection:(KLineDirection)direction {
    _direction = direction;
    self.painterView.direction = direction;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scaleX = 1;
        _mainState = MainStateMA;
        _secondaryState = SecondaryStateWR;
        _scrollX = -self.frame.size.width / 5 + ChartStyle_candleWidth / 2;
        [self initIndicatirs];
        _painterView = [[KLinePainterView alloc] initWithFrame:self.bounds datas:_datas scrollX:_scrollX isLine:_isLine scaleX:_scaleX isLongPress:_isLongPress mainState:_mainState secondaryState:_secondaryState];
        [self addSubview:_painterView];
         __weak typeof(self) weakSelf = self;
        _painterView.showInfoBlock = ^(KLineModel * _Nonnull model, BOOL isLeft) {
            weakSelf.infoView.model = model;
            [weakSelf addSubview:weakSelf.infoView];
            CGFloat padding = 5;
            if(isLeft){
                weakSelf.infoView.frame = CGRectMake(padding, 30,  weakSelf.infoView.frame.size.width,  weakSelf.infoView.frame.size.height);
            } else {
                weakSelf.infoView.frame = CGRectMake(weakSelf.frame.size.width - weakSelf.infoView.frame.size.width - padding, 30,  weakSelf.infoView.frame.size.width,  weakSelf.infoView.frame.size.height);
            }
        };
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragKlineEvent:)];
        UILongPressGestureRecognizer *longGresture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressKlineEvent:)];
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(secalXEvent:)];
        [_painterView addGestureRecognizer:panGesture];
        [_painterView addGestureRecognizer:longGresture];
        [_painterView addGestureRecognizer:pinGesture];
    }
    return self;
}


-(void)initIndicatirs {
    CGFloat dataLength = ((CGFloat)_datas.count) * (ChartStyle_candleWidth * _scaleX + ChartStyle_canldeMargin) - ChartStyle_canldeMargin;
      _maxScroll = dataLength - self.frame.size.width;
//    if(dataLength > self.frame.size.width) {
//        _maxScroll = dataLength - self.frame.size.width;
//    } else {
//        _maxScroll =  -(self.frame.size.width - dataLength);
//    }
    CGFloat dataScroll = self.frame.size.width - dataLength;
    CGFloat normalminScroll = -self.frame.size.width/5.0 + (ChartStyle_candleWidth * _scaleX) / (CGFloat)2.0;
    self.minScroll = MIN(normalminScroll,-dataScroll);
    self.scrollX = [self clamp:_scrollX min:_minScroll max:_maxScroll];
    self.lastScrollX = self.scrollX;
    
}

-(void)dragKlineEvent:(UIPanGestureRecognizer *)gesture{
    if(_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [gesture locationInView:self.painterView];
            _dragbeginX = point.x;
            _isDrag = true;
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self.painterView];
            CGFloat dragX = point.x - _dragbeginX;
            self.scrollX = [self clamp:_lastScrollX + dragX min:_minScroll max:_maxScroll];
        } break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint speed = [gesture velocityInView:self.painterView];
            self.speedX = speed.x;
            _isDrag = false;
            self.lastScrollX = self.scrollX;
            if(speed.x != 0) {
                _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshEvent:)];
                [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            }
        }break;
        default:
            break;
    }
    
}

-(void)longPressKlineEvent:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [gesture locationInView:self.painterView];
            self.longPressX = point.x;
            self.isLongPress = YES;
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self.painterView];
            self.longPressX = point.x;
            self.isLongPress = YES;
        } break;
        case UIGestureRecognizerStateEnded:
            self.isLongPress = NO;
        default:
            break;
    }
}
-(void)secalXEvent:(UIPinchGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _isScale = true;
            break;
        case UIGestureRecognizerStateChanged:
        {
            _isScale = true;
            self.scaleX = [self clamp:self.lastscaleX * gesture.scale min:0.5 max:2];
        }
        case UIGestureRecognizerStateEnded:
        {
            _isScale = false;
            self.lastscaleX = _scaleX;
        }
        default:
            break;
    }
}

-(void)refreshEvent:(CADisplayLink *)displaylink {
    CGFloat space = 100;
    if(self.speedX < 0) {
        self.speedX = MIN(self.speedX + space,0);
        self.scrollX = [self clamp:self.scrollX - 5 min:_minScroll max:_maxScroll];
        self.lastscaleX = self.scrollX;
    } else if (self.speedX > 0) {
        self.speedX = MAX(self.speedX - space,0);
        self.scrollX = [self clamp:self.scrollX + 5 min:_minScroll max:_maxScroll];
        self.lastScrollX = self.scrollX;
    } else {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}


-(CGFloat)clamp:(CGFloat)value min:(CGFloat)min max:(CGFloat)max {
    if (value < min) {
        return min;
    } else if (value > max) {
        return max;
    } else {
        return value;
    }
}

-(KLineInfoView *)infoView {
    if(_infoView == nil) {
        _infoView = [KLineInfoView lineInfoView];
    }
    return _infoView;
}


@end
