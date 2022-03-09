import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main_Camera.dart';

Future<void> push_to_camera_screen(
    BuildContext context,
    String card_type,
    String card_id,
    String card_name,
    String contry_id,
    String mrzDocumentType) async {
  if (await Permission.camera.status.isGranted) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => main_camera(
                card_type, card_id, card_name, contry_id, mrzDocumentType)));
  } else {
    if (await Permission.camera.request().isGranted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => main_camera(
                  card_type, card_id, card_name, contry_id, mrzDocumentType)));
    } else {

    }
  }
}
