import 'package:flutter/material.dart';
import 'kchart/kchat_widget.dart';
import 'package:flutter/services.dart';
import 'kchart/flutter_kchart.dart';
import 'dart:convert';
import 'dart:math';
import 'kline_moretime_widget.dart';
import 'kchart/chart_style.dart';
import 'kline_indicators_widget.dart';
import 'kline_data_controller.dart';

class KLineVerticalWidget extends StatefulWidget {

  KLineVerticalWidget({@required this.datas,this.dataController});

  KLineDataController dataController;
  List<KLineEntity> datas = [];

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _KLineVerticalWidgetState();
  }

}

class _KLineVerticalWidgetState extends State<KLineVerticalWidget> with TickerProviderStateMixin {


  KLineDataController dataController;

  TabController controller;

  Animation<Rect> timeRect;
  AnimationController timeAnimationController;
  RectTween timePosition;


  Animation<Rect> indicatorsRect;
  AnimationController indicatorsAnimationController;
  RectTween indicatorsPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dataController = widget.dataController;

    controller =
        TabController(initialIndex: 0, length: dataController.topPeriodItems.length, vsync: this);
    controller.addListener(() {

    });

    timeAnimationController = new AnimationController(vsync: this);
    timePosition = new RectTween(
      begin: new Rect.fromLTRB(0.0, -40, 0, 0.0),
      end: new Rect.fromLTRB(0.0, 5.0, 0.0, 0.0),
    );
    timeRect = timePosition.animate(timeAnimationController);

    indicatorsAnimationController = new AnimationController(vsync: this);
    indicatorsPosition = new RectTween(
      begin: new Rect.fromLTRB(0.0, -100, 0, 0.0),
      end: new Rect.fromLTRB(0.0, 5.0, 0.0, 0.0),
    );
    indicatorsRect = indicatorsPosition.animate(indicatorsAnimationController);
  }

  void  indicatorsShowOrHide() {
    hidePeriod();
    if(indicatorsAnimationController.value == 0) {
      indicatorsAnimationController.animateTo(1.0,duration: Duration(milliseconds: 300),curve: Curves.linear);
    } else if (indicatorsAnimationController.value == 1) {
      indicatorsAnimationController.animateTo(0,duration: Duration(milliseconds: 300),curve: Curves.linear);
    }
  }

  void periodShowOrHide() {
    hideindicators();
    if(timeAnimationController.value == 0) {
      timeAnimationController.animateTo(1.0,duration: Duration(milliseconds: 300),curve: Curves.linear);
    } else {
      hidePeriod();
    }
  }

  void hidePeriod() {
    timeAnimationController.animateTo(0.0,duration: Duration(milliseconds: 300),curve: Curves.linear);
  }

  void hideindicators() {
    indicatorsAnimationController.animateTo(0.0,duration: Duration(milliseconds: 300),curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return KLineDataWidgetController(
      dataController: dataController,
      child: Column(
        children: <Widget>[
          Container(
            color: Color(0xff131E30),
            child: Row(
              children: <Widget>[

                Builder(builder: (BuildContext context) {
                return  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    child: TabBar(tabs: dataController.topPeriodItems.map((e) => Tab(text: e.name)).toList(),
                      labelStyle: TextStyle(fontSize: 12),
                      controller: controller,
                      labelPadding: EdgeInsets.all(0),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor:  Color(0xff1E80D2),
                      unselectedLabelColor: Color(0xff6882A1),//36 128 210
                      onTap: (int index){
                        if (index == dataController.topPeriodItems.length - 1) {
                          periodShowOrHide();
                        } else {
                          hidePeriod();
                          hideindicators();
                          KLineDataWidgetController.of(context).changePeriod(dataController.topPeriodItems[index]);
                        }
                      },
                    ),
                  );

                }),

                Container(
                  width: 0.5,
                  height: 20,
                  color: Color(0xff3D536c),
                ),
                Expanded(child: Center(
                  child: IconButton(icon: Icon(Icons.view_module,color: Color(0xff3D536c)), onPressed: indicatorsShowOrHide),
                ))
              ],
            ),
          ),
          Builder(builder: (BuildContext context) {
            return  Expanded(child: Stack(
              children: <Widget>[
                Container(
                  height: 450,
                  width: MediaQuery.of(context).size.width,
                  child: KChartWidget(
                    widget.datas,
                    width:MediaQuery.of(context).size.width,
                    height: 450,
                    isLine: KLineDataWidgetController.of(context).isLine,
                    mainState: dataController.mainState,
                    secondaryState: dataController.secondaryState,
                    volState: VolState.VOL,
                    fractionDigits: 2,
                  ),
                ),
                RelativePositionedTransition(rect: timeRect, size: Size(0, 0), child: Align(
                  alignment: Alignment.topCenter,
                  child:  KlineMoreTimeWidght(periods: dataController.flodPeriodItems,hideClick: (){
                    hidePeriod();
                  },),
                )),

                RelativePositionedTransition(rect: indicatorsRect, size: Size(0, 0), child: Align(
                  alignment: Alignment.topCenter,
                  child:   KlineIndicatorsWidget(mainStates: dataController.mainStates,secondaryStates: dataController.secondaryStates,hideClick: (){
                    hideindicators();
                  },),
                ))

              ],
            )
            );
          }),


        ],
      ),
    );
  }

}