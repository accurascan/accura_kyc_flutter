# accura_kyc_flutter

This package is for digital user verification system powered by Accura Scan. 

**Installation using PubGet**

`flutter pub add <absolute-path-to-(accura_kyc_flutter)-folder>`
### Example
`flutter pub add I:\download\accura_kyc_flutter`

## Setup Android
### Add this permissions into Android AndroidManifest.xml file.
```sh
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

### Add it in your root build.gradle at the end of repositories.
```sh
buildscript {
    repositories {
        ...
        jcenter()
    }
}

allprojects {
    repositories {
        ...
        jcenter()
    }
}
```

## Setup iOS
### Add this permissions into iOS Info.plist file.
```sh
<key>NSCameraUsageDescription</key>
<string>App usage camera for scan documents.</string>
<key>NSMicrophoneUsageDescription</key>
<string>App usage microphone for oral verification.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>App usage speech recognition for oral verification.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App usage photos for get document picture.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>App usage photos for save document picture.</string>
```

## Setup Accura license into your projects
**Accura has license require for use full functionality of this library. Generate your own Accura license from [here](https://accurascan.com/developer/dashboard)**
1. ### key.license 
    - This license is compulsory for this library to work. it will get all setup of accura SDK.

***Note:-*** You have to create license of your own bundle id for iOS and app id for Android. You can not use any other app license. If you use other app license then it will return error.

**1. Setup license into Android**
- Go to android -> app -> src -> main and create folder named 'assets' if not exist and put license into that folder.

**2. Setup license into iOS**
- Open iOS project into Xcode and drag & drop all license into project root directory. Do not forgot to check "copy if needed" & "project name".

## Usage

Import flutter library into file.
```js
import 'package:accura_kyc_flutter/accura_kyc_flutter.dart';
```
### Please add bellow files into your project-> lib directory.
1. CameraScreen.dart
2. result_activity.dart
3. model/mrzandcountrylistmodel.dart
4. model/OCR_Data_model.dart

### ➜ Get license configuration from SDK. It returns all active functionalities of your license.
```js
try {
      var data = await AccuraKycFlutter.getOcrList();

      print("dataListdataList${data}");
      mrzandcountrylistmodel model =
          mrzandcountrylistmodel.fromJson(jsonDecode(data));
      if (model.sdkRate > 0) {
        // success response of data
      } else {
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
      }
    } on PlatformException catch (e) {}
```

### ➜ Method for scan MRZ documents.
- cardType: String 
    - value: "MRZ"
- card_id: String 
    - value: "0"
- card_name: String 
    - value: "Passport MRZ", "ID card MRZ", "VISA MRZ", "ALL MRZ"
- country_id: String 
    - value: "0"
- mrzDocumentType: String
    - value: "Passport MRZ" -> "1", "ID card MRZ" -> "2", "VISA MRZ" -> "3", "ALL MRZ" -> "0"
```js
String cardType = "MRZ";
String card_id = "0";
String card_name = "Passport MRZ";
String country_id = "0";
String mrzDocumentType = "1";
Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraScreen(cardType, card_id, card_name,country_id,mrzDocumentType)));

```
### ➜ Method for scan OCR documents.

- cardType: String 
    - value: You will get from "getOcrList()" model
- card_id: String 
    - value: You will get from "getOcrList()" model
- card_name: String 
    - value: You will get from "getOcrList()" model
- country_id: String 
    - value: You will get from "getOcrList()" model
- mrzDocumentType: String
    - value: "0"
```js
String cardType = "0";
String card_id = "49";
String card_name = "Victoria Driving License";
String country_id = "12";
String mrzDocumentType = "0";
Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraScreen(cardType, card_id, card_name,country_id,mrzDocumentType)));
```
### ➜ Method for scan barcode.
- cardType: String 
    - value: "BARCODE"
- card_id: String 
    - value: "0"
- card_name: String 
    - value: "Barcode"
- country_id: String 
    - value: "0"
- mrzDocumentType: String
    - value: "0"
```js
String cardType = "BARCODE";
String card_id = "0";
String card_name = "Barcode";
String country_id = "0";
String mrzDocumentType = "0";
Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraScreen(cardType, card_id, card_name,country_id,mrzDocumentType)));
```
### ➜ Method for scan bankcard.
- cardType: String 
    - value: "BANKCARD"
- card_id: String 
    - value: "0"
- card_name: String 
    - value: "Bank Card"
- country_id: String 
    - value: 0
- mrzDocumentType: String
    - value: 0
```js
String cardType = "BANKCARD";
String card_id = "0";
String card_name = "Bank Card";
String country_id = "0";
String mrzDocumentType = "0";
Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraScreen(cardType, card_id, card_name,country_id,mrzDocumentType)));
```
### ➜ Get result of any scanning.
➜ You will get result model as "OCR_Data_model" into the result_activity.dart

Thanks.
