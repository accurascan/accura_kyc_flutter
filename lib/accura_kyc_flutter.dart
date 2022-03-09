import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccuraKycFlutter {
/*  static const MethodChannel _channel =
  const MethodChannel('accura_kyc_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return versio
  }*/
  static MethodChannel channel1 = MethodChannel('scan_preview');
  static MethodChannel channel = new MethodChannel('getMrzAndCountryList');
  static BasicMessageChannel layout_width_hight_channel =
      BasicMessageChannel("layout_width_hight", StandardMessageCodec());
  static BasicMessageChannel scanSound_channel= BasicMessageChannel("playScanSound", StandardMessageCodec());

  static Future<String> getOcrList() async {
    String result = await channel.invokeMethod('getMrzList');
    return result;
  }

  static Future<void> updateFilters(
      {int blurPercentage,
      int faceBlurPercentage,
        int minGlarePercentage,
        int maxGlarePercentage,
      bool isCheckPhotoCopy,
      bool isDetectHologram,
      int lightTolerance,
      int motionThreshold}) async {
    String result = await channel.invokeMethod('updateFilters', {
     "blurPercentage": blurPercentage!=null?blurPercentage.toString():"60",
      "faceBlurPercentage": faceBlurPercentage!=null?faceBlurPercentage.toString():"70",
      "minGlarePercentage": minGlarePercentage!=null?minGlarePercentage.toString():"6",
      "maxGlarePercentage": maxGlarePercentage!=null?maxGlarePercentage.toString():"98",
      "isCheckPhotoCopy": isCheckPhotoCopy!=null?isCheckPhotoCopy ? "1" : "0":"0",
      "isDetectHologram": isDetectHologram!=null?isDetectHologram ? "1" : "0":"1",
      "lightTolerance": lightTolerance!=null?lightTolerance.toString():"39",
      "motionThreshold": motionThreshold!=null?motionThreshold.toString():"18",
    });
  }

  static Future<String> StartLiveNess(String LivenessUrl,
      {String backGroundColor,
      String closeIconColor,
      String feedbackBackGroundColor,
      String feedbackTextColor,
      int feedbackTextSize,
      String feedBackframeMessage,
      String feedBackAwayMessage,
      String feedBackOpenEyesMessage,
      String feedBackCloserMessage,
      String feedBackCenterMessage,
      String feedBackMultipleFaceMessage,
      String feedBackHeadStraightMessage,
      String feedBackBlurFaceMessage,
      String feedBackGlareFaceMessage,
      int setBlurPercentage,
      int minGlarePercentage,
      int maxGlarePercentage,bool ServerTrustWIthSSLPinning}) async {
    String result = await channel.invokeMethod('checkLiveness', {
      "LivenessUrl": LivenessUrl,
      "backGroundColor": backGroundColor,
      "closeIconColor": closeIconColor,
      "feedbackBackGroundColor": feedbackBackGroundColor,
      "feedbackTextColor": feedbackTextColor,
      'feedbackTextSize': feedbackTextSize.toString(),
      'feedBackframeMessage': feedBackframeMessage,
      'feedBackAwayMessage': feedBackAwayMessage,
      'feedBackOpenEyesMessage': feedBackOpenEyesMessage,
      'feedBackCloserMessage': feedBackCloserMessage,
      'feedBackCenterMessage': feedBackCenterMessage,
      'feedBackMultipleFaceMessage': feedBackMultipleFaceMessage,
      'feedBackHeadStraightMessage': feedBackHeadStraightMessage,
      'feedBackBlurFaceMessage': feedBackBlurFaceMessage,
      'feedBackGlareFaceMessage': feedBackGlareFaceMessage,
      'setBlurPercentage': setBlurPercentage.toString(),
      'setminGlarePercentage': minGlarePercentage.toString(),
      'maxGlarePercentage': maxGlarePercentage.toString(),
      'ServerTrustWIthSSLPinning':ServerTrustWIthSSLPinning!=null?ServerTrustWIthSSLPinning?"1":"0":"0"
    });
    return result;
  }

  static Future<String> StartFaceMatchCamera(
      {String backGroundColor,
      String closeIconColor,
      String feedbackBackGroundColor,
      String feedbackTextColor,
      int feedbackTextSize,
      String feedBackframeMessage,
      String feedBackAwayMessage,
      String feedBackOpenEyesMessage,
      String feedBackCloserMessage,
      String feedBackCenterMessage,
      String feedBackMultipleFaceMessage,
      String feedBackHeadStraightMessage,
      String feedBackBlurFaceMessage,
      String feedBackGlareFaceMessage,
      int setBlurPercentage,
      int minGlarePercentage,
      int maxGlarePercentage}) async {
    String result = await channel.invokeMethod('start_facematch', {
      "backGroundColor": backGroundColor,
      "closeIconColor": closeIconColor,
      "feedbackBackGroundColor": feedbackBackGroundColor,
      "feedbackTextColor": feedbackTextColor,
      'feedbackTextSize': feedbackTextSize.toString(),
      'feedBackframeMessage': feedBackframeMessage,
      'feedBackAwayMessage': feedBackAwayMessage,
      'feedBackOpenEyesMessage': feedBackOpenEyesMessage,
      'feedBackCloserMessage': feedBackCloserMessage,
      'feedBackCenterMessage': feedBackCenterMessage,
      'feedBackMultipleFaceMessage': feedBackMultipleFaceMessage,
      'feedBackHeadStraightMessage': feedBackHeadStraightMessage,
      'feedBackBlurFaceMessage': feedBackBlurFaceMessage,
      'feedBackGlareFaceMessage': feedBackGlareFaceMessage,
      'setBlurPercentage': setBlurPercentage.toString(),
      'setminGlarePercentage': minGlarePercentage.toString(),
      'maxGlarePercentage': maxGlarePercentage.toString()
    });
    return result;
  }

  static Future<String> StartFaceMatching(
      String documentImage, String liveImage) async {
    String result = await channel.invokeMethod('start_facematching',
        {"documentImage": documentImage, "liveImage": liveImage});
    return result;
  }

  static getSizeOfBox(Object _messageHandler) {
    layout_width_hight_channel.setMessageHandler(_messageHandler);
  }
  static playScanSound(Object _messageHandler) {
    scanSound_channel.setMessageHandler(_messageHandler);
  }

  static setCardSideScan(int cardSide) async {
    await channel1
        .invokeMethod('setCardSide', {"cardside":cardSide.toString()});
  }
  static setCameraFacing(int facing) async {
    await channel1
        .invokeMethod('setcamerafacing', {"facing":facing.toString()});
  }
  static showLogFile(bool isShow) async {
    await channel1.invokeMethod('printLogFile', {"value": isShow ?"1":"0"});
  }

  static setBarcodeType(int barcodeType) async {
    await channel1
        .invokeMethod('setBarcodeType', {"barcode":barcodeType.toString()});
  }
  static activitypause() async {
    await channel1.invokeMethod('scan#activitypause');

  }

  static activitydoOnResume() async {
    await channel1.invokeMethod('scan#activitydoOnResume');

  }

}
