import 'package:accura_kyc_flutter_example/colors.dart';
import 'package:accura_kyc_flutter_example/push_to_camera_screen.dart';
import 'package:accura_kyc_flutter_example/static_data.dart';
import 'package:flutter/material.dart';
import 'model/mrzandcountrylistmodel.dart';

class ocr_detail_screen extends StatefulWidget {
  List<Cards> oCRALlData;
  String contryId;
  ocr_detail_screen(this.oCRALlData, this.contryId);

  @override
  _ocr_detail_screenState createState() => _ocr_detail_screenState();
}

class _ocr_detail_screenState extends State<ocr_detail_screen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(milliseconds: 0), () {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        storeOrientation("1");
      } else {
        storeOrientation("0");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ACCURA OCR"),
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) => Container(
            padding: EdgeInsets.only(bottom: 10, top: 10, right: 10, left: 10),
            child: GestureDetector(
              onTap: () {
                push_to_camera_screen(
                    context,
                    widget.oCRALlData[index].cardType.toString(),
                    widget.oCRALlData[index].cardId.toString(),
                    widget.oCRALlData[index].cardName,
                    widget.contryId,
                    "0");
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: colors.theme_color,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: EdgeInsets.only(top: 12, bottom: 12, left: 12),
                child: Text(
                  widget.oCRALlData[index].cardName,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          shrinkWrap: true,
          itemCount: widget.oCRALlData.length,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

  storeOrientation(String ori) {
    colors.orientation = ori;
  }
}
