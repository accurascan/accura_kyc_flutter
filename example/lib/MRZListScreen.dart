import 'dart:convert';

import 'package:accura_kyc_flutter/accura_kyc_flutter.dart';
import 'package:accura_kyc_flutter_example/colors.dart';
import 'package:accura_kyc_flutter_example/push_to_camera_screen.dart';
import 'package:accura_kyc_flutter_example/static_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/mrzandcountrylistmodel.dart';
import 'ocr_detail_screen.dart';

class MRZListScreen extends StatefulWidget {
  const MRZListScreen({Key key}) : super(key: key);

  @override
  _MRZListScreenState createState() => _MRZListScreenState();
}

class _MRZListScreenState extends State<MRZListScreen>
    with WidgetsBindingObserver {
  List<mrzandcountrylistmodel> dataList = [];
  List<AllData> countryList = [];
  bool isShowErrorDialog = false;
  String errorMessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 0), () {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        storeOrientation("1");
      } else {
        storeOrientation("1");
      }
    });
    getAll_MRZ_And_Country_List();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCURA OCR'),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     if (colors.orientation == "1") {
          // static_data.changeOrientationLandscap();
          //       storeOrientation("0");
          //     } else {
          //       static_data.changeOrientationPotrait();
          //       storeOrientation("1");
          //     }
          //   },
          //   child: Container(
          //     child: Center(
          //         child: Container(
          //       padding: EdgeInsets.only(
          //         top: 10,
          //         bottom: 10,
          //         left: 15,
          //         right: 15,
          //       ),
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(20)),
          //       child: Text(
          //         colors.orientation == "1" ? "Landscape" : "Portrait",
          //         style: TextStyle(fontSize: 12, color: colors.theme_color),
          //       ),
          //       margin: EdgeInsets.only(right: 10),
          //     )),
          //   ),
          // )
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              dataList.length > 0 && dataList[0].allData.length > 0
                  ? Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Visibility(
                                visible: dataList[0].allData[0].mrz != null &&
                                        dataList[0].allData[0].mrz == 1
                                    ? true
                                    : false,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        push_to_camera_screen(context, "MRZ",
                                            "0", "Passport MRZ", "0", "1");
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "Passport MRZ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        push_to_camera_screen(context, "MRZ",
                                            "0", "ID card MRZ", "0", "2");
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "ID card MRZ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        push_to_camera_screen(context, "MRZ",
                                            "0", "VISA MRZ", "0", "3");
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "VISA MRZ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        push_to_camera_screen(context, "MRZ",
                                            "0", "All MRZ", "0", "0");
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "All MRZ",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            dataList[0].allData[1].bankCard != null &&
                                    dataList[0].allData[1].bankCard == 1
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            push_to_camera_screen(
                                                context,
                                                "BANKCARD",
                                                "0",
                                                "Bank Card",
                                                "0",
                                                "0");
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            padding: EdgeInsets.only(
                                                top: 12, bottom: 12, left: 12),
                                            child: Text(
                                              "Bank Card",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            dataList[0].allData[2].barcode != null &&
                                    dataList[0].allData[2].barcode == 1
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            push_to_camera_screen(
                                                context,
                                                "BARCODE",
                                                "0",
                                                "Barcode",
                                                "0",
                                                "0");
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            padding: EdgeInsets.only(
                                                top: 12, bottom: 12, left: 12),
                                            child: Text(
                                              "BarCode",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            ListView.builder(
                              itemBuilder: (context, index) => Container(
                                padding: EdgeInsets.only(top: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ocr_detail_screen(
                                                  countryList[index].cards,
                                                  countryList[index]
                                                      .countryId
                                                      .toString()),
                                        )).then((value) {
                                      print("backSCreen");
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: colors.theme_color,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      countryList[index].countryName,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              shrinkWrap: true,
                              itemCount: countryList.length,
                              physics: const NeverScrollableScrollPhysics(),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Color(0xffffff),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xfffd1313))),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getAll_MRZ_And_Country_List() async {
    try {
      var data = await AccuraKycFlutter.getOcrList();

      print("dataListdataList${data}");
      mrzandcountrylistmodel model =
          mrzandcountrylistmodel.fromJson(jsonDecode(data));
      if (model.sdkRate > 0) {
        dataList.add(model);
        if (dataList.length > 0) {
          if (dataList[0].allData.length > 3) {
            for (int i = 0; i < dataList[0].allData.length; i++) {
              if (i > 2) {
                if (mounted) {
                  setState(() {
                    countryList.add(dataList[0].allData[i]);
                  });
                }
              }
            }
          }
          if (dataList[0].allData.length > 0) {
            //Update Filters If License is Valid
            var data = await AccuraKycFlutter.updateFilters(
                minGlarePercentage: 6,
                maxGlarePercentage: 98,
                isCheckPhotoCopy: false,
                isDetectHologram: true,
                motionThreshold: 18,
                lightTolerance: 39,
                faceBlurPercentage: 70,
                blurPercentage: 80);
          }
        }
      } else {
        if (mounted)
          setState(() {
            isShowErrorDialog = true;
          });
        switch (model.sdkRate) {
          case -1:
            errorMessage = "Invalid license";
            break;
          case -2:
            errorMessage = "Invalid Bundle ID";
            break;
          case -3:
            errorMessage = "Invalid Platform";
            break;
          default:
            errorMessage = "License is Expired";
            break;
        }
        if (mounted) {
          setState(() {
            errorMessage;
          });
        }
      }
    } on PlatformException catch (e) {}
  }

  storeOrientation(String ori) {
    if (mounted)
      setState(() {
        colors.orientation = ori;
      });
  }
}
