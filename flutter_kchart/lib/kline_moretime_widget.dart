import 'package:flutter/material.dart';
import 'kchart/chart_style.dart';
import 'kchart/flutter_kchart.dart';
import 'kline_data_controller.dart';

class KlineMoreTimeWidght extends StatelessWidget {

  KlineMoreTimeWidght({@required this.periods,this.hideClick});

  VoidCallback hideClick;

  final List<KLinePeriodModel> periods;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    LinearGradient linerGradient =
    return Container(
      margin: EdgeInsets.only(left: 5,right: 5),
      decoration: BoxDecoration(
          border: Border.all(color: ChartColors.gridColor,width: 0.5),
          color: ChartColors.bgColor,
          gradient:LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
          colors: ChartColors.kRectShadowColor)),
      height: 40,
      child: ListView.builder(itemBuilder: (BuildContext context,int index){
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
                hideClick();
                KLineDataWidgetController.of(context).changePeriod(periods[index]);
            },
            child:  Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text(periods[index].name,style: ChartStyle.getIndicatorTextStyle()),
            ),
          );
      },
        itemCount: periods.length,
        scrollDirection: Axis.horizontal,
      )
    );
  }
}