import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../entity/k_line_entity.dart';
import '../entity/candle_entity.dart';
import '../chart_style.dart';
import '../utils/number_util.dart';
import '../kchat_widget.dart';
import 'base_chart_renderer.dart';
import '../state_enum.dart';

class MainChartRenderer extends BaseChartRenderer<CandleEntity> {

  double _contentPadding = 20.0;
  bool isLine = false;
  MainState state;

  Path linePath, lineFillPath;
  Paint linePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0
    ..color = ChartColors.kLineColor;

  Shader lineFillShader;
  Paint lineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  MainChartRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding, bool isLine, double candleWidth, this.state) : super(chartRect: mainRect, maxValue: maxValue, minValue: minValue, topPadding: topPadding, candleWidth: candleWidth)  {
    this.isLine = isLine;
    //这样处理的好处，使蜡烛线不会触及到上下的网格线
    var diff = maxValue - minValue; //计算差
    var newScaleY = (chartRect.height - _contentPadding) / diff; //内容区域高度/差=新的比例
    var newDiff = chartRect.height / newScaleY; //高/新比例=新的差
    var value = (newDiff - diff) / 2; //新差-差/2=y轴需要扩大的值
    if (newDiff > diff) {
      this.scaleY = newScaleY;
      this.maxValue += value;
      this.minValue -= value;
    }
  }

  void drawChart(Canvas canvas, CandleEntity lastpoint, CandleEntity curpoint, double curX) {
    if (!isLine) drawCandle(canvas, curpoint, curX);
    if (lastpoint != null) {
      if (isLine) {
        drawKLine(canvas, lastpoint.close, curpoint.close, curX);
      } else if (state == MainState.MA) {
        drawMaLine(canvas, lastpoint, curpoint, curX);
      } else if (state == MainState.BOLL) {
        drawBoLL(canvas, lastpoint, curpoint, curX);
      }
    }
  }

  void drawCandle(Canvas canvas, CandleEntity curPoint, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    if (open > close) {
      chartPaint.color = ChartColors.upColor;
      canvas.drawRect(Rect.fromLTRB(chartRect.width - curX - candleWidth, close,chartRect.width - curX, open),chartPaint);
      canvas.drawRect(Rect.fromLTRB(chartRect.width - curX - candleWidth / 2 - ChartStyle.candleLineWidth / 2, high, chartRect.width -  curX - candleWidth / 2 +  ChartStyle.candleLineWidth / 2, low),
          chartPaint);
    } else {
      chartPaint.color = ChartColors.dnColor;
      canvas.drawRect(Rect.fromLTRB(chartRect.width - curX - candleWidth, open,chartRect.width - curX, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(chartRect.width -curX -candleWidth / 2 -ChartStyle.candleLineWidth / 2,high,
              chartRect.width - curX - candleWidth / 2 + ChartStyle.candleLineWidth / 2, low),
          chartPaint);
    }
  }

  void drawKLine(Canvas canvas, double lastPrice, double curPrice, double curX) {
    double lastX = curX - candleWidth - ChartStyle.canldeMargin;
    double x1 = chartRect.width - lastX;
    double y1 = getY(lastPrice);
    double x2 = chartRect.width - curX;
    double y2 = getY(curPrice);
    linePath ??= Path();
    linePath.moveTo(x1, y1);
    linePath.cubicTo((x1 + x2) / 2, y1, (x1 + x2) / 2, y2, x2, y2);
    canvas.drawPath(linePath, linePaint);
    linePath.reset();

    lineFillShader ??= LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        tileMode: TileMode.clamp,
        colors: ChartColors.kLineShadowColor)
        .createShader(chartRect);

    lineFillPaint..shader = lineFillShader;
    lineFillPath ??= Path();
    lineFillPath.moveTo(x1, chartRect.height + chartRect.top);
    lineFillPath.lineTo(x1, y1);
    lineFillPath.cubicTo((x1 + x2) / 2, y1, (x1 + x2) / 2, y2, x2, y2);
    lineFillPath.lineTo(x2, chartRect.height + chartRect.top);
    lineFillPath.close();
    canvas.drawPath(lineFillPath, lineFillPaint);
    lineFillPath.reset();
  }

  void drawRightText(Canvas canvas, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      double position = 0;
      position = (gridRows - i) * rowSpace;
      var value = position / scaleY + minValue;
      TextSpan span = TextSpan(
          text: "${NumberUtil.format(value)}",
          style: ChartStyle.getRightTextStyle());
      TextPainter textPainter =
      TextPainter(text: span, textDirection: TextDirection.ltr);
      textPainter.layout();
      double y = 0;
      if (i == 0) {
        y = getY(value);
      } else {
        y = getY(value) - textPainter.height;
      }
      textPainter.paint(canvas, Offset(chartRect.width - textPainter.width, y));
    }
  }

  ///画网格
  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColums) {
    //画每一行的线
    super.drawGradientBgColor(canvas);
    double rowspace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      Offset startOffset = Offset(0, i * rowspace + topPadding);
      Offset endOffset = Offset(chartRect.width, i * rowspace + topPadding);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }
    //画每一列的线
    double colomspace = chartRect.width / gridColums;
    for (int i = 0; i <= gridColums; i++) {
      Offset startOffset = Offset(i * colomspace, 0);
      Offset endOffset = Offset(i * colomspace, chartRect.height + topPadding);
      canvas.drawLine(startOffset, endOffset, gridPaint);
    }

  }

  //画MA线
  void drawMaLine(Canvas canvas, CandleEntity lastpoint, CandleEntity curPoint, double curX) {
    if (curPoint.MA5Price != 0) {
      drawLine(canvas, lastpoint.MA5Price, curPoint.MA5Price, curX,
          ChartColors.ma5Color);
    }
    if (curPoint.MA10Price != 0) {
      drawLine(canvas, lastpoint.MA10Price, curPoint.MA10Price, curX,
          ChartColors.ma10Color);
    }

    if (curPoint.MA30Price != 0) {
      drawLine(canvas, lastpoint.MA30Price, curPoint.MA30Price, curX,
          ChartColors.ma30Color);
    }
  }

  void drawTopText(Canvas canvas, CandleEntity curPoint) {
    List<TextSpan> list = List<TextSpan>();
    if(state == MainState.MA) {
      if(curPoint.MA5Price != 0) {
        TextSpan spanMa5 = TextSpan(text: "MA5:${NumberUtil.format(curPoint.MA5Price)}    ", style: TextStyle(color: ChartColors.ma5Color,fontSize: 10));
        list.add(spanMa5);
      }
      if(curPoint.MA10Price != 0) {
        TextSpan spanMa10 = TextSpan(text: "MA10:${NumberUtil.format(curPoint.MA10Price)}    ", style: TextStyle(color: ChartColors.ma10Color,fontSize: 10));
        list.add(spanMa10);
      }
      if(curPoint.MA30Price != 0) {
        TextSpan spanMa30 = TextSpan(text: "MA30:${NumberUtil.format(curPoint.MA30Price)}    ", style: TextStyle(color: ChartColors.ma30Color,fontSize: 10));
        list.add(spanMa30);
      }
    } else {
        if (curPoint.mb != 0) {
          TextSpan span = TextSpan(text: "BOLL:${NumberUtil.format(curPoint.mb)}    ", style: TextStyle(color: ChartColors.ma5Color,fontSize: 10));
          list.add(span);
        }
        if (curPoint.up != 0) {
          TextSpan span = TextSpan(text: "UP:${NumberUtil.format(curPoint.up)}    ", style: TextStyle(color: ChartColors.ma10Color,fontSize: 10));
          list.add(span);
        }
        if (curPoint.dn != 0) {
          TextSpan span = TextSpan(text: "LB:${NumberUtil.format(curPoint.mb)}    ", style: TextStyle(color: ChartColors.ma30Color,fontSize: 10));
          list.add(span);
        }
    }
    TextSpan span = TextSpan(
      children: list
    );
    TextPainter tpMa5 = TextPainter(text: span, textDirection: TextDirection.ltr);
    tpMa5.layout();
    double y = 6;
    tpMa5.paint(canvas, Offset(10, y));

  }

  //画boll线
  void drawBoLL(Canvas canvas, CandleEntity lastpoint, CandleEntity curPoint, double curX) {
    if (curPoint.up != 0) {
      drawLine(canvas, lastpoint.up, curPoint.up, curX, ChartColors.ma5Color);
    }
    if (curPoint.mb != 0) {
      drawLine(canvas, lastpoint.mb, curPoint.mb, curX, ChartColors.ma10Color);
    }
    if (curPoint.dn != 0) {
      drawLine(canvas, lastpoint.dn, curPoint.dn, curX, ChartColors.ma30Color);
    }
  }
  //根据当前的价格计算出
  double getY(double value) => scaleY * (maxValue - value) + chartRect.top;
}
