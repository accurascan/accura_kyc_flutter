import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:accura_kyc_flutter/accura_kyc_flutter.dart';
import 'package:accura_kyc_flutter/scan_preview_controller.dart';
import 'package:accura_kyc_flutter_example/MRZListScreen.dart';
import 'package:accura_kyc_flutter_example/colors.dart';
import 'package:accura_kyc_flutter_example/static_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'CameraScreen.dart';
import 'model/OCR_Data_model.dart';
import 'model/liveness_model.dart';

class result_activity extends StatefulWidget {
  const result_activity({Key key, this.data}) : super(key: key);

  final List<OCR_Data_model> data;

  @override
  _result_activityState createState() => _result_activityState();
}

class _result_activityState extends State<result_activity> {
  String image = "";
  ValueChanged<Object> onScanResult;

  var scroll_controller = new ScrollController();
  double fontsize = 16;

  File frontImageFile;
  File backImageFile;
  File faceImageFile;
  String liveliveness_img_file;

  String faceMatch_Score;

  String liveness_Score;
  bool liveness_status = false;

  List<OcrData> ocrDataList = [];
  String mrzdata = "";
  var _byteImage;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.data.length > 0) {
      ocrDataList = widget.data[0].ocrData;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ACCURA OCR"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: SingleChildScrollView(
                controller: scroll_controller,
                scrollDirection: Axis.vertical,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        child: Column(children: [
                          ocrDataList[0].faceImage != null
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.memory(
                                          base64.decode(widget
                                              .data[0].ocrData[0].faceImage),
                                          height: 100,
                                          width: 100,
                                        ),
                                        liveliveness_img_file != null
                                            ? Visibility(
                                                visible: liveness_status,
                                                child: Image.memory(
                                                  base64.decode(
                                                      liveliveness_img_file),
                                                  height: 100,
                                                  width: 100,
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                )
                              : Container(),
                          ocrDataList[0].frontData != null &&
                                  widget.data[0].ocrData[0].frontData.length > 0
                              ? Container(
                                  child: Column(children: [
                                  Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Text(
                                      "Front Data",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        top: 15, bottom: 15, left: 10),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Table(
                                      border: TableBorder.all(
                                          color: Color(0xFFD32D39)),
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    ocrDataList[0]
                                                        .frontData[index]
                                                        .frontKey,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: fontsize)),
                                              ),
                                            ),
                                          ),
                                          ocrDataList[0]
                                                      .frontData[index]
                                                      .scannedType ==
                                                  1
                                              ? TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                          ocrDataList[0]
                                                              .frontData[index]
                                                              .frontKeydata,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  fontsize)),
                                                    ),
                                                  ),
                                                )
                                              : ocrDataList[0]
                                                          .frontData[index]
                                                          .scannedType ==
                                                      2
                                                  ? Image.memory(base64.decode(
                                                      ocrDataList[0]
                                                          .frontData[index]
                                                          .frontKeydata))
                                                  : Container(),
                                        ]),
                                      ],
                                    ),
                                    itemCount: ocrDataList[0].frontData.length,
                                  )
                                ]))
                              : Container(),
                          ocrDataList[0].bankData != null &&
                                  ocrDataList[0].bankData.length > 0
                              ? Container(
                                  child: Column(children: [
                                  Column(
                                    children: [
                                      Container(
                                        color: Colors.grey.withOpacity(0.5),
                                        child: Text(
                                          "Bank Data",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.only(
                                            top: 15, bottom: 15, left: 10),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) => Table(
                                          border: TableBorder.all(
                                              color: Color(0xFFD32D39)),
                                          children: [
                                            TableRow(children: [
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                        ocrDataList[0]
                                                            .bankData[index]
                                                            .Bank_key,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                fontsize)),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                        ocrDataList[0]
                                                            .bankData[index]
                                                            .Bank_data,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                fontsize)),
                                                  ),
                                                ),
                                              )
                                            ]),
                                          ],
                                        ),
                                        itemCount:
                                            ocrDataList[0].bankData.length,
                                      )
                                    ],
                                  ),
                                ]))
                              : Container(),
                          ocrDataList[0].backData != null &&
                                  ocrDataList[0].backData.length > 0
                              ? Container(
                                  child: Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Text(
                                      "Back Data",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        top: 15, bottom: 15, left: 10),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Table(
                                      border: TableBorder.all(
                                          color: Color(0xFFD32D39)),
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    ocrDataList[0]
                                                        .backData[index]
                                                        .backKey,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: fontsize)),
                                              ),
                                            ),
                                          ),
                                          ocrDataList[0]
                                                      .backData[index]
                                                      .scannedType ==
                                                  1
                                              ? TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Text(
                                                          ocrDataList[0]
                                                              .backData[index]
                                                              .backKeydata,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  fontsize)),
                                                    ),
                                                  ),
                                                )
                                              : ocrDataList[0]
                                                          .backData[index]
                                                          .scannedType ==
                                                      2
                                                  ? Image.memory(base64.decode(
                                                      ocrDataList[0]
                                                          .backData[index]
                                                          .backKeydata))
                                                  : Container(),
                                        ]),
                                      ],
                                    ),
                                    itemCount: ocrDataList[0].backData.length,
                                  )
                                ]))
                              : Container(),
                          ocrDataList[0].mRZData != null &&
                                  ocrDataList[0].mRZData.length > 0
                              ? Container(
                                  child: Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Text(
                                      "MRZ",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        top: 15, bottom: 15, left: 10),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) =>
                                        ocrDataList[0]
                                                    .mRZData[index]
                                                    .MRZ_data !=
                                                null
                                            ? Table(
                                                border: TableBorder.all(
                                                    color: Color(0xFFD32D39)),
                                                children: [
                                                  TableRow(children: [
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              ocrDataList[0]
                                                                  .mRZData[
                                                                      index]
                                                                  .MRZ_key,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      fontsize)),
                                                        ),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              ocrDataList[0]
                                                                  .mRZData[
                                                                      index]
                                                                  .MRZ_data,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      fontsize)),
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                                ],
                                              )
                                            : Container(),
                                    itemCount: ocrDataList[0].mRZData.length,
                                  )
                                ]))
                              : Container(),
                          ocrDataList[0].pdf417Data != null &&
                                  ocrDataList[0].pdf417Data.length > 0
                              ? Container(
                                  child: Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Text(
                                      "Pdf417",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                        top: 15, bottom: 15, left: 10),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) =>
                                        ocrDataList[0]
                                                    .pdf417Data[index]
                                                    .pDF417Keydata !=
                                                null
                                            ? Table(
                                                border: TableBorder.all(
                                                    color: Color(0xFFD32D39)),
                                                children: [
                                                  TableRow(children: [
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              ocrDataList[0]
                                                                  .pdf417Data[
                                                                      index]
                                                                  .pDF417Key,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      fontsize)),
                                                        ),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      verticalAlignment:
                                                          TableCellVerticalAlignment
                                                              .middle,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              ocrDataList[0]
                                                                  .pdf417Data[
                                                                      index]
                                                                  .pDF417Keydata,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      fontsize)),
                                                        ),
                                                      ),
                                                    )
                                                  ]),
                                                ],
                                              )
                                            : Container(),
                                    itemCount: ocrDataList[0].pdf417Data.length,
                                  )
                                ]))
                              : Container(),
                          ocrDataList[0].frontImage != null
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      color: Colors.grey.withOpacity(0.5),
                                      child: Text(
                                        "Front Image",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          top: 15, bottom: 15, left: 10),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Image.memory(base64.decode(
                                        widget.data[0].ocrData[0].frontImage)),
                                  ],
                                )
                              : Container(),
                          ocrDataList[0].backImage != null
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      color: Colors.grey.withOpacity(0.5),
                                      child: Text(
                                        "Back Image",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          top: 15, bottom: 15, left: 10),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Image.memory(base64.decode(
                                        widget.data[0].ocrData[0].backImage)),
                                  ],
                                )
                              : Container()
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),

//      Image.memory(base64Decode(image)),
    );
  }

  storeOrientation(String ori) {
    colors.orientation = ori;
  }
}
