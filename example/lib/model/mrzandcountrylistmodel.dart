
class mrzandcountrylistmodel {
  List<AllData> allData;
  int sdkRate;


  mrzandcountrylistmodel({this.allData});

  mrzandcountrylistmodel.fromJson(Map<String, dynamic> json) {
    if (json['All_Data'] != null) {
      allData = new List<AllData>();
      json['All_Data'].forEach((v) {
        allData.add(new AllData.fromJson(v));
      });
    }
    sdkRate = json['sdk_rate_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.allData != null) {
      data['All_Data'] = this.allData.map((v) => v.toJson()).toList();
    }
    data['sdk_rate_value'] = this.sdkRate;
    return data;
  }
}

class AllData {
  int mrz;
  int barcode;
  int bankCard;
  String countryName;
  int countryId;
  List<Cards> cards;

  AllData(
      {this.mrz,
        this.barcode,
        this.bankCard,
        this.countryName,
        this.countryId,
        this.cards});

  AllData.fromJson(Map<String, dynamic> json) {
    mrz = json['Mrz'];
    barcode = json['Barcode'];
    bankCard = json['Bank_Card'];
    countryName = json['country_name'];
    countryId = json['country_id'];
    if (json['cards'] != null) {
      cards = new List<Cards>();
      json['cards'].forEach((v) {
        cards.add(new Cards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Mrz'] = this.mrz;
    data['Barcode'] = this.barcode;
    data['Bank_Card'] = this.bankCard;
    data['country_name'] = this.countryName;
    data['country_id'] = this.countryId;
    if (this.cards != null) {
      data['cards'] = this.cards.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cards {
  int cardId;
  String cardName;
  int cardType;

  Cards({this.cardId, this.cardName, this.cardType});

  Cards.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    cardName = json['card_name'];
    cardType = json['card_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_id'] = this.cardId;
    data['card_name'] = this.cardName;
    data['card_type'] = this.cardType;
    return data;
  }
}