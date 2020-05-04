import 'package:flutter/material.dart';
import 'kchart/flutter_kchart.dart';
import 'kline_data_controller.dart';

class KlineIndicatorsWidget extends StatelessWidget {
  List<KLineMainStateModel> mainStates;
  List<KLineSecondaryStateModel> secondaryStates;
  KlineIndicatorsWidget({this.mainStates, this.secondaryStates,this.hideClick});

  VoidCallback hideClick;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 100,
      margin: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        color: ChartColors.bgColor,
          border: Border.all(color: ChartColors.gridColor, width: 0.5)),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 10)),
              Text(
                "主图",
                style: ChartStyle.getIndicatorTextStyle(),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                width: 0.5,
                height: 15,
                color: ChartColors.gridColor,
              ),
              Expanded(
                  child: Container(
                height: 30,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (){
                        hideClick();
                        KLineDataWidgetController.of(context).changeMainState(mainStates[index].state);
                      },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Center(
                          child: Text(mainStates[index].name,
                              style: ChartStyle.getIndicatorTextStyle(
                                  isSelect: mainStates[index].state == KLineDataWidgetController.of(context).mainState)),
                        ),
                      ),
                    );
                  },
                  itemCount: mainStates.length,
                  scrollDirection: Axis.horizontal,
                ),
              )),
              IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: KLineDataWidgetController.of(context).mainState == MainState.NONE ? Color(0xff3D536c) : Color(0xffBBBBBB),
                  ),
                  onPressed: (){
                    hideClick();
                    KLineDataWidgetController.of(context).changeMainState(MainState.NONE);
                  })
            ],
          ),
          Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 10)),
              Text(
                "副图",
                style: ChartStyle.getIndicatorTextStyle(),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                width: 0.5,
                height: 15,
                color: ChartColors.gridColor,
              ),
              Expanded(
                  child: Container(
                height: 30,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (){
                        hideClick();
                      KLineDataWidgetController.of(context).changeSecondaryState(secondaryStates[index].state);
                    },
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      child: Center(
                        child: Text(secondaryStates[index].name,
                            style: ChartStyle.getIndicatorTextStyle(
                                isSelect: secondaryStates[index].state == KLineDataWidgetController.of(context).secondaryState)),
                      ),
                    ),
                    );
                  },
                  itemCount: secondaryStates.length,
                  scrollDirection: Axis.horizontal,
                ),
              )),
              IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color:KLineDataWidgetController.of(context).secondaryState == SecondaryState.NONE ? Color(0xff3D536c) : Color(0xffBBBBBB),
                  ),
                  onPressed: (){
                    hideClick();
                    KLineDataWidgetController.of(context).changeSecondaryState(SecondaryState.NONE);
                  })
            ],
          ),
        ],
      ),
    );
  }
}
