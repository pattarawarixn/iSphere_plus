import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;

class ExpansionTileCardDemo extends StatefulWidget {
  @override
  _ExpansionTileCardDemoState createState() => _ExpansionTileCardDemoState();
}

class _Data {
  final String id;
  final String rawData;
  final double temperature;
  final double humid;
  final DateTime timestamp;
  final double barometer;
  final double visible_light;
  final double ir_light;
  final String node;
  final int flag;

  _Data(
      {required this.id,
      required this.rawData,
      required this.temperature,
      required this.humid,
      required this.timestamp,
      required this.barometer,
      required this.visible_light,
      required this.ir_light,
      required this.node,
      required this.flag});

  factory _Data.fromJson(Map<String, dynamic> json) {
    return _Data(
        id: json['_id'].toString(),
        rawData: json['rawData'].toString(),
        temperature: double.parse(json['temperature'].toStringAsFixed(2)),
        humid: double.parse(json['humid'].toStringAsFixed(2)),
        timestamp: new DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(json['timestamp'].toString()),
        barometer: double.parse(json['barometer'].toStringAsFixed(2)),
        visible_light: double.parse(json['visible_light'].toStringAsFixed(2)),
        ir_light: double.parse(json['ir_light'].toStringAsFixed(2)),
        node: json['node'].toString(),
        flag: int.parse(json['flag'].toString()));
  }
}

class _ExpansionTileCardDemoState extends State<ExpansionTileCardDemo> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardD = new GlobalKey();

  bool isFirstTime = true;
  late List<_Data> lastestData;
  var last;
  late Timer timer;
  late ChartSeriesController _chartSeriesController1;
  late ChartSeriesController _chartSeriesController2;
  late ChartSeriesController _chartSeriesController3;
  late ChartSeriesController _chartSeriesController4;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer timer) => _updateData());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<dynamic> _getData() async {
    final response = await http.get(Uri.parse(
        'http://engineer.narit.or.th/ajax/weather_module/api_test.php'));
    var map = json.decode(response.body);
    return map;
  }

  _updateData() async {
    if (last != null) {
      try {
        final response = await http.get(Uri.parse(
            'http://engineer.narit.or.th/ajax/weather_module/api_test.php?id=' +
                last));
        var map = json.decode(response.body);

        List<_Data> temp =
            (map as List).map((item) => _Data.fromJson(item)).toList();

        last = temp.last.id;

        int beforeCount = lastestData.length - 1;

        temp.forEach((element) {
          if (element.timestamp != null) {
            lastestData.add(element);
          }
        });

        int afterCount = lastestData.length - 1;

        int countRemove = afterCount - beforeCount - 1;

        lastestData.removeRange(0, countRemove);

        _chartSeriesController1.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController2.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController3.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController4.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
      } catch (e) {}
    }
  }

  List<_Data> _get(data) {
    List<_Data> listData =
        (data as List).map((item) => _Data.fromJson(item)).toList();
    return listData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          FutureBuilder(
              future: _getData(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (isFirstTime) {
                    lastestData = _get(snapshot.data);
                    last = lastestData.last.id;
                    isFirstTime = false;
                  }
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Text(
                      "Welcome, ------ \nSelect an option",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                  );

                  //TEMPERATURE//
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 25.0),
                      child: SingleChildScrollView(
                        child: ExpansionTileCard(
                          baseColor: Colors.cyan[50],
                          expandedColor: Colors.red[50],
                          key: cardA,
                          title: Text("Flutter Dev's"),
                          subtitle: Text("FLUTTER DEVELOPMENT COMPANY"),
                          children: <Widget>[
                            SfCartesianChart(
                                primaryXAxis: DateTimeAxis(
                                    labelRotation: 90,
                                    intervalType: DateTimeIntervalType.seconds,
                                    edgeLabelPlacement:
                                        EdgeLabelPlacement.shift,
                                    dateFormat: DateFormat.Hms()),
                                // Chart title
                                // Enable legend
                                primaryYAxis: NumericAxis(
                                  isVisible: true,
                                  numberFormat: NumberFormat("##.##", "en_US"),
                                  maximumLabelWidth: 25,
                                  decimalPlaces: 0,
                                  minimum: 0,
                                  maximum: 100,
                                  interval: 10,
                                ),
                                legend: Legend(isVisible: false),
                                // Enable tooltip
                                tooltipBehavior: TooltipBehavior(enable: false),
                                series: <ChartSeries<_Data, DateTime>>[
                                  LineSeries<_Data, DateTime>(
                                      onRendererCreated:
                                          (ChartSeriesController controller) {
                                        // Assigning the controller to the _chartSeriesController.
                                        _chartSeriesController1 = controller;
                                      },
                                      dataSource: lastestData,
                                      xValueMapper: (_Data test, _) =>
                                          test.timestamp,
                                      yValueMapper: (_Data test, _) =>
                                          test.temperature,
                                      name: 'Temperature',
                                      // Enable data label
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true)),
                                ]),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              buttonHeight: 52.0,
                              buttonMinWidth: 90.0,
                              children: <Widget>[
                                FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  onPressed: () {
                                    cardA.currentState?.collapse();
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.arrow_upward),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                      ),
                                      Text('Close'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
                  //HUMIDITY//
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: ExpansionTileCard(
                      baseColor: Colors.cyan[50],
                      expandedColor: Colors.red[50],
                      key: cardB,
                      // leading:
                      //     CircleAvatar(child: Image.asset("assets/images/devs.jpg")),
                      title: Text("Flutter Dev's"),
                      subtitle: Text("FLUTTER DEVELOPMENT COMPANY"),
                      children: <Widget>[
                        SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              dateFormat: DateFormat.Hms(),
                            ),
                            // Chart title
                            // Enable legend
                            primaryYAxis: NumericAxis(
                              isVisible: true,
                              numberFormat: NumberFormat("###.##", "en_US"),
                              maximumLabelWidth: 25,
                              decimalPlaces: 0,
                              minimum: 0,
                              maximum: 100,
                              interval: 10,
                            ),
                            legend: Legend(isVisible: false),
                            // Enable tooltip
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<_Data, DateTime>>[
                              LineSeries<_Data, DateTime>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController2 = controller;
                                  },
                                  dataSource: lastestData,
                                  xValueMapper: (_Data test, _) =>
                                      test.timestamp,
                                  yValueMapper: (_Data test, _) => test.humid,
                                  name: 'Humidity',
                                  // Enable data label
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true)),
                            ]),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceAround,
                          buttonHeight: 52.0,
                          buttonMinWidth: 90.0,
                          children: <Widget>[
                            TextButton(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(4.0)),
                              onPressed: () {
                                cardB.currentState?.collapse();
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.arrow_upward),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                  ),
                                  Text('Close'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  //BAROMETER//
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: ExpansionTileCard(
                      baseColor: Colors.cyan[50],
                      expandedColor: Colors.red[50],
                      key: cardC,
                      // leading:
                      //     CircleAvatar(child: Image.asset("assets/images/devs.jpg")),
                      title: Text("Flutter Dev's"),
                      subtitle: Text("FLUTTER DEVELOPMENT COMPANY"),
                      children: <Widget>[
                        SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                                labelRotation: 90,
                                intervalType: DateTimeIntervalType.seconds,
                                dateFormat: DateFormat.Hms()),
                            // Chart title
                            // Enable legend
                            primaryYAxis: NumericAxis(
                              isVisible: true,
                              numberFormat: NumberFormat("##.###", "en_US"),
                              maximumLabelWidth: 25,
                              //minimum: 0,
                              //maximum: 100,
                              //interval: 10,
                            ),
                            legend: Legend(isVisible: false),
                            // Enable tooltip
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<_Data, DateTime>>[
                              LineSeries<_Data, DateTime>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController3 = controller;
                                  },
                                  dataSource: lastestData,
                                  xValueMapper: (_Data test, _) =>
                                      test.timestamp,
                                  yValueMapper: (_Data test, _) =>
                                      test.barometer,
                                  name: 'Barometer',
                                  // Enable data label
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true)),
                            ]),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceAround,
                          buttonHeight: 52.0,
                          buttonMinWidth: 90.0,
                          children: <Widget>[
                            TextButton(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(4.0)),
                              onPressed: () {
                                cardC.currentState?.collapse();
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.arrow_upward),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                  ),
                                  Text('Close'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  //VISIBLE LIGHT//
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: ExpansionTileCard(
                      baseColor: Colors.cyan[50],
                      expandedColor: Colors.red[50],
                      key: cardD,
                      // leading:
                      //     CircleAvatar(child: Image.asset("assets/images/devs.jpg")),
                      title: Text("Flutter Dev's"),
                      subtitle: Text("FLUTTER DEVELOPMENT COMPANY"),
                      children: <Widget>[
                        SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                                labelRotation: 90,
                                intervalType: DateTimeIntervalType.seconds,
                                dateFormat: DateFormat.Hms()),
                            // Chart title
                            // Enable legend
                            primaryYAxis: NumericAxis(
                                isVisible: true,
                                numberFormat: NumberFormat("###.##", "en_US"),
                                maximumLabelWidth: 25),
                            legend: Legend(isVisible: false),
                            // Enable tooltip
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<_Data, DateTime>>[
                              LineSeries<_Data, DateTime>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController4 = controller;
                                  },
                                  dataSource: lastestData,
                                  xValueMapper: (_Data test, _) =>
                                      test.timestamp,
                                  yValueMapper: (_Data test, _) =>
                                      test.visible_light,
                                  name: 'Visible Light',
                                  // Enable data label
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: false)),
                            ]),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ))),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceAround,
                          buttonHeight: 52.0,
                          buttonMinWidth: 90.0,
                          children: <Widget>[
                            TextButton(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(4.0)),
                              onPressed: () {
                                cardD.currentState?.collapse();
                              },
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.arrow_upward),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                  ),
                                  Text('Close'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                    child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                    
                  ),
                ));
              }),
        ],
      ),
    );
  }
}

// SfCartesianChart chartTemp = SfCartesianChart(
//     primaryXAxis: DateTimeAxis(
//         labelRotation: 90,
//         intervalType: DateTimeIntervalType.seconds,
//         edgeLabelPlacement: EdgeLabelPlacement.shift,
//         dateFormat: DateFormat.Hms()),
//     // Chart title
//     // Enable legend
//     primaryYAxis: NumericAxis(
//       isVisible: true,
//       numberFormat: NumberFormat("##.##", "en_US"),
//       maximumLabelWidth: 25,
//       decimalPlaces: 0,
//       minimum: 0,
//       maximum: 100,
//       interval: 10,
//     ),
//     legend: Legend(isVisible: false),
//     // Enable tooltip
//     tooltipBehavior: TooltipBehavior(enable: false),
//     series: <ChartSeries<_Data, DateTime>>[
//       LineSeries<_Data, DateTime>(
//           onRendererCreated: (ChartSeriesController controller) {
//             // Assigning the controller to the _chartSeriesController.
//             _chartSeriesController1 = controller;
//           },
//           dataSource: lastestData,
//           xValueMapper: (_Data test, _) => test.timestamp,
//           yValueMapper: (_Data test, _) => test.temperature,
//           name: 'Temperature',
//           // Enable data label
//           dataLabelSettings: DataLabelSettings(isVisible: true)),
//     ]);
// SfCartesianChart chartHumi = SfCartesianChart(
//     primaryXAxis: DateTimeAxis(
//       labelRotation: 90,
//       intervalType: DateTimeIntervalType.seconds,
//       dateFormat: DateFormat.Hms(),
//     ),
//     // Chart title
//     // Enable legend
//     primaryYAxis: NumericAxis(
//       isVisible: true,
//       numberFormat: NumberFormat("###.##", "en_US"),
//       maximumLabelWidth: 25,
//       decimalPlaces: 0,
//       minimum: 0,
//       maximum: 100,
//       interval: 10,
//     ),
//     legend: Legend(isVisible: false),
//     // Enable tooltip
//     tooltipBehavior: TooltipBehavior(enable: true),
//     series: <ChartSeries<_Data, DateTime>>[
//       LineSeries<_Data, DateTime>(
//           onRendererCreated: (ChartSeriesController controller) {
//             // Assigning the controller to the _chartSeriesController.
//             _chartSeriesController2 = controller;
//           },
//           dataSource: lastestData,
//           xValueMapper: (_Data test, _) => test.timestamp,
//           yValueMapper: (_Data test, _) => test.humid,
//           name: 'Humidity',
//           // Enable data label
//           dataLabelSettings: DataLabelSettings(isVisible: true)),
//     ]);
// SfCartesianChart chartBaro = SfCartesianChart(
//     primaryXAxis: DateTimeAxis(
//         labelRotation: 90,
//         intervalType: DateTimeIntervalType.seconds,
//         dateFormat: DateFormat.Hms()),
//     // Chart title
//     // Enable legend
//     primaryYAxis: NumericAxis(
//       isVisible: true,
//       numberFormat: NumberFormat("##.###", "en_US"),
//       maximumLabelWidth: 25,
//       //minimum: 0,
//       //maximum: 100,
//       //interval: 10,
//     ),
//     legend: Legend(isVisible: false),
//     // Enable tooltip
//     tooltipBehavior: TooltipBehavior(enable: true),
//     series: <ChartSeries<_Data, DateTime>>[
//       LineSeries<_Data, DateTime>(
//           onRendererCreated: (ChartSeriesController controller) {
//             // Assigning the controller to the _chartSeriesController.
//             _chartSeriesController3 = controller;
//           },
//           dataSource: lastestData,
//           xValueMapper: (_Data test, _) => test.timestamp,
//           yValueMapper: (_Data test, _) => test.barometer,
//           name: 'Barometer',
//           // Enable data label
//           dataLabelSettings: DataLabelSettings(isVisible: true)),
//     ]);
// SfCartesianChart chartVisi = SfCartesianChart(
//     primaryXAxis: DateTimeAxis(
//         labelRotation: 90,
//         intervalType: DateTimeIntervalType.seconds,
//         dateFormat: DateFormat.Hms()),
//     // Chart title
//     // Enable legend
//     primaryYAxis: NumericAxis(
//         isVisible: true,
//         numberFormat: NumberFormat("###.##", "en_US"),
//         maximumLabelWidth: 25),
//     legend: Legend(isVisible: false),
//     // Enable tooltip
//     tooltipBehavior: TooltipBehavior(enable: true),
//     series: <ChartSeries<_Data, DateTime>>[
//       LineSeries<_Data, DateTime>(
//           onRendererCreated: (ChartSeriesController controller) {
//             // Assigning the controller to the _chartSeriesController.
//             _chartSeriesController4 = controller;
//           },
//           dataSource: lastestData,
//           xValueMapper: (_Data test, _) => test.timestamp,
//           yValueMapper: (_Data test, _) => test.visible_light,
//           name: 'Visible Light',
//           // Enable data label
//           dataLabelSettings: DataLabelSettings(isVisible: false)),
//     ]);
