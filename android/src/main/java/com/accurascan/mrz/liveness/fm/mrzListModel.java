package com.accurascan.mrz.liveness.fm;

import java.util.ArrayList;

public class mrzListModel {
    boolean isMRZEnable;
    boolean isBankCardEnable;
    boolean isAllBarcodeEnable;
    boolean isOCREnable;
    ArrayList<countrydataModel> countrymodeldata;

    public ArrayList<countrydataModel> getCountrymodeldata() {
        return countrymodeldata;
    }

    public void setCountrymodeldata(ArrayList<countrydataModel> countrymodeldata) {
        this.countrymodeldata = countrymodeldata;
    }

    public boolean isMRZEnable() {
        return isMRZEnable;
    }

    public void setMRZEnable(boolean MRZEnable) {
        isMRZEnable = MRZEnable;
    }

    public boolean isBankCardEnable() {
        return isBankCardEnable;
    }

    public void setBankCardEnable(boolean bankCardEnable) {
        isBankCardEnable = bankCardEnable;
    }

    public boolean isAllBarcodeEnable() {
        return isAllBarcodeEnable;
    }

    public void setAllBarcodeEnable(boolean allBarcodeEnable) {
        isAllBarcodeEnable = allBarcodeEnable;
    }

    public boolean isOCREnable() {
        return isOCREnable;
    }

    public void setOCREnable(boolean OCREnable) {
        isOCREnable = OCREnable;
    }
}
