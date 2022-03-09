import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scan_preview_controller.dart';

class ScanPreviewWidget extends StatefulWidget {
  ScanPreviewWidget(
      {this.laserColor,
      this.borderColor,
      this.onScannerCreated,
      @required this.onScanResult,
      this.cardType,
      this.CardID,
      this.CardName,
      this.country_id,
      this.mrzDocumentType});

  final Function(ScanPreviewController) onScannerCreated;
  final ValueChanged<Object> onScanResult;
  final int laserColor;
  final int borderColor;
  final String cardType;
  final String CardID;
  final String CardName;
  final String country_id;
  final String mrzDocumentType;

  @override
  ScanPreviewWidgetState createState() => ScanPreviewWidgetState();
}

class ScanPreviewWidgetState extends State<ScanPreviewWidget> {
  ScanPreviewController controller;

  final BasicMessageChannel _messageChannel =
      BasicMessageChannel("scan_preview_message", StandardMessageCodec());

  @override
  void initState() {
    super.initState();
    _messageChannel.setMessageHandler(_messageHandler);
  }

  Future<dynamic> _messageHandler(Object message) async {
    widget.onScanResult(message);
  }

  @override
  void dispose() {
/*    controller.stopCamera();
    WidgetsBinding.instance.removeObserver(this);*/
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("startCamerasstartCameratrecogTypeartCamera");
      controller.startCamera(widget.cardType, widget.CardID,
          widget.country_id, widget.mrzDocumentType);
    } else if (state == AppLifecycleState.paused) {
      //controller.stopCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _init();
  }

  Widget _init() {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      // 其他参数
      'laserColor': widget.laserColor != null ? widget.laserColor : 0xFF00FF00,
      'borderColor':
          widget.borderColor != null ? widget.borderColor : 0xFFFFFFFF
    };
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'scan_preview',
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'scan_preview',
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }
  }

  void onPlatformViewCreated(int id) {
    final ScanPreviewController controller =
        ScanPreviewController.init(id, this);
    widget.onScannerCreated(controller);
  }
}
