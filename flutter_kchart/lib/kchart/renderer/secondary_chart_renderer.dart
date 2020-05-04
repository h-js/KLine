import 'base_chart_renderer.dart';
import '../entity/candle_entity.dart';
import 'package:flutter/material.dart';
import '../entity/macd_entity.dart';
import '../chart_style.dart';
import '../kchat_widget.dart';
import '../utils/number_util.dart';
import '../state_enum.dart';

class SecondaryChartRenderer extends BaseChartRenderer<MACDEntity> {

  double mMACDWidth = ChartStyle.macdWidth;
  SecondaryState state;

  SecondaryChartRenderer(Rect mainRect, double maxValue, double minValue, double topPadding, double candleWidth,this.state)
      : super(chartRect: mainRect, maxValue: maxValue, minValue: minValue, topPadding: topPadding, candleWidth: candleWidth);

  @override
  void drawChart(Canvas canvas, MACDEntity lastpoint, MACDEntity curpoint, double curX) {
     if(state == SecondaryState.MACD) {
       drawMACD(canvas,lastpoint, curpoint, curX);
     } else if (state == SecondaryState.KDJ && lastpoint != null) {
       if (lastpoint.k != 0) drawLine(canvas, lastpoint.k, curpoint.k, curX, ChartColors.kColor);
       if (lastpoint.d != 0) drawLine(canvas, lastpoint.d, curpoint.d, curX, ChartColors.dColor);
       if (lastpoint.j != 0) drawLine(canvas, lastpoint.j, curpoint.j, curX, ChartColors.jColor);
     } else if (state == SecondaryState.RSI && lastpoint != null) {
       if (lastpoint.rsi != 0) drawLine(canvas, lastpoint.rsi, curpoint.rsi, curX, ChartColors.rsiColor);
     } else if (state == SecondaryState.WR && lastpoint != null) {
       if (lastpoint.r != 0) drawLine(canvas, lastpoint.r, curpoint.r, curX, ChartColors.wrColor);
     }
  }


  void drawMACD(Canvas canvas,MACDEntity lastPoint,  MACDEntity curPoint, double curX) {
    double macdCenterX = (chartRect.width - (curX + candleWidth / 2));
    double macdY = getY(curPoint.macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd > 0) {
      canvas.drawRect(
          Rect.fromLTRB(macdCenterX - r, macdY, macdCenterX + r, zeroy), chartPaint..color = ChartColors.upColor);
    } else {
      canvas.drawRect(
          Rect.fromLTRB(macdCenterX - r, zeroy, macdCenterX + r, macdY), chartPaint..color = ChartColors.dnColor);
    }
    if(lastPoint != null) {
      if (lastPoint.dif != 0) {
        drawLine(canvas,lastPoint.dif, curPoint.dif, curX, ChartColors.difColor);
      }
      if (lastPoint.dea != 0) {
        drawLine(canvas, lastPoint.dea, curPoint.dea, curX, ChartColors.deaColor);
      }
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColums) {
    super.drawGradientBgColor(canvas);
    canvas.drawLine(Offset(0, chartRect.bottom), Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColums;
    for(int i = 0; i < gridColums; i++) {
      canvas.drawLine(Offset(i * columnSpace, chartRect.top - topPadding), Offset(i * columnSpace, chartRect.bottom), gridPaint);
    }
  }

  @override
  void drawRightText(Canvas canvas, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${NumberUtil.format(maxValue)}", style: ChartStyle.getRightTextStyle()), textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${NumberUtil.format(minValue)}", style: ChartStyle.getRightTextStyle()), textDirection: TextDirection.ltr);
    minTp.layout();
    maxTp.paint(canvas, Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas, Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  void drawTopText(Canvas canvas, MACDEntity data) {
    List<TextSpan> children = List<TextSpan>();
    switch (state) {
      case SecondaryState.MACD:
         children.add(TextSpan(text: "MACD(12,26,9)    ", style: getTextStyle(ChartColors.yAxisTextColor)));
          if (data.macd != 0)
            children.add(TextSpan(text: "MACD:${format(data.macd)}    ", style: getTextStyle(ChartColors.macdColor)));
          if (data.dif != 0)
            children.add(TextSpan(text: "DIF:${format(data.dif)}    ", style: getTextStyle(ChartColors.difColor)));
          if (data.dea != 0)
            children.add(TextSpan(text: "DEA:${format(data.dea)}    ", style: getTextStyle(ChartColors.deaColor)));
        break;
      case SecondaryState.KDJ:
         children.add(TextSpan(text: "KDJ(14,1,3)    ", style: getTextStyle(ChartColors.yAxisTextColor)));
          if (data.k != 0)
            children.add(TextSpan(text: "K:${format(data.k)}    ", style: getTextStyle(ChartColors.kColor)));
          if (data.d != 0)
            children.add(TextSpan(text: "D:${format(data.d)}    ", style: getTextStyle(ChartColors.dColor)));
          if (data.j != 0)
            children.add(TextSpan(text: "J:${format(data.j)}    ", style: getTextStyle(ChartColors.jColor)));
        break;
      case SecondaryState.RSI:
        children.add(TextSpan(text: "RSI(14):${format(data.rsi)}    ", style: getTextStyle(ChartColors.rsiColor)));

        break;
      case SecondaryState.WR:
        children.add(TextSpan(text: "WR(14):${format(data.r)}    ", style: getTextStyle(ChartColors.wrColor)));
        break;
      default:
        break;
    }
    TextPainter tp = TextPainter(text: TextSpan(children: children ?? []), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(10, chartRect.top - topPadding));
  }


}