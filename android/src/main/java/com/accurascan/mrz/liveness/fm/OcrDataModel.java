package com.accurascan.mrz.liveness.fm;

public class OcrDataModel {
    int card_Id;
    String card_Country_Name;
    int recog_Type;
    int cardType;

    public int getCard_Id() {
        return card_Id;
    }

    public void setCard_Id(int card_Id) {
        this.card_Id = card_Id;
    }

    public String getCard_Country_Name() {
        return card_Country_Name;
    }

    public void setCard_Country_Name(String card_Country_Name) {
        this.card_Country_Name = card_Country_Name;
    }

    public int getRecog_Type() {
        return recog_Type;
    }

    public void setRecog_Type(int recog_Type) {
        this.recog_Type = recog_Type;
    }

    public int getCardType() {
        return cardType;
    }

    public void setCardType(int cardType) {
        this.cardType = cardType;
    }
}
