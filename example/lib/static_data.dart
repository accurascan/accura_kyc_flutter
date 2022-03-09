import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class static_data{
  static int slectedBarcode = 0;

  static changeOrientationPotrait(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  static changeOrientationLandscap(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

}