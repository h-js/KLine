import 'dart:math';
import 'dart:async' show StreamSink;
import 'package:flutter/material.dart';
import '../chart_style.dart';
import '../entity/k_line_entity.dart';
import 'package:flutter_kchart/kchart/renderer/main_chart_renderer.dart';
import '../kchat_widget.dart';
import '../entity/candle_entity.dart';
import 'vol_chart_render.dart';
import 'secondary_chart_renderer.dart';
import '../utils/date_format_util.dart';
import '../utils/number_util.dart';
import '../entity/info_window_entity.dart';
import '../state_enum.dart';

class ChartPainter extends CustomPainter {

  List<KLineEntity> datas;
  double scrollX;
  double startX;
  bool isLine = false;
  double scaleX = 1.0;
  bool isLongPress;
  double selectX;

  StreamSink<InfoWindowEntity> sink;

  MainState mainState = MainState.BOLL;
  VolState volState = VolState.VOL;
  SecondaryState secondaryState = SecondaryState.WR;

  ChartPainter({this.datas,this.scrollX,this.isLine,this.scaleX,this.isLongPress,this.selectX,this.sink,this.mainState,this.secondaryState}) {
    canleWidth =  ChartStyle.candleWidth;  //* scaleX;
  }

  //3块区域大小与位置
  Rect mMainRect, mVolRect, mSecondaryRect;
  double mDisplayHeight, mWidth;
  double mMarginRight = 0.0; //k线右边空出来的距离

  double canleWidth = ChartStyle.candleWidth;
  double mPointWidth = ChartStyle.pointWidth;


  MainChartRenderer mainChartRenderer;
  VolChartRenderer volChartRenderer;
  SecondaryChartRenderer secondaryChartRenderer;

  int selectIndex = 0;

  //需要绘制的开始和结束下标
  int mStartIndex = 0, mStopIndex = 0;
  //主要区域的最大值，和最小值下标
  int mMainMaxIndex = 0, mMainMinIndex = 0;
  //主要区域
  double mMainMaxValue = -double.maxFinite, mMainMinValue = double.maxFinite;
  double mVolMaxValue = -double.maxFinite, mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = -double.maxFinite, mSecondaryMinValue = double.maxFinite;
  double mMainHighMaxValue = -double.maxFinite, mMainLowMinValue = double.maxFinite;

  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间

  @override
  void paint(Canvas canvas, Size size) {
    initFormats();
    mDisplayHeight = size.height - ChartStyle.topPadding - ChartStyle.bottomDateHigh;
    mWidth = size.width;
    divisionRect(size);
    drawBg(canvas, size);
    calculateValue();
    initRender();
    drawGrid(canvas);
    if(datas != null && datas.isNotEmpty){
      drawChart(canvas);
      drawDate(canvas, size);
      drawMaxAndMin(canvas);
      drawRightText(canvas);
      if (isLongPress) {
        selectIndex = calculateIndex(selectX);
//        selectIndex = selectIndex.clamp(0, datas.length - 1);
        if(outRangeIndex(selectIndex)) return;
        print("selectIndex${selectIndex}");
        drawLongPressCrossLine(canvas, size);

        drawTopText(canvas, datas[selectIndex]);
      } else {
        drawTopText(canvas, datas.first);
      }
    }
  }

  void initFormats() {
//    [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]
    if (datas.length < 2) return;
    int firstTime = datas.first?.id ?? 0;
    int secondTime = datas[1]?.id ?? 0;
    int time = firstTime - secondTime;
    //月线
    if (time >= 24 * 60 * 60 * 28)
      mFormats = [yy, '-', mm];
    //日线等
    else if (time >= 24 * 60 * 60)
      mFormats = [yy, '-', mm, '-', dd];
    //小时线等
    else
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
  }

  void drawChart(Canvas canvas) {
    canvas.save();
    for(int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineEntity curpoint = datas[i];
      double itemWidth = canleWidth + ChartStyle.canldeMargin;
      double curX = (i - mStartIndex) * itemWidth +  startX;
      KLineEntity lastpoint = null;
      if(i != mStartIndex) {
        lastpoint = datas[i - 1];
       }
      mainChartRenderer?.drawChart(canvas, lastpoint, curpoint, curX);
      volChartRenderer?.drawChart(canvas, lastpoint, curpoint, curX);
      secondaryChartRenderer?.drawChart(canvas, lastpoint, curpoint, curX);
    }
    canvas.restore();
  }
  void drawRightText(Canvas canvas) {
    mainChartRenderer?.drawRightText(canvas, ChartStyle.gridRows);
    volChartRenderer?.drawRightText(canvas, ChartStyle.gridRows);
    secondaryChartRenderer?.drawRightText(canvas, ChartStyle.gridRows);
  }

  void drawTopText(Canvas canvas,KLineEntity curPoint) {
    mainChartRenderer?.drawTopText(canvas, curPoint);
    volChartRenderer?.drawTopText(canvas, curPoint);
    secondaryChartRenderer?.drawTopText(canvas, curPoint);
  }


  //计算startIndex和stopIndex
  void calculateValue() {
    double itemWidth = canleWidth + ChartStyle.canldeMargin;
    if(scrollX <= 0){
      this.startX = -scrollX;
    } else {
      double start =  scrollX / itemWidth;
      double offsetX = 0;
      if(start.floor() == start.ceil()) {
        mStartIndex = start.floor();
      } else {
        mStartIndex = (scrollX / itemWidth).floor();
        offsetX = mStartIndex * itemWidth - scrollX;
      }
      this.startX = offsetX;
    }
    int diffIndex = ((mMainRect.width - this.startX.toDouble()) / itemWidth).ceil();
    mStopIndex = min(mStartIndex + diffIndex, datas.length - 1);
//    print("mStartIndex${mStartIndex},mStopIndex${mStopIndex}");
    for(int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      var item = datas[i];
      getMainMaxMinValue(item, i);
      getVolMaxMinValue(item);
      getSecondaryMaxMinValue(item);
    }
  }


  void getMainMaxMinValue(KLineEntity item, int i) {
    if (isLine == true) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    } else {
      double maxPrice = item.high, minPrice = item.low;
      if (mainState == MainState.MA) {
        if(item.MA5Price != 0){
          maxPrice = max(maxPrice, item.MA5Price);
          minPrice = min(minPrice, item.MA5Price);
        }
        if(item.MA10Price != 0){
          maxPrice = max(maxPrice, item.MA10Price);
          minPrice = min(minPrice, item.MA10Price);
        }
        if(item.MA20Price != 0){
          maxPrice = max(maxPrice, item.MA20Price);
          minPrice = min(minPrice, item.MA20Price);
        }
        if(item.MA30Price != 0){
          maxPrice = max(maxPrice, item.MA30Price);
          minPrice = min(minPrice, item.MA30Price);
        }
      } else if (mainState == MainState.BOLL) {
        if(item.up!=0){
          maxPrice = max(item.up, item.high);
        }
        if(item.dn!=0){
          minPrice = min(item.dn, item.low);
        }
      }
      mMainMaxValue = max(mMainMaxValue, maxPrice);
      mMainMinValue = min(mMainMinValue, minPrice);

      if (mMainHighMaxValue < item.high) {
        mMainHighMaxValue = item.high;
        mMainMaxIndex = i;
      }
      if (mMainLowMinValue > item.low) {
        mMainLowMinValue = item.low;
        mMainMinIndex = i;
      }
    }
  }

  void getVolMaxMinValue(KLineEntity item) {
    mVolMaxValue = max(mVolMaxValue, max(item.vol, max(item.MA5Volume, item.MA10Volume)));
    mVolMinValue = min(mVolMinValue, min(item.vol, min(item.MA5Volume, item.MA10Volume)));
  }

  void getSecondaryMaxMinValue(KLineEntity item) {
    if (secondaryState == SecondaryState.MACD) {
      mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.macd, max(item.dif, item.dea)));
      mSecondaryMinValue = min(mSecondaryMinValue, min(item.macd, min(item.dif, item.dea)));
    } else if (secondaryState == SecondaryState.KDJ) {
      mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.k, max(item.d, item.j)));
      mSecondaryMinValue = min(mSecondaryMinValue, min(item.k, min(item.d, item.j)));
    } else if (secondaryState == SecondaryState.RSI) {
      mSecondaryMaxValue = max(mSecondaryMaxValue, item.rsi);
      mSecondaryMinValue = min(mSecondaryMinValue, item.rsi);
    } else {
      mSecondaryMaxValue = max(mSecondaryMaxValue, item.r);
      mSecondaryMinValue = min(mSecondaryMinValue, item.r);
    }
  }

  void initRender() {
    mainChartRenderer ??= MainChartRenderer(mMainRect, mMainMaxValue, mMainMinValue, ChartStyle.topPadding,isLine,canleWidth,mainState);
    if(mVolRect != null) {
      volChartRenderer = VolChartRenderer(
          mVolRect, mVolMaxValue, mVolMinValue, ChartStyle.childPadding,
          canleWidth);
    }
    if (mSecondaryRect != null) {
      secondaryChartRenderer = SecondaryChartRenderer(
          mSecondaryRect, mSecondaryMaxValue, mSecondaryMinValue,
          ChartStyle.childPadding, canleWidth, secondaryState);
    }
  }

  //画背景色
  void drawBg(Canvas canvas, Size size) {
    final Paint mBgPaint = Paint()..color= ChartColors.bgColor;
    Rect chartRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(chartRect, mBgPaint);
  }

  //区分成三大块区域
  void divisionRect(Size size) {
//    double mainHeight = mDisplayHeight * 0.6;
//    double volHeight = mDisplayHeight * 0.2;
//    double secondaryHeight = mDisplayHeight * 0.2;
//    mMainRect = Rect.fromLTRB(0, ChartStyle.topPadding, mWidth, ChartStyle.topPadding + mainHeight);
//    mVolRect = Rect.fromLTRB(0, mMainRect.bottom + ChartStyle.childPadding, mWidth, mMainRect.bottom + volHeight);
//    mSecondaryRect = Rect.fromLTRB(0, (mVolRect?.bottom??mMainRect.bottom )+ ChartStyle.childPadding, mWidth, (mVolRect?.bottom??mMainRect.bottom)  + secondaryHeight);


    double mainHeight = mDisplayHeight * 0.6;
    double volHeight = mDisplayHeight * 0.2;
    double secondaryHeight = mDisplayHeight * 0.2;
    if (volState == VolState.NONE && secondaryState == SecondaryState.NONE) {
      mainHeight = mDisplayHeight;
    } else if (volState == VolState.NONE || secondaryState == SecondaryState.NONE) {
      mainHeight = mDisplayHeight * 0.8;
    }
    mMainRect = Rect.fromLTRB(0, ChartStyle.topPadding, mWidth, ChartStyle.topPadding + mainHeight);
    if(volState != VolState.NONE){
      mVolRect = Rect.fromLTRB(0, mMainRect.bottom + ChartStyle.childPadding, mWidth, mMainRect.bottom + volHeight);
    }
    if (secondaryState != SecondaryState.NONE){
      mSecondaryRect = Rect.fromLTRB(0, (mVolRect?.bottom??mMainRect.bottom )+ ChartStyle.childPadding, mWidth, (mVolRect?.bottom??mMainRect.bottom)  + secondaryHeight);
    }
  }

  //画网格
  void drawGrid(Canvas canvas) {
    mainChartRenderer?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    volChartRenderer?.drawGrid(canvas, ChartStyle.gridRows, ChartStyle.gridColumns);
    secondaryChartRenderer?.drawGrid(canvas,ChartStyle.gridRows, ChartStyle.gridColumns);
  }

  //画日期
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / ChartStyle.gridColumns;
    for (var i = 0; i < ChartStyle.gridColumns; ++i) {
        int index = calculateIndex(i*columnSpace);
        if (outRangeIndex(index)) { continue; }
        var data = datas[index];
        double y = 0.0;
        if (data != null) {
          TextPainter tp = getTextPainter(getDate(datas[index].id),ChartStyle.getDateTextStyle());
          y = size.height - (ChartStyle.bottomDateHigh - tp.height) / 2 - tp.height;
          tp.paint(canvas, Offset(columnSpace * i - tp.width / 2, y));
        }
    }
  }

  //画最大和最小值的标记
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    var y1 = mainChartRenderer.getY(mMainHighMaxValue);
    double itemWidth = canleWidth + ChartStyle.canldeMargin;
    var x1 =  mWidth - ((mMainMaxIndex - mStartIndex) * itemWidth +  startX + canleWidth / 2);
    if (x1 < mWidth / 2) {
      TextPainter tp = getTextPainter("——${NumberUtil.format(mMainHighMaxValue)}", TextStyle(fontSize: 10,color: Colors.white));
      tp.paint(canvas, Offset(x1, y1 - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter("${NumberUtil.format(mMainHighMaxValue)}——", TextStyle(fontSize: 10,color: Colors.white));
      tp.paint(canvas, Offset(x1 - tp.width, y1- tp.height / 2));
    }

    var y2 = mainChartRenderer.getY(mMainLowMinValue);
    var x2 =  mWidth - ((mMainMinIndex - mStartIndex) * itemWidth +  startX + canleWidth / 2);
    if (x2 < mWidth / 2) {
      TextPainter tp = getTextPainter("——${NumberUtil.format(mMainLowMinValue)}", TextStyle(fontSize: 10,color: Colors.white));
      tp.paint(canvas, Offset(x2, y2 - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter("${NumberUtil.format(mMainLowMinValue)}——", TextStyle(fontSize: 10,color: Colors.white));
      tp.paint(canvas, Offset(x2 - tp.width, y2- tp.height / 2));
    }
  }

  TextPainter getTextPainter(text, style) {
    TextSpan span = TextSpan(text: "$text", style: style);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  void drawLongPressCrossLine(Canvas canvas, Size size) {
      var index = calculateIndex(selectX);
      if(outRangeIndex(index)) return;
      var point = datas[index];
      double itemWidth = canleWidth + ChartStyle.canldeMargin;
      double curX = (index - mStartIndex) * itemWidth +  startX + canleWidth / 2 ;
      Paint paintY = Paint()
        ..color = Colors.white12
        ..strokeWidth = canleWidth
        ..isAntiAlias = true;
      double x = mWidth - curX;
      double y = mainChartRenderer.getY(point.close);
      canvas.drawLine(Offset(x, ChartStyle.topPadding), Offset(x, size.height - ChartStyle.bottomDateHigh), paintY);

      Paint paintX = Paint()
        ..color = Colors.white
        ..strokeWidth = ChartStyle.hCrossWidth
        ..isAntiAlias = true;
      // k线图横线
      canvas.drawLine(Offset(0, y), Offset(mWidth, y), paintX);
      canvas.drawCircle(Offset(x, y), 2.0, paintX);
      drawLongPressCrossLineText(canvas, size, y, x, point);
  }

  Paint selectPointPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..color = ChartColors.markerBgColor;
  Paint selectorBorderPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke
    ..color = ChartColors.markerBorderColor;

  void drawLongPressCrossLineText(Canvas canvas,Size size,double y,double curX, KLineEntity entity) {
    TextPainter tp = getTextPainter(NumberUtil.format(entity.close), TextStyle(color: Colors.white,fontSize: 10));
    double padding = 3;
    double textHeight = tp.height + padding * 2;
    double textWidth = tp.width;
    bool isLeft = false;
    if(curX > mWidth / 2) {
      Path path = Path();
      path.moveTo(0,  y - textHeight / 2);
      path.lineTo(0, y + textHeight / 2);
      path.lineTo(textWidth, y + textHeight / 2);
      path.lineTo(textWidth + 10, y);
      path.lineTo(textWidth , y - textHeight / 2);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    } else {
      isLeft = true;
      Path path = Path();
      path.moveTo(mWidth,  y - textHeight / 2);
      path.lineTo(mWidth, y + textHeight / 2);
      path.lineTo(mWidth - textWidth, y + textHeight / 2);
      path.lineTo(mWidth - textWidth - 10, y);
      path.lineTo(mWidth - textWidth , y - textHeight / 2);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(mWidth - textWidth - 2, y - tp.height / 2));
    }
    TextPainter dateTp = getTextPainter(getDate(entity.id),TextStyle(color:Colors.white,fontSize: 10));

    var dateRect = Rect.fromLTRB(curX - dateTp.width / 2 - padding, size.height - ChartStyle.bottomDateHigh, curX + dateTp.width / 2 + padding, size.height);
    canvas.drawRect(dateRect, selectPointPaint);
    canvas.drawRect(dateRect, selectorBorderPaint);
    dateTp.paint(canvas, Offset(curX - dateTp.width / 2, size.height - ChartStyle.bottomDateHigh + ChartStyle.bottomDateHigh / 2 - dateTp.height / 2));

    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(entity, isLeft));
  }



  String getDate(int date) => dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000), mFormats);

  //根据x的位置计算index
  int calculateIndex(double selectX) {
    int index = ((mWidth - startX - selectX) / (canleWidth + ChartStyle.canldeMargin)).toInt() + mStartIndex;
//    print("index $index");
    return index;
  }
  //判断下标是否越界
  bool outRangeIndex(int index) {
    if(index < 0 || index >= datas.length) {
      return true;
    } else {
      return false;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }


}