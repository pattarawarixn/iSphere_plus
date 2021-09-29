import 'dart:convert';
// import 'dart:ffi';

import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:blinking_text/blinking_text.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

class WeatherData {
  final String? returnMessage;
  final String? deviceName;
  final String? fieldName;
  final DateTime? dataTimeStamp;
  final String? stationName;
  final String value;
  final String? dataType;

  WeatherData(
      {required this.returnMessage,
      required this.deviceName,
      required this.fieldName,
      required this.dataTimeStamp,
      required this.stationName,
      required this.value,
      required this.dataType});

  factory WeatherData.fromJson(dynamic json) {
    return WeatherData(
      returnMessage: json['ReturnMessage'] as String?,
      deviceName: json['DeviceName'] as String?,
      fieldName: json['FieldName'] as String?,
      dataTimeStamp: DateFormat("dd/MM/yyyy hh:mm:ss a")
          .parse(json['DataTimeStamp'].toString()),
      stationName: json['StationName'] as String?,
      value: json['Value'].toString(),
      dataType: json['DataType'].toString(),
    );
  }
}

class ExpansionTileCardDemo extends StatefulWidget {
  @override
  _ExpansionTileCardDemoState createState() => _ExpansionTileCardDemoState();
}

class _ExpansionTileCardDemoState extends State<ExpansionTileCardDemo> {
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = new GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardD = new GlobalKey();
  double currentTemp = 0;
  double currentHumi = 0;
  double currentCloud = 0;
  double currentRain = 0;
  double currentSky = 0;
  double currentDew = 0;
  List<WeatherData> lastTempOut = [];
  List<WeatherData> lastOutHumi = [];
  List<WeatherData> lastOutCloud = [];
  List<WeatherData> lastOutRain = [];
  List<WeatherData> lastOutSky = [];
  List<WeatherData> lastOutDew = [];
  bool _hasBeenPressed = false;
  bool _notifyHumi = false;
  bool _notifyCloud = false;
  bool _notifyRain = false;
  bool _notifySky = false;

  double nowBadHumi = 0;
  double timestampBadHumi = 0;
  double nowGoodHumi = 0;
  double timestampGoodHumi = 0;
  double nowBadCloud = 0;
  double timestampBadCloud = 0;
  double nowGoodCloud = 0;
  double timestampGoodCloud = 0;
  double nowBadRain = 0;
  double timestampBadRain = 0;
  double nowGoodRain = 0;
  double timestampGoodRain = 0;
  double nowBadSky = 0;
  double timestampBadSky = 0;
  double nowGoodSky = 0;
  double timestampGoodSky = 0;
  double alertBadHumi = 0;
  double alertBadCloud = 0;
  double alertBadRain = 0;
  double alertBadSky = 0;
  double alertGoodHumi = 0;
  double alertGoodCloud = 0;
  double alertGoodRain = 0;
  double alertGoodSky = 0;

  @override
  void initState() {
    super.initState();
    _weatherData();
    var androidInitialize = new AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);
    notificationsPlugin = new FlutterLocalNotificationsPlugin();
    notificationsPlugin.initialize(initializationSettings);

    // initializeSetting();
    // tz.initializeTimeZones();
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(
        0, "Ding Dong BEEP BEEP", "TEST", generalNotificationDetails);
  }

  Future _showGoodHumidity() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(0, "Woo wee Good Humidity is BACK ",
        "you can open the dome", generalNotificationDetails);
  }

  Future _showBadHumidity() async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(
        0,
        "\u{26A0} WARNING , We catch high humidity value",
        "please close the dome",
        generalNotificationDetails,
        payload: "xxxx");
  }

  Future _showGoodCloud() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(
        0, "SKY SO CLEARRRRR ", "open the dome", generalNotificationDetails);
  }

  Future _showBadCloud() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(
        0,
        "\u{1F44E} Why so many cloud huh? \u{2601}",
        "Please close the dome",
        generalNotificationDetails);
  }

  Future _showGoodRain() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(0, "NO RAIN ANYMORE",
        "open the dome , Enjoy \u{1F389} ", generalNotificationDetails);
  }

  Future _showBadRain() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(
        0,
        "\u{2614} Rain is Coming RAIN IS COMING ! be careful, Take care",
        "please close the dome",
        generalNotificationDetails);
  }

  Future _showGoodSky() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(0, "We're love Sunny , Right ? \u{2600}",
        "Dome can be use now , Have a nice pic !", generalNotificationDetails);
  }

  Future _showBadSky() async {
    var androidDetails = new AndroidNotificationDetails(
        "", "channelName", "channelDescription",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await notificationsPlugin.show(0, " Why sky look like that :(",
        "please close the dome", generalNotificationDetails);
  }

  Future _weatherData() async {
    final channel = WebSocketChannel.connect(
      Uri.parse('wss://engineer.narit.or.th:8443'),
    );
    channel.sink.add('Authentication&Username=GuestCDK17&Password=GuestCDK17');
    channel.stream.listen((message) {
      //print(message);
      var dataJson = jsonDecode(message);
      WeatherData weatherData = WeatherData.fromJson(dataJson);

      //HUMIDITY//
      if (weatherData.returnMessage == "Login successful.") {
        channel.sink.add(
            'Subscribe&Station=ASTROPARK&DeviceName=ASTROPARK_WEATHER&FieldName=WEATHER_OUTHUM&ReturningState=true');
        print(weatherData.returnMessage);
      } else if (weatherData.fieldName == "WEATHER_OUTHUM") {
        if (weatherData.dataType != "null") {
          currentHumi = double.parse(weatherData.value);

          if (currentHumi >= 85) {
            nowBadHumi = DateTime.now().millisecondsSinceEpoch / 1000;
            alertBadHumi = (nowBadHumi - timestampBadHumi);
            print(alertBadHumi);
            print("bad value");
            if (alertBadHumi >= 300) {
              timestampBadHumi = nowBadHumi;

              if (_notifyHumi == false) {
                if (_hasBeenPressed == true) {
                  _showBadHumidity();
                  _notifyHumi = true;
                  print("Bad");
                }
              }
            }
          }
          if (currentHumi <= 84) {
            nowGoodHumi = DateTime.now().millisecondsSinceEpoch / 1000;
            alertGoodHumi = (nowGoodHumi - timestampGoodHumi);
            print(alertGoodHumi);
            print("good value");

            if (alertGoodHumi >= 300) {
              timestampGoodHumi = nowGoodHumi;

              if (_notifyHumi == true) {
                if (_hasBeenPressed == true) {
                  _showGoodHumidity();
                  _notifyHumi = false;

                  print("Good");
                }
              }
            }
          }
          setState(() {
            lastOutHumi.add(weatherData);
            if (lastOutHumi.length > 5) {
              lastOutHumi.removeAt(0);
            }
          });
        }
      }
      //CLOUD//
      if (weatherData.returnMessage == "Login successful.") {
        channel.sink.add(
            'Subscribe&Station=ASTROPARK&DeviceName=ASTROPARK_CLOUDSENSOR&FieldName=CLOUDSENSOR_CLEARITY&ReturningState=true');
        print(weatherData.returnMessage);
      } else if (weatherData.fieldName == "CLOUDSENSOR_CLEARITY") {
        if (weatherData.dataType != "null") {
          currentCloud = double.parse(weatherData.value);

          if (currentCloud >= 27) {
            nowBadCloud = DateTime.now().millisecondsSinceEpoch / 1000;
            alertBadCloud = (nowBadCloud - timestampBadCloud);

            if (alertBadCloud >= 300) {
              timestampBadCloud = nowBadCloud;
              if (_notifyCloud == false) {
                if (_hasBeenPressed == true) {
                  _showBadCloud();
                  _notifyCloud = true;
                }
              }
            }
          }
          if (currentCloud <= 27) {
            nowGoodCloud = DateTime.now().millisecondsSinceEpoch / 1000;
            alertGoodCloud = (nowGoodCloud - timestampGoodCloud);

            if (alertGoodCloud >= 300) {
              timestampGoodCloud = nowGoodCloud;
              if (_notifyCloud == true) {
                if (_hasBeenPressed == true) {
                  _showGoodCloud();
                  _notifyCloud = false;
                }
              }
            }
          }
          setState(() {
            lastOutCloud.add(weatherData);
            if (lastOutCloud.length > 5) {
              lastOutCloud.removeAt(0);
            }
          });
        }
      }

      //RAIN_RATE
      if (weatherData.returnMessage == "Login successful.") {
        channel.sink.add(
            'Subscribe&Station=ASTROPARK&DeviceName=ASTROPARK_WEATHER&FieldName=WEATHER_RAINRATE&ReturningState=true');
        print(weatherData.returnMessage);
      } else if (weatherData.fieldName == "WEATHER_RAINRATE") {
        if (weatherData.dataType != "null") {
          currentRain = double.parse(weatherData.value);
          if (currentRain >= 10) {
            nowBadRain = DateTime.now().millisecondsSinceEpoch / 1000;
            alertBadRain = (nowBadRain - timestampBadRain);

            if (alertBadRain >= 300) {
              timestampBadRain = nowBadRain;
              if (_notifyRain == false) {
                if (_hasBeenPressed == true) {
                  _showBadRain();
                }
              }
            }
          }
          if (currentRain <= 10) {
            nowGoodRain = DateTime.now().millisecondsSinceEpoch / 1000;
            alertGoodRain = (nowGoodRain - timestampGoodRain);

            if (alertGoodRain >= 300) {
              timestampGoodRain = nowGoodRain;
              if (_notifyRain == true) {
                if (_hasBeenPressed == true) {
                  _showGoodRain();
                  _notifyRain = false;
                }
              }
            }
          }
          setState(() {
            lastOutRain.add(weatherData);
            if (lastOutRain.length > 5) {
              lastOutRain.removeAt(0);
            }
          });
        }
      }
      //SKY_BRIGHTNESS//
      if (weatherData.returnMessage == "Login successful.") {
        channel.sink.add(
            'Subscribe&Station=ASTROPARK&DeviceName=ASTROPARK_SQM&FieldName=SQM_SKYBRIGNESS_DATA&ReturningState=true');
        print(weatherData.returnMessage);
      } else if (weatherData.fieldName == "SQM_SKYBRIGNESS_DATA") {
        if (weatherData.dataType != "null") {
          currentSky = double.parse(weatherData.value);
          if (currentSky >= 10) {
            nowBadSky = DateTime.now().millisecondsSinceEpoch / 1000;
            alertBadSky = (nowBadSky - timestampBadSky);

            if (alertBadSky >= 300) {
              timestampBadSky = nowBadSky;
              if (_notifySky == false) {
                if (_hasBeenPressed == true) {
                  _showBadSky();
                }
              }
            }
          }
          if (currentSky <= 10) {
            nowGoodSky = DateTime.now().millisecondsSinceEpoch / 1000;
            alertGoodSky = (nowGoodSky - timestampGoodSky);

            if (alertGoodSky >= 300) {
              timestampGoodSky = nowGoodSky;
              if (_notifySky == true) {
                if (_hasBeenPressed == true) {
                  _showGoodSky();
                  _notifySky = false;
                }
              }
            }
          }
          setState(() {
            lastOutSky.add(weatherData);
            if (lastOutSky.length > 5) {
              lastOutSky.removeAt(0);
            }
          });
        }
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(children: <Widget>[
          SizedBox(height: 50),
          new Container(
            padding: const EdgeInsets.all(0.0),
            width: 20.0, // you can adjust the width as you need
          ),
          Center(
              child: Container(
                  child: Text(
            'Welcome , Astronomers',
            style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ))),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "Let's see what's the weather today",
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Column(children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _hasBeenPressed = !_hasBeenPressed;
                });
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide()))),
              icon: _hasBeenPressed
                  ? Icon(
                      Icons.done,
                      size: 18,
                      color: Colors.green,
                    )
                  : Icon(Icons.notification_add_outlined,
                      size: 18, color: Colors.black),
              label: _hasBeenPressed
                  ? Text(
                      "SUBSCRIBED",
                      style: GoogleFonts.poppins(color: Colors.green),
                    )
                  : Text(
                      "SUBSCRIBE ",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
            ),
          ]),
          SizedBox(height: 30),
          StreamBuilder(
            builder: (context, snapshot) {
              return Column(children: <Widget>[
                //HUMIDITY//
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: ExpansionTileCard(
                    baseColor: Colors.white,
                    expandedColor: Colors.white,
                    key: cardA,
                    leading: CircleAvatar(
                      child: Lottie.asset("assets/images/mist.json",
                          width: 35, height: 35),
                      backgroundColor: Colors.blue[600],
                    ),
                    title: Text(
                      "Humidity",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Container(
                      child: Row(
                        children: <Widget>[
                          // สีสลับกันแบบงง ๆ
                          Row(children: <Widget>[
                            if (currentHumi >= 85)
                              BlinkText('Unstable',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400),
                                  beginColor: Colors.white,
                                  endColor: Colors.red,
                                  times: 10000000000,
                                  duration: Duration(milliseconds: 500))
                          ]),
                          Row(children: <Widget>[
                            if (currentHumi <= 84)
                              Text(
                                'Stable',
                                style: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                          ]),
                        ],
                      ),
                    ),
                    children: <Widget>[
                      // Divider(
                      //   thickness: 1.0,
                      //   height: 1.0,
                      // ),
                      SizedBox(height: 10),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 0,
                              intervalType: DateTimeIntervalType.seconds,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            numberFormat: NumberFormat("##.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            minimum: 0,
                            maximum: 200,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: false),
                          series: <CartesianSeries<WeatherData, DateTime>>[
                            SplineAreaSeries<WeatherData, DateTime>(
                              splineType: SplineType.cardinal,
                              dataSource: lastOutHumi,
                              gradient: LinearGradient(colors: [
                                HexColor("#1A2980"),
                                HexColor("#26D0CE"),
                              ]),
                              opacity: 0.7,
                              xValueMapper: (WeatherData weather, _) =>
                                  weather.dataTimeStamp,
                              yValueMapper: (WeatherData weather, _) =>
                                  double.parse(weather.value),
                              name: 'Humidity',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                useSeriesColor: true,
                              ),
                            ),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //CLOUD//
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: ExpansionTileCard(
                    baseColor: Colors.white,
                    expandedColor: Colors.white,
                    key: cardB,
                    leading: CircleAvatar(
                      child: Lottie.asset("assets/images/partly-cloudy.json",
                          width: 35, height: 35),
                      backgroundColor: Colors.blue[400],
                    ),
                    title: Text(
                      "Cloud",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Container(
                      child: Row(
                        children: <Widget>[
                          // สีสลับกันแบบงง ๆ
                          Row(children: <Widget>[
                            if (currentCloud <= 27)
                              BlinkText('Unstable',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400),
                                  beginColor: Colors.white,
                                  endColor: Colors.red,
                                  times: 10000000000,
                                  duration: Duration(milliseconds: 500))
                          ]),
                          Row(children: <Widget>[
                            if (currentCloud >= 27)
                              Text(
                                'Stable',
                                style: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                          ]),
                        ],
                      ),
                    ),
                    children: <Widget>[
                      // Divider(
                      //   thickness: 1.0,
                      //   height: 1.0,
                      // ),
                      SizedBox(height: 10),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            numberFormat: NumberFormat("##.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            // minimum: -100,
                            // maximum: 100,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: false),
                          series: <CartesianSeries<WeatherData, DateTime>>[
                            SplineAreaSeries<WeatherData, DateTime>(
                              splineType: SplineType.cardinal,
                              dataSource: lastOutCloud,
                              gradient: LinearGradient(colors: [
                                HexColor("#3a7bd5"),
                                HexColor("#3a6073"),
                              ]),
                              opacity: 0.7,
                              xValueMapper: (WeatherData weather, _) =>
                                  weather.dataTimeStamp,
                              yValueMapper: (WeatherData weather, _) =>
                                  double.parse(weather.value),
                              name: 'Cloud',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                useSeriesColor: true,
                              ),
                            ),
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
                              cardB.currentState?.collapse();
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: ExpansionTileCard(
                    baseColor: Colors.white,
                    expandedColor: Colors.white,
                    key: cardC,
                    leading: CircleAvatar(
                      child: Lottie.asset("assets/images/thunderstorm.json",
                          width: 35, height: 35),
                      backgroundColor: Colors.blue[300],
                    ),
                    title: Text(
                      "Rain",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Container(
                      child: Row(
                        children: <Widget>[
                          Row(children: <Widget>[
                            if (currentRain >= 10)
                              BlinkText('Unstable',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400),
                                  beginColor: Colors.white,
                                  endColor: Colors.red,
                                  times: 10000000000,
                                  duration: Duration(milliseconds: 500))
                          ]),
                          Row(children: <Widget>[
                            if (currentRain <= 10)
                              Text(
                                'Stable',
                                style: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                          ]),
                        ],
                      ),
                    ),
                    children: <Widget>[
                      // Divider(
                      //   thickness: 1.0,
                      //   height: 1.0,
                      // ),
                      SizedBox(height: 10),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            numberFormat: NumberFormat("##.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            // minimum: 0,
                            // maximum: 200,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: false),
                          series: <CartesianSeries<WeatherData, DateTime>>[
                            SplineAreaSeries<WeatherData, DateTime>(
                              splineType: SplineType.cardinal,
                              dataSource: lastOutRain,
                              gradient: LinearGradient(colors: [
                                HexColor("#283048"),
                                HexColor("#859398"),
                              ]),
                              opacity: 0.7,
                              xValueMapper: (WeatherData weather, _) =>
                                  weather.dataTimeStamp,
                              yValueMapper: (WeatherData weather, _) =>
                                  double.parse(weather.value),
                              name: 'Rain',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                useSeriesColor: true,
                              ),
                            ),
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
                              cardC.currentState?.collapse();
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: ExpansionTileCard(
                    baseColor: Colors.white,
                    expandedColor: Colors.white,
                    key: cardD,
                    leading: CircleAvatar(
                      child: Lottie.asset("assets/images/cloundsinthesky.json",
                          width: 100, height: 100),
                      backgroundColor: Colors.blue[200],
                    ),
                    title: Text(
                      "Sky",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Container(
                      child: Row(
                        children: <Widget>[
                          // สีสลับกันแบบงง ๆ
                          Row(children: <Widget>[
                            if (currentSky >= 10)
                              BlinkText('Unstable',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400),
                                  beginColor: Colors.white,
                                  endColor: Colors.red,
                                  times: 10000000000,
                                  duration: Duration(milliseconds: 500))
                          ]),
                          Row(children: <Widget>[
                            if (currentSky <= 10)
                              Text(
                                'Stable',
                                style: GoogleFonts.poppins(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                          ]),
                        ],
                      ),
                    ),
                    children: <Widget>[
                      // Divider(
                      //   thickness: 1.0,
                      //   height: 1.0,
                      // ),
                      SizedBox(height: 10),
                      SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                              labelRotation: 90,
                              intervalType: DateTimeIntervalType.seconds,
                              edgeLabelPlacement: EdgeLabelPlacement.shift,
                              dateFormat: DateFormat.Hms()),
                          // Chart title
                          // Enable legend
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            numberFormat: NumberFormat("##.##", "en_US"),
                            maximumLabelWidth: 25,
                            decimalPlaces: 0,
                            // minimum: 0,
                            // maximum: 200,
                            interval: 10,
                          ),
                          legend: Legend(isVisible: false),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: false),
                          series: <CartesianSeries<WeatherData, DateTime>>[
                            SplineAreaSeries<WeatherData, DateTime>(
                              splineType: SplineType.cardinal,
                              dataSource: lastOutSky,
                              gradient: LinearGradient(colors: [
                                HexColor("#E0EAFC"),
                                HexColor("#CFDEF3"),
                              ]),
                              opacity: 0.7,
                              xValueMapper: (WeatherData weather, _) =>
                                  weather.dataTimeStamp,
                              yValueMapper: (WeatherData weather, _) =>
                                  double.parse(weather.value),
                              name: 'Sky',
                              markerSettings: MarkerSettings(isVisible: true),
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                useSeriesColor: true,
                              ),
                            ),
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
                              cardD.currentState?.collapse();
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.arrow_upward),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text('Close'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]);
            },
          ),
        ]));
  }
}
