import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui';
import 'package:accura_kyc_flutter/accura_kyc_flutter.dart';
import 'package:accura_kyc_flutter/scan_preview_controller.dart';
import 'package:accura_kyc_flutter/scan_preview_widget.dart';
import 'package:accura_kyc_flutter_example/colors.dart';
import 'package:accura_kyc_flutter_example/model/OCR_Data_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'result_activity.dart';

class CameraScreen extends StatefulWidget {
  String recogType;
  String card_id;
  String card_name;
  String country_id;
  String mrzDocumentType;

  CameraScreen(this.recogType, this.card_id, this.card_name, this.country_id,
      this.mrzDocumentType);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List cameras;
  List cameras1;
  String imagePath;
  bool is_capture = true;
  ScanPreviewController controller;
  var count = 0;
  List<dynamic> Frontdata;
  var Backdata;
  int back = 1;
  bool done = false;
  AnimationController controller_anim;
  bool isFrontVisible = true;
  Animation<double> _frontRotation;
  bool animimage_visible = false;
  int License_state = -1;
  String message_toast = " ";
  String message_card_side = " ";
  var overlay_size;
  var toast = "";
  var side_message = "";
  double heightOfOverlayBox;
  double widthOfOverlayBox;
  final player = AudioCache();

  int slectedBarcode = 0;

  // List<dynamic> result_data;
  List<String> barcodeFormatList = [
    "ALL FORMATS",
    "AZTEC",
    "CODABAR",
    "CODE 39",
    "CODE 93",
    "CODE 128",
    "DATA MATRIX",
    "EAN 8",
    "EAN 13",
    "ITF",
    "PDF417",
    "OR CODE",
    "UPC A",
    "UPC E"
  ];
  AppBar appBar;

  @override
  Future<void> initState() {
    super.initState();
    AccuraKycFlutter.getSizeOfBox(_messageHandler);
    AccuraKycFlutter.playScanSound(_soundHandler);
    controller_anim = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    _updateRotations(true);

    WidgetsBinding.instance.addObserver(this);
  }

  Future<dynamic> _messageHandler(Object message) async {
//    final height = MediaQuery.of(context).size.height;

    List<dynamic> result_data;
    result_data = message as List<dynamic>;

    result_data.forEach((element) {
      element.forEach((key, value) {
        if (key == "Height") {
          setState(() {
            heightOfOverlayBox = double.parse(value);
            //    print("heightOfOverlayBoxheight$heightOfOverlayBox");
          });
        } else if (key == "Width") {
          setState(() {
            widthOfOverlayBox = double.parse(value);
            print(
                "heightOfOverlayBoxheight${MediaQuery.of(context).size.height}");
            print(
                "heightOfOverlayBoxwidth${MediaQuery.of(context).size.width}");
          });
        }
      });
    });
  }

  Future<dynamic> _soundHandler(Object message) async {
    player.play('sound/beep.mp3');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.stopCamera();
    super.dispose();
    controller = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AccuraKycFlutter.activitypause();
    }
    if (state == AppLifecycleState.resumed) {
      AccuraKycFlutter.activitydoOnResume();
    }
  }

  Widget message(int ret) {
    if (ret == -1) {
      return new Text("No Key Found");
    } else if (ret == -2) {
      return new Text("Invalid Key");
    } else if (ret == -3) {
      return new Text("Invalid Platform");
    } else if (ret == -4) {
      return new Text("Invalid License");
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      message_toast = toast;
      message_card_side = side_message;
    });
    appBar = AppBar(
      actions: [
        GestureDetector(
            onTap: () {
              controller.flipCamera();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Image.asset(
                "assets/images/ic_camera.png",
                height: 40,
                width: 40,
              ),
            )),
      ],
    );

    return _cameraPreviewWidget();
  }

  Widget _cameraPreviewWidget() {
    final width = MediaQuery.of(context).size.width;

    controller_anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animimage_visible = false;
      }
    });

    return Scaffold(
      appBar: colors.orientation == "1" ? appBar : null,
      body: SafeArea(
        child: Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Container(
                        width: width,
                        height: MediaQuery.of(context).size.height,
                        child: ScanPreviewWidget(
                          cardType: widget.recogType,
                          CardID: widget.card_id,
                          CardName: widget.card_name,
                          country_id: widget.country_id,
                          mrzDocumentType: widget.mrzDocumentType,
                          onScannerCreated: (ScanPreviewController controller) {
                            this.controller = controller;
                            /*    AccuraKycFlutter.setCameraFacing(
                                cameraFacing.CAMERA_FACING_FRONT);*/
                            AccuraKycFlutter.setCardSideScan(
                                cardSide.FIRST_FRONT_AFTER_BACK);
                            startCamera(controller);
                          },
                          onScanResult: (result) {
                            List<dynamic> result_data;
                            result_data = result as List<dynamic>;
                            print(
                                "result_dataresult_dataresult_data${result_data.length}");
                            result_data.forEach((element) {
                              element.forEach((key, value) {
                                if (key == 'errorMessage') {
                                  print("resultcccccccccis$key");
                                  if (mounted) {
                                    Future.delayed(
                                        const Duration(milliseconds: 0), () {
                                      setState(() {
                                        switch (value) {
                                          case "0":
                                            toast = "Keep Document Steady";
                                            break; // if device in motion
                                          case "1":
                                            toast = "Keep document in frame";
                                            break;
                                          case "2":
                                            toast = "Bring card near to frame.";
                                            break;
                                          case "3":
                                            toast = "Processing...";
                                            break;
                                          case "4":
                                            toast = "Blur detect in document";
                                            break;
                                          case "5":
                                            toast = "Blur detected over face";
                                            break;
                                          case "6":
                                            toast = "Glare detect in document";
                                            break;
                                          case "7":
                                            toast = "Hologram Detected";
                                            break;
                                          case "8":
                                            toast = "Low lighting detected";
                                            break;
                                          case "9":
                                            toast =
                                                "Can not accept Photo Copy Document";
                                            break;
                                          case "10":
                                            toast = "Face not detected";
                                            break;
                                          case "11":
                                            toast = "MRZ not detected";
                                            break;
                                          case "12":
                                            toast = "Passport MRZ not detected";
                                            break;
                                          case "13":
                                            toast = "ID card MRZ not detected";
                                            break;
                                          case "14":
                                            toast = "Visa MRZ not detected";
                                            break;
                                          case "15":
                                            toast =
                                                "Document is upside down. Place it properly";
                                            break;
                                          case "16":
                                            toast =
                                                "Scanning wrong side of document";

                                            break;
                                          default:
                                            toast = value;
                                            break; // some filter message
                                        }
                                      });
                                    });
                                  }
                                  /* setState(() {
                                      toast=value;
                                    });*/
                                } else if (key == "titleMessage") {
                                  if (mounted) {
                                    setState(() {
                                      switch (value) {
                                        case "1":
                                          //SCAN_TITLE_OCR_FRONT
                                          side_message =
                                              "Scan Front Side of ${widget.card_name}";
                                          break;
                                        case "2":
                                          //SCAN_TITLE_OCR_BACK
                                          side_message =
                                              "Scan Back Side of ${widget.card_name}";
                                          break;
                                        case "3":
                                          //SCAN_TITLE_OCR
                                          side_message =
                                              "Scan ${widget.card_name}";
                                          break;
                                        case "4":
                                          //SCAN_TITLE_MRZ_PDF417_FRONT
                                          if (widget.recogType == "BANKCARD") {
                                            side_message = "Scan Bank Card";
                                          } else if (widget.recogType ==
                                              "BARCODE") {
                                            side_message = "Scan Barcode";
                                          } else
                                            side_message =
                                                "Scan Front Side of Document";
                                          break;
                                        case "5":
                                          //SCAN_TITLE_MRZ_PDF417_BACK
                                          side_message =
                                              "Now Scan Back Side of Document";
                                          break;
                                        case "6":
                                          //SCAN_TITLE_DLPLATE
                                          side_message = "Scan Number Plate";
                                          break;
                                        default:
                                          side_message = "";
                                          break; // some filter message
                                      }
                                      print("TitleValue$value");

                                      /*if (value.toString().contains("Back")) {
                                          animimage_visible = true;
                                        }*/
                                    });
                                  }
                                } else {
                                  OCR_Data_model model =
                                      OCR_Data_model.fromJson(
                                          jsonDecode(value));
                                  List<OCR_Data_model> datalist = [];
                                  datalist.add(model);
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            result_activity(data: datalist)),
                                  ).then((value) => {
                                        WidgetsBinding.instance
                                            .addObserver(this),
                                        Navigator.pop(context),
                                      });
                                }
                              });
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              widthOfOverlayBox != null && heightOfOverlayBox != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              message_card_side.isEmpty
                                  ? ""
                                  : message_card_side,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: heightOfOverlayBox,
                            width: widthOfOverlayBox,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(bottom: 5, right: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Powered By",
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 7),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Image.asset(
                                          "assets/images/accuralogo.png",
                                          height: 12,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: widthOfOverlayBox,
                                  height: heightOfOverlayBox,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                        color: colors.theme_color, width: 3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(
                              message_toast.isEmpty ? "" : message_toast,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              widget.recogType == "BARCODE"
                  ? colors.orientation == "1"
                      ? Container(
                          margin: EdgeInsets.only(bottom: 30),
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.only(
                                    top: 15, bottom: 15, right: 30, left: 30),
                                primary: colors.theme_color),
                            child: Text(
                              "SELECT BARCODE FORMAT",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              controller.stopCamerPreview();
                              showBarcodeFormateDialog();
                            },
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(bottom: 20, right: 20),
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              controller.stopCamerPreview();
                              showBarcodeFormateDialog();
                            },
                            child: Image.asset(
                              "assets/images/barcode.png",
                              height: 40,
                              width: 40,
                            ),
                          ),
                        )
                  : Container(),
              AnimatedBuilder(
                animation: _frontRotation,
                builder: (BuildContext context, Widget child) {
                  var transform = Matrix4.identity();
                  transform.setEntry(3, 2, 0.001);
                  transform.rotateY(_frontRotation.value);
                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: animimage_visible,
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          child: Image.asset("assets/flip.png"),
                        ),
                      ),
                    ),
                  );
                },
              ),
              colors.orientation == "0"
                  ? Container(
                      alignment: Alignment.topCenter,
                      height: 55,
                      width: MediaQuery.of(context).size.width,
                      child: AppBar(
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        actions: [
                          GestureDetector(
                              onTap: () {
                                controller.flipCamera();
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Image.asset(
                                  "assets/images/ic_camera.png",
                                  height: 40,
                                  width: 40,
                                ),
                              )),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _leftRotation() {
    _toggleSide(false);
  }

  void _rightRotation() {
    _toggleSide(true);
  }

  void _toggleSide(bool isRightTap) {
    _updateRotations(isRightTap);
    if (isFrontVisible) {
      controller_anim.forward();
      isFrontVisible = false;
    } else {
      controller_anim.reverse();
      isFrontVisible = true;
    }
  }

  _updateRotations(bool isRightTap) {
    setState(() {
      bool rotateToLeft =
          (isFrontVisible && !isRightTap) || !isFrontVisible && isRightTap;
      _frontRotation = TweenSequence(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween(begin: 0.0, end: rotateToLeft ? (pi) : (-pi))
                .chain(CurveTween(curve: Curves.linear)),
            weight: 50.0,
          ),
          TweenSequenceItem<double>(
            tween: ConstantTween<double>(rotateToLeft ? (-pi) : (pi)),
            weight: 50.0,
          ),
        ],
      ).animate(controller_anim);
    });
  }

  void startCamera(ScanPreviewController controller) {
    controller.startCamera(widget.recogType, widget.card_id, widget.country_id,
        widget.mrzDocumentType);
  }

  void setSound(ScanPreviewController controller) {
    Future.delayed(const Duration(seconds: 5), () {});
  }

  void showBarcodeFormateDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          controller.restartCameraPreview();

          print("cklnclmn");
        },
        child: AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            height: 250,
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: colors.theme_color,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
                  child: Row(
                    children: [
                      Text(
                        "Barcode Format",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.restartCameraPreview();
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: barcodeFormatList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        slectedBarcode = index;
                        AccuraKycFlutter.setBarcodeType(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          barcodeFormatList[index],
                          style: TextStyle(
                              color: index == slectedBarcode
                                  ? colors.theme_color
                                  : Colors.black,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class cameraFacing {
  static int CAMERA_FACING_BACK = 0;
  static int CAMERA_FACING_FRONT = 1;
}

class cardSide {
  static int BACK_CARD_SCAN = 0;
  static int FRONT_CARD_SCAN = 1;
  static int FIRST_FRONT_AFTER_BACK = 2;
  static int FIRST_BACK_AFTER_FRONT = 3;
}
