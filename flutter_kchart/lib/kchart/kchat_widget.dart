import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
//import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart';
import 'utils/number_util.dart';
import 'renderer/chat_painter.dart';
import 'state_enum.dart';


class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final VolState volState;
  final SecondaryState secondaryState;
  final bool isLine;
  final double height;
  final double width;

  KChartWidget(this.datas, {this.width,this.height,this.mainState = MainState.MA,this.volState = VolState.VOL, this.secondaryState = SecondaryState.MACD, this.isLine,int fractionDigits = 2}){
    NumberUtil.fractionDigits = fractionDigits;
  }

  @override
  _KChartWidgetState createState() => _KChartWidgetState();


}

class _KChartWidgetState extends State<KChartWidget>  with SingleTickerProviderStateMixin {

  bool isScale = false, isDrag = false, isLongPress = false;
  double scrollX = 0.0;
  double maxScroll = 0;
  double minScroll = 0;
  double scaleX = 1.0;
  double selectX = 0.0;

  StreamController<InfoWindowEntity> mInfoWindowStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity>();
    scrollX = -(widget.width / 5) + ChartStyle.candleWidth / 2 ;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mInfoWindowStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var dataLength =  widget.datas.length * (ChartStyle.candleWidth + ChartStyle.canldeMargin) - ChartStyle.canldeMargin;
    if(dataLength > widget.width) {
      maxScroll = dataLength - widget.width;
    } else {
      maxScroll = -(widget.width - dataLength);
    }
    var datsScroll =  widget.width - dataLength;
    var normalminScroll =  -(widget.width / 5) + ChartStyle.candleWidth / 2;
    minScroll = min(normalminScroll, -datsScroll);


    scrollX = (scrollX).clamp(minScroll, maxScroll);
    print("maxScroll${maxScroll}");
    return ClipRRect(
      child:  GestureDetector(
        onHorizontalDragStart: (details){
          isDrag = true;
        },
        onHorizontalDragEnd: (details){
          isDrag = false;
        },
        onHorizontalDragUpdate: (details){
          print("details.primaryDelta${details.primaryDelta}");
          setState(() {
            scrollX = (details.primaryDelta + scrollX).clamp(minScroll, maxScroll);
          });
        },
        onScaleStart: (details){
          isScale = true;
        },
        onScaleUpdate: (details){
          setState(() {
            scaleX = (scaleX * details.scale).clamp(0.5, 2.2);
            ChartStyle.candleWidth = ChartStyle.defaultcandleWidth * scaleX;
          });
        },
        onScaleEnd: (details){
          isScale = false;
        },
        onLongPressStart: (details) {
          isLongPress = true;
          selectX = details.localPosition.dx;
          setState(() {

          });
        },
        onLongPressEnd: (details) {
          isLongPress = false;
          setState(() {

          });
        },
        onLongPressMoveUpdate: (details) {
          selectX = details.localPosition.dx;
          setState(() {

          });
        },


        child: Stack(
          children: <Widget>[
            CustomPaint(
              size: Size(widget.width,double.infinity),
              painter: ChartPainter(
                  datas: widget.datas.reversed.toList(),
                  scrollX: scrollX,
                  isLine: widget.isLine,
                  scaleX: scaleX,
                  selectX: selectX,
                  isLongPress: isLongPress,
                  sink: mInfoWindowStream.sink,
                mainState: widget.mainState,
                secondaryState: widget.secondaryState
              ),
            ),
            _buildInfoDialog()
          ],
        ),
      ),
    );
  }

  List<String> infoNames = ["时间", "开", "高", "低", "收", "涨跌额", "涨幅", "成交量"];
  List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress || widget.isLine == true || !snapshot.hasData || snapshot.data.kLineEntity == null)
            return Container();
          KLineEntity entity = snapshot.data.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = upDown / entity.open * 100;
          infos = [
            getDate(entity.id),
            NumberUtil.format(entity.open),
            NumberUtil.format(entity.high),
            NumberUtil.format(entity.low),
            NumberUtil.format(entity.close),
            "${upDown > 0 ? "+" : ""}${NumberUtil.format(upDown)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            NumberUtil.volFormat(entity.vol)
          ];
          return Align(
            alignment: snapshot.data.isLeft ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 25),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                  color: ChartColors.markerBgColor,
                  border: Border.all(color: ChartColors.markerBorderColor, width: 0.5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(infoNames.length, (i) => _buildItem(infos[i].toString(), infoNames[i])),
              ),
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Colors.white;
    if (info.startsWith("+"))
      color = Colors.green;
    else if (info.startsWith("-"))
      color = Colors.red;
    else
      color = Colors.white;
    return Container(
      constraints: BoxConstraints(minWidth: 95, maxWidth: 110, maxHeight: 14.0, minHeight: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("$infoName", style: TextStyle(color: Colors.white, fontSize: ChartStyle.defaultTextSize)),
          SizedBox(width: 5),
          Text(info, style: TextStyle(color: color, fontSize: ChartStyle.defaultTextSize)),
        ],
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000), [yy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }


}