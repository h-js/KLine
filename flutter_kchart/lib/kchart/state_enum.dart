enum MainState { MA, BOLL, NONE }
enum VolState { VOL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class KLineMainStateModel {
  MainState state;
  String name;
  bool isSelect;
  KLineMainStateModel({this.state,this.name,this.isSelect});
  static List<KLineMainStateModel> defaultModels() {
    var model1 = KLineMainStateModel(state: MainState.MA,name: "MA",isSelect: true);
    var model2 = KLineMainStateModel(state: MainState.BOLL,name: "BOLL",isSelect: false);
    return [model1,model2];
  }
}

class KLineSecondaryStateModel {
  SecondaryState state;
  String name;
  bool isSelect;
  KLineSecondaryStateModel({this.state,this.name,this.isSelect});
  static List<KLineSecondaryStateModel> defaultModels() {
    var model1 = KLineSecondaryStateModel(state: SecondaryState.MACD,name: "MACD",isSelect: true);
    var model2 = KLineSecondaryStateModel(state: SecondaryState.KDJ,name: "KDJ",isSelect: false);
    var model3 = KLineSecondaryStateModel(state: SecondaryState.RSI,name: "RSI",isSelect: false);
    var model4 = KLineSecondaryStateModel(state: SecondaryState.WR,name: "WR",isSelect: false);
    return [model1,model2,model3,model4];
  }
}

class KLinePeriodModel {

  String name;
  String period;
  KLinePeriodModel({this.name,this.period});

  static List<KLinePeriodModel> topModels() {
    var model1 = KLinePeriodModel(name: "分时",period: "1min");
    var model2 = KLinePeriodModel(name: "15分",period: "15min");
    var model3 = KLinePeriodModel(name: "1小时",period: "60min");
    var model4 = KLinePeriodModel(name: "4小时",period: "4hour");
    var model5 = KLinePeriodModel(name: "日线",period: "1day");
    var model6 = KLinePeriodModel(name: "更多",period: "-1");
    return [model1,model2,model3,model4,model5,model6];
  }


  static List<KLinePeriodModel> foldModels() {
    var model1 = KLinePeriodModel(name: "1分",period: "1min");
    var model2 = KLinePeriodModel(name: "5分",period: "5min");
    var model3 = KLinePeriodModel(name: "30分",period: "30min");
    var model4 = KLinePeriodModel(name: "周线",period: "1week");
    var model5 = KLinePeriodModel(name: "一月",period: "1mon");
    return [model1,model2,model3,model4,model5];
  }

  static KLinePeriodModel defaultModel() {
    var model3 = KLinePeriodModel(name: "分时",period: "1min");
    return model3;
  }

}