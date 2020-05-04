import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kchart/flutter_kchart.dart';
import 'dart:convert';
import 'kchart/chart_style.dart';
import 'kline_vertical_widget.dart';
import 'kline_data_controller.dart';
import 'network/httptool.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'USTD-BTC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  List<KLineEntity> datas = [];
  bool showLoading = true;
  KLineDataController dataController = KLineDataController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData(dataController.periodModel.period);
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      Map tick = parseJson['tick'];
      var bids = tick['bids'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
      var asks = tick['asks'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
//      initDepth(bids, asks);
    });

    dataController.changePeriodClick = (KLinePeriodModel model){
      getData(model.period);
    };

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: ChartColors.bgColor,
      body: Stack(
        children: <Widget>[
          KLineVerticalWidget(datas: datas, dataController: dataController),
          Offstage(
            offstage: !showLoading,
            child:  Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: CircularProgressIndicator()
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void getData(String period) async {
//    String result;
//    print('获取数据失败,获取本地数据');

    setState(() {
      datas = [];
      showLoading = true;
    });
    Map<String,dynamic> results = await  HttpTool.tool.get('https://api.huobi.pro/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt', null);
    List list = results["data"];
    datas = list.map((item) => KLineEntity.fromJson(item)).toList().reversed.toList().cast<KLineEntity>();
    DataUtil.calculate(datas);
    showLoading = false;
    setState(() {});




//      Map parseJson = json.decode(result);
//      List list = parseJson['data'];
//      datas = list.map((item) => KLineEntity.fromJson(item)).toList().reversed.toList().cast<KLineEntity>();
//      DataUtil.calculate(datas);
//      showLoading = false;
//      setState(() {});

  }
}
