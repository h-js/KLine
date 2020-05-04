import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../entity/k_line_entity.dart';
import '../entity/candle_entity.dart';
import '../chart_style.dart';
import '../utils/number_util.dart';
import '../kchat_widget.dart';

abstract class BaseChartRenderer<T>  {
  double maxValue, minValue;
  double topPadding;
  Rect chartRect;
  double candleWidth;

  double scaleY;

  Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.3
    ..color = ChartColors.gridColor;

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;

  BaseChartRenderer({@required this.chartRect,this.maxValue,this.minValue,this.topPadding,this.candleWidth}) {
    scaleY = chartRect.height / (maxValue - minValue);
  }

  //画对应区域里面的图表
  void drawChart(Canvas canvas, T lastpoint, T curpoint, double curX);

  //画右边的值
  void drawRightText(Canvas canvas, int gridRows);

  //画网格
  void drawGrid(Canvas canvas, int gridRows, int gridColums);

  void drawGradientBgColor(Canvas canvas) {
    LinearGradient linerGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
        colors: ChartColors.kRectShadowColor);
    Shader shader = linerGradient.createShader(chartRect);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    paint.shader = shader;
    canvas.drawRect(Rect.fromLTRB(chartRect.left, chartRect.top - topPadding, chartRect.right, chartRect.bottom), paint);
  }

  //划线公用方法
  void drawLine(Canvas canvas, double lastprice, double curprice, double curX, Color color) {
    curX = curX + candleWidth / 2;
    double lastX = curX - candleWidth - ChartStyle.canldeMargin;
    double x1 = chartRect.width - lastX;
    double y1 = getY(lastprice);
    double x2 = chartRect.width - curX;
    double y2 = getY(curprice);
    chartPaint.color = color;
    canvas.drawLine(Offset(x1, y1),Offset(x2, y2),chartPaint);
  }
  //根据当前的价格计算出
  double getY(double value) => scaleY * (maxValue - value) + chartRect.top;

  String format(double n) {
    return NumberUtil.format(n);
  }
  TextStyle getTextStyle(Color color){
    return TextStyle(fontSize: ChartStyle.defaultTextSize,color: color);
  }
}
