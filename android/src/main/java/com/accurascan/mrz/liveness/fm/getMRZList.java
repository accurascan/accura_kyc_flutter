package com.accurascan.mrz.liveness.fm;


import static com.accurascan.mrz.liveness.fm.UnsafeOkHttpClient.getUnsafeOkHttpClient;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;

import com.inet.facelock.callback.FaceCallback;
import com.inet.facelock.callback.FaceDetectionResult;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.os.Parcel;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.widget.Toast;

import com.inet.facelock.callback.FaceHelper;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.accurascan.facedetection.LivenessCustomization;
import com.accurascan.facedetection.SelfieCameraActivity;
import com.accurascan.facedetection.model.AccuraVerificationResult;
import com.accurascan.ocr.mrz.model.ContryModel;
import com.accurascan.ocr.mrz.motiondetection.SensorsActivity;
import com.androidnetworking.AndroidNetworking;
import com.androidnetworking.common.Priority;
import com.androidnetworking.error.ANError;
import com.androidnetworking.interfaces.JSONObjectRequestListener;
import com.docrecog.scan.RecogEngine;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import okhttp3.OkHttpClient;


public class getMRZList implements MethodChannel.MethodCallHandler, ActivityAware, FaceCallback, FaceHelper.FaceMatchCallBack, PluginRegistry.ActivityResultListener {
    public static Activity mActivity;
    public static Context mContext;
    private List<ContryModel> modelList = new ArrayList();
    private final static int ACCURA_LIVENESS_CAMERA = 100;
    LivenessCustomization livenessCustomization = new LivenessCustomization();
    public static MethodChannel.Result liveness_result;
    private String TAG = "getMRZListgetMRZListgetMRZListgetMRZList";

    RecogEngine recogEngine;

    public getMRZList(Activity mActivity, Context mContext) {

        this.mActivity = mActivity;
        this.mContext = mContext;

    }

    @Override
    public void onMethodCall(@NonNull @NotNull MethodCall call, @NonNull @NotNull MethodChannel.Result result) {
        liveness_result = result;
        Log.e(TAG, "onMethodCall:getMRZListgetMRZListgetMRZListgetMRZList " + call.method);
        switch (call.method) {
            case "getMrzList":
                getAllMrzAndCountryList(call, result);
                break;

            case "checkLiveness":

                startLiveness(call, result);

                break;

            case "start_facematch":

                startFaceMatch(call, result);
                break;

            case "start_facematching":
                startfaceMatching(call, result);
                break;

            case "updateFilters":
                UpdateFilters(call, result);
                break;
            default:
                break;
        }
    }

    private void UpdateFilters(MethodCall call, MethodChannel.Result result) {
        recogEngine = new RecogEngine();
        String blurPercentage = call.argument("blurPercentage");
        String faceBlurPercentage = call.argument("faceBlurPercentage");
        String minGlarePercentage = call.argument("minGlarePercentage");
        String maxGlarePercentage = call.argument("maxGlarePercentage");
        String isCheckPhotoCopy = call.argument("isCheckPhotoCopy");
        String isDetectHologram = call.argument("isDetectHologram");
        String lightTolerance = call.argument("lightTolerance");
        String motionThreshold = call.argument("motionThreshold");


        if (blurPercentage != null && blurPercentage != "null") {
            recogEngine.setBlurPercentage(mContext, Integer.valueOf(blurPercentage));
        }
        if (faceBlurPercentage != null && faceBlurPercentage != "null") {
            recogEngine.setFaceBlurPercentage(mContext, Integer.valueOf(faceBlurPercentage));
        }
        if (minGlarePercentage != null && minGlarePercentage != "null" && maxGlarePercentage != null && maxGlarePercentage != "null") {
            recogEngine.setGlarePercentage(mContext, Integer.valueOf(minGlarePercentage), Integer.valueOf(maxGlarePercentage));
        }
        if (isCheckPhotoCopy != null && isCheckPhotoCopy != "null") {
            if (isCheckPhotoCopy == "1") {
                recogEngine.isCheckPhotoCopy(mContext, true);
            } else {
                recogEngine.isCheckPhotoCopy(mContext, false);
            }

        }
        if (isDetectHologram != null && isDetectHologram != "null") {
            if (isDetectHologram == "1") {
                recogEngine.SetHologramDetection(mContext, true);
            } else {
                recogEngine.SetHologramDetection(mContext, false);
            }

        }
        if (lightTolerance != null && lightTolerance != "null") {
            recogEngine.setLowLightTolerance(mContext, Integer.valueOf(lightTolerance));
        }
        if (motionThreshold != null && motionThreshold != "null") {
            recogEngine.setMotionThreshold(mActivity, Integer.valueOf(motionThreshold));
        }
    }

    private void startfaceMatching(MethodCall call, MethodChannel.Result result) {

        // Initialized facehelper in onCreate.
        FaceHelper helper = new FaceHelper(mActivity);
        helper.setFaceMatchCallBack(this);
        helper.setFacecallBack(this);
        helper.initEngine();
        String documentimage = call.argument("documentImage");
        String liveImage = call.argument("liveImage");
        Bitmap documentBitmap = Base64ToBitmap(documentimage);
        Bitmap liveBitmap = Base64ToBitmap(liveImage);

        helper.setInputImage(documentBitmap);
        helper.setMatchImage(liveBitmap);

    }

    Bitmap Base64ToBitmap(String myImageData) {
        byte[] imageAsBytes = Base64.decode(myImageData.getBytes(), Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(imageAsBytes, 0, imageAsBytes.length);
    }


    private void startFaceMatch(MethodCall call, MethodChannel.Result result) {
        LivenessCustomization cameraScreenCustomization = new LivenessCustomization();
        String backGroundColor = call.argument("backGroundColor");
        String closeIconColor = call.argument("closeIconColor");
        String feedbackBackGroundColor = call.argument("feedbackBackGroundColor");
        String feedbackTextColor = call.argument("feedbackTextColor");
        String feedbackTextSize = call.argument("feedbackTextSize");
        String feedBackframeMessage = call.argument("feedBackframeMessage");
        String feedBackAwayMessage = call.argument("feedBackAwayMessage");
        String feedBackOpenEyesMessage = call.argument("feedBackOpenEyesMessage");
        String feedBackCloserMessage = call.argument("feedBackCloserMessage");
        String feedBackCenterMessage = call.argument("feedBackCenterMessage");
        String feedBackMultipleFaceMessage = call.argument("feedBackMultipleFaceMessage");
        String feedBackHeadStraightMessage = call.argument("feedBackHeadStraightMessage");
        String setBlurPercentage = call.argument("setBlurPercentage");
        String setminGlarePercentage = call.argument("setminGlarePercentage");
        String setmaxGlarePercentage = call.argument("setmaxGlarePercentage");
        String feedBackBlurFaceMessage = call.argument("feedBackBlurFaceMessage");
        String feedBackGlareFaceMessage = call.argument("feedBackGlareFaceMessage");


        if (!TextUtils.isEmpty(backGroundColor)) {
            cameraScreenCustomization.backGroundColor = Color.parseColor(backGroundColor);
        }
        if (!TextUtils.isEmpty(closeIconColor)) {
            cameraScreenCustomization.closeIconColor = Color.parseColor(closeIconColor);
        }
        if (!TextUtils.isEmpty(feedbackBackGroundColor)) {
            cameraScreenCustomization.feedbackBackGroundColor = Color.parseColor(feedbackBackGroundColor);
        }
        if (!TextUtils.isEmpty(feedbackTextColor)) {
            cameraScreenCustomization.feedbackTextColor = Color.parseColor(feedbackTextColor);
        }

        if (!TextUtils.isEmpty(feedbackTextSize) && !feedbackTextSize.equalsIgnoreCase("null")) {
            cameraScreenCustomization.feedbackTextSize = Integer.valueOf(feedbackTextSize);
        }
        if (!TextUtils.isEmpty(feedBackframeMessage)) {
            cameraScreenCustomization.feedBackframeMessage = feedBackframeMessage;
        }
        if (!TextUtils.isEmpty(feedBackAwayMessage)) {
            cameraScreenCustomization.feedBackAwayMessage = feedBackAwayMessage;
        }
        if (!TextUtils.isEmpty(feedBackOpenEyesMessage)) {
            cameraScreenCustomization.feedBackOpenEyesMessage = feedBackOpenEyesMessage;
        }
        if (!TextUtils.isEmpty(feedBackCloserMessage)) {
            cameraScreenCustomization.feedBackCloserMessage = feedBackCloserMessage;
        }
        if (!TextUtils.isEmpty(feedBackCenterMessage)) {
            cameraScreenCustomization.feedBackCenterMessage = feedBackCenterMessage;
        }
        if (!TextUtils.isEmpty(feedBackMultipleFaceMessage)) {
            cameraScreenCustomization.feedBackMultipleFaceMessage = feedBackMultipleFaceMessage;
        }
        if (!TextUtils.isEmpty(feedBackHeadStraightMessage)) {
            cameraScreenCustomization.feedBackHeadStraightMessage = feedBackHeadStraightMessage;
        }
        if (!TextUtils.isEmpty(feedBackBlurFaceMessage)) {
            cameraScreenCustomization.feedBackBlurFaceMessage = feedBackBlurFaceMessage;
        }
        if (!TextUtils.isEmpty(feedBackGlareFaceMessage)) {
            cameraScreenCustomization.feedBackGlareFaceMessage = feedBackGlareFaceMessage;
        }

        if (!TextUtils.isEmpty(setBlurPercentage) && !setBlurPercentage.equalsIgnoreCase("null")) {
            cameraScreenCustomization.setBlurPercentage(Integer.valueOf(setBlurPercentage));
        }

        if (setminGlarePercentage != null && setmaxGlarePercentage != null && setminGlarePercentage != "" && setmaxGlarePercentage != "" && !setminGlarePercentage.equalsIgnoreCase("null") && !setmaxGlarePercentage.equalsIgnoreCase("null")) {
            cameraScreenCustomization.setGlarePercentage(Integer.valueOf(setminGlarePercentage), Integer.valueOf(setmaxGlarePercentage));
        }
        IntentFilter intentFilter = new IntentFilter();

       
        Intent intent = SelfieCameraActivity.getFaceMatchCameraIntent(mActivity, cameraScreenCustomization);
        if (intent != null) {
            mActivity.startActivityForResult(intent, 1212);
        } else {
            Toast.makeText(mActivity, "Please Enter valid Liveness Url", Toast.LENGTH_SHORT).show();
        }
    }


    private void startLiveness(MethodCall call, MethodChannel.Result result) {
        AndroidNetworking.initialize(mActivity, getUnsafeOkHttpClient());
        String livenessUrl = call.argument("LivenessUrl");
        String backGroundColor = call.argument("backGroundColor");
        String closeIconColor = call.argument("closeIconColor");
        String feedbackBackGroundColor = call.argument("feedbackBackGroundColor");
        String feedbackTextColor = call.argument("feedbackTextColor");
        String feedBackframeMessage = call.argument("feedBackframeMessage");
        String feedBackAwayMessage = call.argument("feedBackAwayMessage");
        String feedBackOpenEyesMessage = call.argument("feedBackOpenEyesMessage");
        String feedBackCloserMessage = call.argument("feedBackCloserMessage");
        String feedBackCenterMessage = call.argument("feedBackCenterMessage");
        String feedBackMultipleFaceMessage = call.argument("feedBackMultipleFaceMessage");
        String feedBackHeadStraightMessage = call.argument("feedBackHeadStraightMessage");
        String feedBackBlurFaceMessage = call.argument("feedBackBlurFaceMessage");
        String feedBackGlareFaceMessage = call.argument("feedBackGlareFaceMessage");

        String setBlurPercentage = call.argument("setBlurPercentage");
        String setminGlarePercentage = call.argument("setminGlarePercentage");
        String setmaxGlarePercentage = call.argument("setmaxGlarePercentage");
        String feedbackTextSize = call.argument("feedbackTextSize");

        if (!TextUtils.isEmpty(backGroundColor)) {
            livenessCustomization.backGroundColor = Color.parseColor(backGroundColor);
        }
        if (!TextUtils.isEmpty(closeIconColor)) {
            livenessCustomization.closeIconColor = Color.parseColor(closeIconColor);
        }
        if (!TextUtils.isEmpty(feedbackBackGroundColor)) {
            livenessCustomization.feedbackBackGroundColor = Color.parseColor(feedbackBackGroundColor);
        }
        if (!TextUtils.isEmpty(feedbackTextColor)) {
            livenessCustomization.feedbackTextColor = Color.parseColor(feedbackTextColor);
        }
        if (!TextUtils.isEmpty(feedBackframeMessage)) {
            livenessCustomization.feedBackframeMessage = feedBackframeMessage;
        }
        if (!TextUtils.isEmpty(feedBackAwayMessage)) {
            livenessCustomization.feedBackAwayMessage = feedBackAwayMessage;
        }
        if (!TextUtils.isEmpty(feedBackOpenEyesMessage)) {
            livenessCustomization.feedBackOpenEyesMessage = feedBackOpenEyesMessage;
        }
        if (!TextUtils.isEmpty(feedBackCloserMessage)) {
            livenessCustomization.feedBackCloserMessage = feedBackCloserMessage;
        }
        if (!TextUtils.isEmpty(feedBackCenterMessage)) {
            livenessCustomization.feedBackCenterMessage = feedBackCenterMessage;
        }
        if (!TextUtils.isEmpty(feedBackMultipleFaceMessage)) {
            livenessCustomization.feedBackMultipleFaceMessage = feedBackMultipleFaceMessage;
        }
        if (!TextUtils.isEmpty(feedBackHeadStraightMessage)) {
            livenessCustomization.feedBackHeadStraightMessage = feedBackHeadStraightMessage;
        }
        if (!TextUtils.isEmpty(feedBackBlurFaceMessage)) {
            livenessCustomization.feedBackBlurFaceMessage = feedBackBlurFaceMessage;
        }
        if (!TextUtils.isEmpty(feedBackGlareFaceMessage)) {
            livenessCustomization.feedBackGlareFaceMessage = feedBackGlareFaceMessage;
        }

        if (!TextUtils.isEmpty(feedbackTextSize)) {
            livenessCustomization.feedbackTextSize = Integer.valueOf(feedbackTextSize);
        }
        if (!TextUtils.isEmpty(setBlurPercentage)) {
            livenessCustomization.setBlurPercentage(Integer.valueOf(setBlurPercentage));
        }
        if (!TextUtils.isEmpty(setminGlarePercentage) && !TextUtils.isEmpty(setmaxGlarePercentage)) {
            livenessCustomization.setGlarePercentage(Integer.valueOf(setminGlarePercentage), Integer.valueOf(setmaxGlarePercentage));
        }

        IntentFilter intentFilter = new IntentFilter();
        
        Intent intent = SelfieCameraActivity.getLivenessCameraIntent(mActivity, livenessCustomization, livenessUrl);

        Log.e(TAG, "livenessUrl:- " + livenessUrl);
        if (intent != null) {
            mActivity.startActivityForResult(intent, 1010);
        } else {
            Toast.makeText(mActivity, "Please Enter valid Liveness Url", Toast.LENGTH_SHORT).show();
        }
    }


    private void getAllMrzAndCountryList(MethodCall call, MethodChannel.Result result) {
        recogEngine = new RecogEngine();
        RecogEngine.SDKModel sdkModel = recogEngine.initEngine(mActivity);
        Log.e(TAG, "sdkmodelSize" + sdkModel.i);
        ArrayList<mrzListModel> datalist = new ArrayList<>();
        mrzListModel mrzListModel = new mrzListModel();

        if (sdkModel.i > 0) { // means license is valid
            if (sdkModel.isMRZEnable) {
                mrzListModel.setMRZEnable(true);
                Log.e(TAG, "isMRZEnable:" + sdkModel.isMRZEnable);
                // RecogType.MRZ

            } else {
                mrzListModel.setMRZEnable(false);

            }
            if (sdkModel.isBankCardEnable) {// RecogType.BANKCARD
                mrzListModel.setBankCardEnable(true);
                Log.e(TAG, "isBankCardEnable:" + sdkModel.isBankCardEnable);
            } else {
                mrzListModel.setBankCardEnable(false);
            }

            if (sdkModel.isAllBarcodeEnable) {
                mrzListModel.setAllBarcodeEnable(true);
                Log.e(TAG, "isAllBarcodeEnable:" + sdkModel.isAllBarcodeEnable);
                // RecogType.BARCODE
            } else {
                mrzListModel.setAllBarcodeEnable(false);
            }

            // sdkModel.isOCREnable is true then get card list which you are selected on creating license
            if (sdkModel.isOCREnable) {
                mrzListModel.setOCREnable(true);
                modelList = recogEngine.getCardList(mContext);
                Log.e(TAG, "isAllBarcodeEnable:" + modelList.size());

            } else {
                mrzListModel.setOCREnable(false);
            }
            if (modelList != null) {
                ArrayList<countrydataModel> countrydatalist = new ArrayList<>();
                for (int i = 0; i < modelList.size(); i++) {
                    countrydataModel countrydataModel = new countrydataModel();
                    // if country & card added in license
                    ContryModel contryModel = new ContryModel();
                    contryModel = modelList.get(i);
                    countrydataModel.setCountry_id(contryModel.getCountry_id());
                    countrydataModel.setCountry_name(String.valueOf(contryModel.getCountry_name()));
                    ArrayList<OcrDataModel> ocrDataList = new ArrayList<>();

                    /******************/
                    for (int index = 0; index < contryModel.getCards().size(); index++) {
                        OcrDataModel ocrDataModel = new OcrDataModel();
                        ContryModel.CardModel model = contryModel.getCards().get(index);// getting card
                        ocrDataModel.setCard_Id(model.getCard_id());
                        ocrDataModel.setCard_Country_Name(model.getCard_name());
                        ocrDataModel.setCardType(model.getCard_type());
                        ocrDataModel.setRecog_Type(model.getCard_type());
                        ocrDataList.add(ocrDataModel);

                    }

                    /*******************/
                    countrydataModel.setOcr_data_list(ocrDataList);
                    countrydatalist.add(countrydataModel);
                }

                mrzListModel.setCountrymodeldata(countrydatalist);

            }
            datalist.add(mrzListModel);
            JSONArray mainJsonObject = new JSONArray();


            if (datalist.get(0).isMRZEnable()) {
                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Mrz", 1);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);

            } else {
                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Mrz", 0);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);
            }
            if (datalist.get(0).isBankCardEnable()) {

                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Bank_Card", 1);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);
            } else {

                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Bank_Card", 0);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);
            }
            if (datalist.get(0).isAllBarcodeEnable()) {
                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Barcode", 1);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);
            } else {
                JSONObject object1 = new JSONObject();
                try {
                    object1.put("Barcode", 0);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mainJsonObject.put(object1);
            }


            for (int i = 0; i < datalist.get(0).countrymodeldata.size(); i++) {
                try {
                    JSONObject countrynameObject = new JSONObject();
                    countrynameObject.put("country_name", datalist.get(0).countrymodeldata.get(i).getCountry_name());
                    countrynameObject.put("country_id", datalist.get(0).countrymodeldata.get(i).getCountry_id());


                    JSONArray ocrListArray = new JSONArray();
                    for (int index = 0; index < datalist.get(0).countrymodeldata.get(i).ocr_data_list.size(); index++) {
                        JSONObject ocr_object = new JSONObject();
                        ocr_object.put("card_id", datalist.get(0).countrymodeldata.get(i).ocr_data_list.get(index).getCard_Id());
                        ocr_object.put("card_name", datalist.get(0).countrymodeldata.get(i).ocr_data_list.get(index).getCard_Country_Name());
                        ocr_object.put("card_type", datalist.get(0).countrymodeldata.get(i).ocr_data_list.get(index).getRecog_Type());
                        ocrListArray.put(ocr_object);
                    }
                    countrynameObject.put("cards", ocrListArray);

                    mainJsonObject.put(countrynameObject);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            JSONObject object = new JSONObject();
            try {
                object.put("All_Data", mainJsonObject);
                object.put("sdk_rate_value", sdkModel.i);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            Log.e(TAG, "getAllMrzAndCountryList: " + object.toString());
            result.success(object.toString());

        } else {
            // sdk_rate_value
            JSONObject object = new JSONObject();
            try {
                object.put("sdk_rate_value", sdkModel.i);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            result.success(object.toString());
        }
    }


    @Override
    public void onFaceMatch(float ret) {
        Log.e("onFaceMatch", "onFaceMatch: "+ret );
        liveness_result.success("" + ret);
    }

    @Override
    public void onSetInputImage(Bitmap src) {
    }

    @Override
    public void onSetMatchImage(Bitmap src) {
    }

    @Override
    public void onInitEngine(int ret) {
    }

    @Override
    public void onExtractInit(int ret) {
    }

    @Override
    public void onLeftDetect(FaceDetectionResult faceResult) {
        // Receive byte buffer of face from inputImage..
    }

    //call if face detect
    @Override
    public void onRightDetect(FaceDetectionResult faceResult) {
        // Receive byte buffer of face from matchImage.
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return true;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
