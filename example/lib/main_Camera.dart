import 'package:accura_kyc_flutter_example/CameraScreen.dart';
import 'package:flutter/material.dart';

class main_camera extends StatefulWidget {
  String cardType;
  String card_id;
  String card_name;
  String country_id;
  String mrzDocumentType;



  main_camera(this.cardType, this.card_id, this.card_name,this.country_id,this.mrzDocumentType);

  @override
  _main_cameraState createState() => _main_cameraState();
}

class _main_cameraState extends State<main_camera> {
  @override
  Widget build(BuildContext context) {
    print("startCamerastartCamera${widget.cardType}");

    return Scaffold(body: CameraScreen(widget.cardType, widget.card_id, widget.card_name,widget.country_id,widget.mrzDocumentType));
  }
}
