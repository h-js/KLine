//
//  BaseChartRenderer.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KLineModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseChartRenderer : NSObject
@property(nonatomic,assign) CGFloat maxValue;
@property(nonatomic,assign) CGFloat minValue;
@property(nonatomic,assign) CGRect chartRect;
@property(nonatomic,assign) CGFloat candleWidth;
@property(nonatomic,assign) CGFloat scaleY;
@property(nonatomic,assign) CGFloat topPadding;

- (instancetype)initWithMaxValue:(CGFloat)maxValue
                        minValue:(CGFloat)minValue
                       chartRect:(CGRect)chartRect
                     candleWidth:(CGFloat)candleWidth
                      topPadding:(CGFloat)topPadding;

-(void)drawGrid:(CGContextRef)context
       gridRows:(NSUInteger)gridRows
     gridColums:(NSUInteger)gridColums;

-(void)drawRightText:(CGContextRef)context
            gridRows:(NSUInteger)gridRows
          gridColums:(NSUInteger)gridColums;

-(void)drawTopText:(CGContextRef)context
          curPoint:(KLineModel *)curPoint;

-(void)drawBg:(CGContextRef)context;

-(void)drawChart:(CGContextRef)context
        lastPoit:(KLineModel *)lastPoint
        curPoint:(KLineModel *)curPoint
            curX:(CGFloat)curX;

-(void)drawLine:(CGContextRef)context
      lastValue:(CGFloat)lastValue
       curValue:(CGFloat)curValue
           curX:(CGFloat)curX
          color:(UIColor *)color;

-(CGFloat)getY:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
