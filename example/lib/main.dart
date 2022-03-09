import 'package:accura_kyc_flutter_example/colors.dart';
import 'package:accura_kyc_flutter_example/static_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:accura_kyc_flutter/accura_kyc_flutter.dart';

import 'package:permission_handler/permission_handler.dart';

import 'CameraScreen.dart';
import 'MRZListScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  double myheight_camera_Live = 80;
  double mywidth_camera_Live = 300;
  String _projectVersion = '';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String projectVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    /* getRecogEngineData(context);*/
    static_data.changeOrientationPotrait();
    return MaterialApp(debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColor: colors.theme_color,appBarTheme: AppBarTheme(color:colors.theme_color ),
          primaryColor: colors.theme_color,
        ),title: "ACCURA OCR",
        home: Scaffold(body: MRZListScreen()));
  }

/*  Future<void> getRecogEngineData(BuildContext context) async {
     const MethodChannel _channel =
    const MethodChannel('accura_kyc_flutter');
    final String version = await _channel.invokeMethod('getRecogEngineData');
    print("Statuscc===>$version");
  }*/
}
