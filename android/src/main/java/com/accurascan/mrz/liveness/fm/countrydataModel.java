package com.accurascan.mrz.liveness.fm;

import java.util.ArrayList;

public class countrydataModel {
    int Country_id;
    String Country_name;
    ArrayList<OcrDataModel> ocr_data_list;

    public ArrayList<OcrDataModel> getOcr_data_list() {
        return ocr_data_list;
    }

    public void setOcr_data_list(ArrayList<OcrDataModel> ocr_data_list) {
        this.ocr_data_list = ocr_data_list;
    }

 

    public int getCountry_id() {
        return Country_id;
    }

    public void setCountry_id(int country_id) {
        Country_id = country_id;
    }

    public String getCountry_name() {
        return Country_name;
    }

    public void setCountry_name(String country_name) {
        Country_name = country_name;
    }



}
