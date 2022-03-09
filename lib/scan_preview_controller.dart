import 'package:flutter/services.dart';

import 'scan_preview_widget.dart';

class ScanPreviewController {
  ScanPreviewWidgetState scanState;
  MethodChannel channel;

  ScanPreviewController._(this.channel, this.scanState);

  static init(int id, ScanPreviewWidgetState state) {
    assert(id != null);
    final MethodChannel channel = MethodChannel('scan_preview');
    return ScanPreviewController._(channel, state);
  }

  startCamera(String card_type, String card_id,
      String country_id, String mrzDocumentType) async {
    String result = await channel.invokeMethod('scan#startCamera', {
      "recogType": card_type,
      "card_id": card_id,
      "country_id": country_id,
      "mrzDocumentType": mrzDocumentType,
    });
    print('start camera: $result');
  }

  restartCamera(String card_type, String card_id,
      String country_id, String mrzDocumentType) async {
    String result = await channel.invokeMethod('scan#restartCamera', {
      "recogType": card_type,
      "card_id": card_id,
      "country_id": country_id,
      "mrzDocumentType": mrzDocumentType,

    });
  }

  stopCamera() async {
   await channel.invokeMethod('scan#stopCamera');

  }



  flipCamera() async {
    await channel.invokeMethod('FlipCamera');
  }
  restartCameraPreview() async {
    await channel.invokeMethod('scan#restartCameraPreview');
  }
  stopCamerPreview() async {
    await channel.invokeMethod('scan#stopCameraPreview');
  }
}
