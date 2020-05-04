import 'base_chart_renderer.dart';
import 'package:flutter/material.dart';
import '../entity/candle_entity.dart';
import '../entity/volume_entity.dart';
import '../chart_style.dart';
import '../utils/number_util.dart';


class VolChartRenderer extends BaseChartRenderer<VolumeEntity> {


  VolChartRenderer(Rect mainRect, double maxValue, double minValue, double topPadding, double candleWidth)
      : super(chartRect: mainRect, maxValue: maxValue, minValue: minValue, topPadding: topPadding, candleWidth: candleWidth);

  @override
  void drawChart(Canvas canvas, VolumeEntity lastpoint, VolumeEntity curpoint, double curX) {
    drawVolChart(canvas, curpoint, curX);
    if (lastpoint != null) {
      if(lastpoint.MA5Volume != 0) {
        drawLine(canvas, lastpoint.MA5Volume, curpoint.MA5Volume, curX, ChartColors.ma5Color);
      }
      if(lastpoint.MA10Volume != 0) {
        drawLine(canvas, lastpoint.MA10Volume, curpoint.MA10Volume, curX, ChartColors.ma10Color);
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
    TextSpan span = TextSpan(text: "${NumberUtil.volFormat(maxValue)}", style: ChartStyle.getRightTextStyle());
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(chartRect.width - tp.width, chartRect.top - topPadding));
  }

  void drawTopText(Canvas canvas, VolumeEntity data) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(text: "VOL:${NumberUtil.volFormat(data.vol)}    ", style: TextStyle(color: ChartColors.volColor,fontSize: 10)),
        TextSpan(text: "MA5:${NumberUtil.volFormat(data.MA5Volume)}    ", style:TextStyle(color: ChartColors.ma5Color,fontSize: 10)),
        TextSpan(text: "MA10:${NumberUtil.volFormat(data.MA10Volume)}    ", style: TextStyle(color: ChartColors.ma10Color,fontSize: 10)),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(10, chartRect.top - topPadding));
  }

  void drawVolChart(Canvas canvas,VolumeEntity curpoint, double curX) {

    var right =  chartRect.width - curX;
    var left = right - candleWidth;
    var bottom = chartRect.bottom;
    var top = getY(curpoint.vol);
    var rect = Rect.fromLTRB(left, top, right, bottom);
    if(curpoint.close > curpoint.open) chartPaint.color = ChartColors.upColor;
    else chartPaint.color = ChartColors.dnColor;
    canvas.drawRect(rect, chartPaint);
  }

  @override
  double getY(double value) {
    // TODO: implement getY
    if(maxValue == 0) return chartRect.bottom;

    return (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;
  }

}