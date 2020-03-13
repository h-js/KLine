//
//  ChartStyle.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "UIColor+RGB.h"

#define Color(rgbValue)  [UIColor rgbFromHex:rgbValue]

  //背景颜色
#define ChartColors_bgColor   Color(0xff06141D)
#define ChartColors_kLineColor   Color(0xff4C86CD)
#define ChartColors_gridColor   Color(0xff4c5c74)
#define ChartColors_ma5Color   Color(0xffC9B885)
#define ChartColors_ma10Color   Color(0xff6CB0A6)
#define ChartColors_ma30Color   Color(0xff9979C6)
#define ChartColors_upColor   Color(0xff4DAA90)
#define ChartColors_dnColor   Color(0xffC15466)
#define ChartColors_volColor   Color(0xff4729AE)

#define ChartColors_macdColor   Color(0xff4729AE)
#define ChartColors_difColor   Color(0xffC9B885)
#define ChartColors_deaColor   Color(0xff6CB0A6)

#define ChartColors_kColor   Color(0xffC9B885)
#define ChartColors_dColor   Color(0xff6CB0A6)
#define ChartColors_jColor   Color(0xff9979C6)
#define ChartColors_rsiColor   Color(0xffC9B885)

#define ChartColors_wrColor   Color(0xffD2D2B4)

#define ChartColors_yAxisTextColor   Color(0xff70839E)  //右边y轴刻度
#define ChartColors_xAxisTextColor   Color(0xff60738E)  //下方时间刻度

#define ChartColors_maxMinTextColor   Color(0xffffffff)  //最大最小值的颜色

//深度颜色
#define ChartColors_depthBuyColor   Color(0xff60A893)
#define ChartColors_depthSellColor   Color(0xffC15866)

//选中后显示值边框颜色
#define ChartColors_markerBorderColor   Color(0xffFFFFFF)

//选中后显示值背景的填充颜色
#define ChartColors_markerBgColor   Color(0xff0D1722)

//实时线颜色等
#define ChartColors_realTimeBgColor   Color(0xff0D1722)
#define ChartColors_rightRealTimeTextColor   Color(0xff4C86CD)
#define ChartColors_realTimeTextBorderColor   Color(0xffffffff)
#define ChartColors_realTimeTextColor   Color(0xffffffff)

//实时线
#define ChartColors_realTimeLineColor   Color(0xffffffff)
#define ChartColors_realTimeLongLineColor   Color(0xff4C86CD)


//表格右边文字颜色
#define ChartColors_reightTextColor   Color(0xff70839E)
#define ChartColors_bottomDateTextColor   Color(0xff70839E)

#define ChartColors_crossHlineColor   Color(0x1FFFFFFF)

static CGFloat dd = 11.0;
//点与点的距离（）不用这种方式实现
static CGFloat ChartStyle_pointWidth = 11.0;

    //蜡烛之间的间距
static CGFloat ChartStyle_canldeMargin =   3;

    //蜡烛默认宽度
static CGFloat ChartStyle_defaultcandleWidth =  8.5;

    //蜡烛宽度
static CGFloat ChartStyle_candleWidth  = 8.5;

    //蜡烛中间线的宽度
static CGFloat ChartStyle_candleLineWidth =  1.5;

    //vol柱子宽度
static CGFloat ChartStyle_volWidth = 8.5;

    //macd柱子宽度
static CGFloat ChartStyle_macdWidth = 3.0;

    //垂直交叉线宽度
static CGFloat ChartStyle_vCrossWidth  = 8.5;

    //水平交叉线宽度
static CGFloat ChartStyle_hCrossWidth = 0.5;

    //网格
static CGFloat ChartStyle_gridRows = 4;
   
static CGFloat ChartStyle_gridColumns = 5;

static CGFloat ChartStyle_topPadding = 30.0;
   
static CGFloat ChartStyle_bottomDateHigh = 20.0;
   
static CGFloat ChartStyle_childPadding = 25.0;

static CGFloat ChartStyle_defaultTextSize = 10;
   
static CGFloat ChartStyle_bottomDatefontSize = 10;
   
   //表格右边文字价格
static CGFloat ChartStyle_reightTextSize = 10;
