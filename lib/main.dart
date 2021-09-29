import 'package:google_fonts/google_fonts.dart';

import 'package:isp_ui/HomeScreen.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays(
  //     [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (10)),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          alignment: Alignment.center,
          child: new Column(
            children: [
              SizedBox(height: 150),
              Lottie.asset(
                'assets/images/logo_1.json',
                controller: _controller,
                height: 400,
                animate: true,
                alignment: Alignment.center,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward().whenComplete(() => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExpansionTileCardDemo()),
                        ));
                },
              ),
              Container(
                child: Text(
                  'i S p h e r e  +',
                  // textAlign: TextAlign.center,
                  style: GoogleFonts.spartan(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                      color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ));
  }
}
