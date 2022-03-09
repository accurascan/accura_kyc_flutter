class OCR_Data_model {
  List<OcrData> ocrData;

  List<DLPLATE> dLPLATE;

  OCR_Data_model({this.ocrData});

  OCR_Data_model.fromJson(Map<String, dynamic> json) {
    if (json['ocr_data'] != null) {
      ocrData = new List<OcrData>();
      json['ocr_data'].forEach((v) {
        ocrData.add(new OcrData.fromJson(v));
      });
    }
    if (json['DL_PLATE'] != null) {
      dLPLATE = new List<DLPLATE>();
      json['DL_PLATE'].forEach((v) {
        dLPLATE.add(new DLPLATE.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ocrData != null) {
      data['ocr_data'] = this.ocrData.map((v) => v.toJson()).toList();
    }
    if (this.dLPLATE != null) {
      data['DL_PLATE'] = this.dLPLATE.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DLPLATE {
  String frontImage;
  String recogType;
  List<FrontData> frontData;

  DLPLATE({this.frontImage, this.recogType, this.frontData});

  DLPLATE.fromJson(Map<String, dynamic> json) {
    frontImage = json['front_Image'];
    recogType = json['recog_type'];
    if (json['front_data'] != null) {
      frontData = new List<FrontData>();
      json['front_data'].forEach((v) {
        frontData.add(new FrontData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['front_Image'] = this.frontImage;
    data['recog_type'] = this.recogType;
    if (this.frontData != null) {
      data['front_data'] = this.frontData.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OcrData {
  String cardName;
  String faceImage;
  String backImage;
  String frontImage;
  String recogType;
  List<FrontData> frontData;
  List<MRZData> mRZData;
  List<BackData> backData;
  List<BankData> bankData;
  List<Pdf417Data> pdf417Data;

  OcrData(
      {this.cardName,
        this.faceImage,
        this.backImage,
        this.frontImage,
        this.recogType,
        this.frontData,
        this.mRZData,
        this.backData,this.bankData,this.pdf417Data});

  OcrData.fromJson(Map<String, dynamic> json) {
    cardName = json['card_Name'];
    faceImage = json['Face_Image'];
    backImage = json['back_Image'];
    frontImage = json['front_Image'];
    recogType = json['recog_type'];
    if (json['front_data'] != null) {
      frontData = new List<FrontData>();
      json['front_data'].forEach((v) {
        frontData.add(new FrontData.fromJson(v));
      });
    }
    if (json['MRZ_Data'] != null) {
      mRZData = new List<MRZData>();
      json['MRZ_Data'].forEach((v) {
        mRZData.add(new MRZData.fromJson(v));
      });
    }
    if (json['back_data'] != null) {
      backData = new List<BackData>();
      json['back_data'].forEach((v) {
        backData.add(new BackData.fromJson(v));
      });
    }
    if (json['bank_Data'] != null) {
      bankData = new List<BankData>();
      json['bank_Data'].forEach((v) {
        bankData.add(new BankData.fromJson(v));
      });

    }
    if (json['pdf417_data'] != null) {
      pdf417Data = new List<Pdf417Data>();
      json['pdf417_data'].forEach((v) {
        pdf417Data.add(new Pdf417Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_Name'] = this.cardName;
    data['Face_Image'] = this.faceImage;
    data['back_Image'] = this.backImage;
    data['front_Image'] = this.frontImage;
    data['recog_type'] = this.recogType;

    if (this.frontData != null) {
      data['front_data'] = this.frontData.map((v) => v.toJson()).toList();
    }
    if (this.mRZData != null) {
      data['MRZ_Data'] = this.mRZData.map((v) => v.toJson()).toList();
    }
    if (this.backData != null) {
      data['back_data'] = this.backData.map((v) => v.toJson()).toList();
    }
    if (this.bankData != null) {
      data['bank_Data'] = this.bankData.map((v) => v.toJson()).toList();
    }
    if (this.pdf417Data != null) {
      data['pdf417_data'] = this.pdf417Data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FrontData {
  int scannedType;
  String frontKey;
  String frontKeydata;

  FrontData({this.scannedType, this.frontKey, this.frontKeydata});

  FrontData.fromJson(Map<String, dynamic> json) {
    scannedType = json['scanned_type'];
    frontKey = json['front_key'];
    frontKeydata = json['front_keydata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scanned_type'] = this.scannedType;
    data['front_key'] = this.frontKey;
    data['front_keydata'] = this.frontKeydata;
    return data;
  }
}

class MRZData {
  String MRZ_key;
  String MRZ_data;

  MRZData({this.MRZ_key, this.MRZ_data});

  MRZData.fromJson(Map<String, dynamic> json) {
    MRZ_key = json['MRZ_key'];
    MRZ_data = json['MRZ_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MRZ_key'] = this.MRZ_key;
    data['MRZ_data'] = this.MRZ_data;
    return data;
  }
}

class BackData {
  int scannedType;
  String backKey;
  String backKeydata;

  BackData({this.scannedType, this.backKey, this.backKeydata});

  BackData.fromJson(Map<String, dynamic> json) {
    scannedType = json['scanned_type'];
    backKey = json['back_key'];
    backKeydata = json['back_keydata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scanned_type'] = this.scannedType;
    data['back_key'] = this.backKey;
    data['back_keydata'] = this.backKeydata;
    return data;
  }
}


class BankData {
  String Bank_key;
  String Bank_data;

  BankData({this.Bank_key, this.Bank_data});

  BankData.fromJson(Map<String, dynamic> json) {
    Bank_key = json['Bank_key'];
    Bank_data = json['Bank_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Bank_key'] = this.Bank_key;
    data['Bank_data'] = this.Bank_data;
    return data;
  }
}
class Pdf417Data {
  String pDF417Key;
  String pDF417Keydata;

  Pdf417Data({this.pDF417Key, this.pDF417Keydata});

  Pdf417Data.fromJson(Map<String, dynamic> json) {
    pDF417Key = json['PDF417_key'];
    pDF417Keydata = json['PDF417_keydata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PDF417_key'] = this.pDF417Key;
    data['PDF417_keydata'] = this.pDF417Keydata;
    return data;
  }
}