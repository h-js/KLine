import 'package:flutter/foundation.dart';
import 'kchart/flutter_kchart.dart';
import 'package:flutter/material.dart';

class KLineDataController extends ChangeNotifier {

  List<KLineMainStateModel> mainStates;
  List<KLineSecondaryStateModel> secondaryStates;

  //默认显示的几个时间k线
  List<KLinePeriodModel> topPeriodItems;

  //点击更多展开时候的数据
  List<KLinePeriodModel> flodPeriodItems;

  MainState mainState;

  SecondaryState  secondaryState;

  bool isLine;

  KLinePeriodModel periodModel;

  void Function(KLinePeriodModel) changePeriodClick;

  KLineDataController() {
    mainStates = KLineMainStateModel.defaultModels();
    secondaryStates = KLineSecondaryStateModel.defaultModels();
    topPeriodItems = KLinePeriodModel.topModels();
    flodPeriodItems = KLinePeriodModel.foldModels();
    mainState = MainState.NONE;
    secondaryState = SecondaryState.NONE;
    isLine = true;
    periodModel = KLinePeriodModel.defaultModel();
  }


  void changeMainState(MainState state) {
    mainState = state;
    notifyListeners();
  }

  void changeSecondaryState(SecondaryState state) {
    secondaryState = state;
    notifyListeners();
  }


  void changePeriod(KLinePeriodModel periodModel) {
    if(periodModel.name == this.periodModel.name) {
      return;
    }
    this.periodModel = periodModel;
    if(periodModel.name == "分时") {
      isLine = true;
    } else {
      isLine = false;
    }
    if(this.flodPeriodItems.map((e) => e.name).toList().contains(periodModel.name)) {
      this.topPeriodItems.last.name = periodModel.name;
    } else {
      this.topPeriodItems.last.name = "更多";
    }
    changePeriodClick(periodModel);
    notifyListeners();
  }

}

class KLineDataWidgetController extends StatefulWidget {

  const KLineDataWidgetController({
    Key key,
    @required this.child,
    @required this.dataController
  }) : super(key: key);

  final Widget child;
  final KLineDataController dataController;

  static KLineDataController of(BuildContext context) {
    final _KLineControllerScope scope =
    context.inheritFromWidgetOfExactType(_KLineControllerScope);
    return scope?.controller;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _KLineDataWidgetControllerState();
  }

}

class _KLineDataWidgetControllerState extends State<KLineDataWidgetController> {

  KLineDataController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = widget.dataController;
    _controller.addListener(_onController);
  }

  void _onController() {
    print("_onController");
      setState(() {
      });
  }


  @override
  Widget build(BuildContext context) {
    return _KLineControllerScope(
      controller: _controller,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onController);
    _controller.dispose();
    super.dispose();

  }

}




class _KLineControllerScope extends InheritedWidget {

  final KLineDataController controller;

  _KLineControllerScope({Key key,this.controller,Widget child}) : super(key: key,child: child);

  @override
  bool updateShouldNotify(_KLineControllerScope oldWidget) {
    // TODO: implement updateShouldNotify
    return  true; //  controller != oldWidget.controller;
  }


}

