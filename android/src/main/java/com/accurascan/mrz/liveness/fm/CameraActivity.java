package com.accurascan.mrz.liveness.fm;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.LinearLayoutCompat;
import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.PersistableBundle;
import android.text.TextUtils;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.accurascan.ocr.mrz.CameraView;
import com.accurascan.ocr.mrz.interfaces.OcrCallback;
import com.accurascan.ocr.mrz.model.CardDetails;
import com.accurascan.ocr.mrz.model.ContryModel;
import com.accurascan.ocr.mrz.model.OcrData;
import com.accurascan.ocr.mrz.model.PDF417Data;
import com.accurascan.ocr.mrz.model.RecogResult;
import com.accurascan.ocr.mrz.motiondetection.SensorsActivity;
import com.accurascan.ocr.mrz.util.AccuraLog;
import com.docrecog.scan.ImageOpencv;
import com.docrecog.scan.MRZDocumentType;

import com.docrecog.scan.RecogEngine;
import com.docrecog.scan.RecogType;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugin.platform.PlatformView;

public class CameraActivity extends FlutterActivity implements FlutterPlugin, PlatformView, MethodChannel.MethodCallHandler, View.OnTouchListener, View.OnClickListener, OcrCallback {
    private CameraView cameraView;
    private MethodChannel channel;
    private MethodChannel scansound;
    private BasicMessageChannel message_Channel;
    private BasicMessageChannel message_Channel_layout_width_hight;
    private BasicMessageChannel messageChannel_facematch;
    private BasicMessageChannel scanSound_channel;
    protected Camera mCameraDevice;
    private int cameraid;
    private MethodChannel methodChannel;
    private int cardId;
    private int countryId;
    private boolean mPausing;
    RecogType recogType;
    boolean isPortrait = true;
    private boolean isBack = false;
    private MRZDocumentType mrzType;
    private PluginRegistry.Registrar registrar;
    FrameLayout frameLayout;
    private FlutterEngine class_flutterEngine;
    List<HashMap<String, String>> list = new ArrayList<HashMap<String, String>>();
    int RESULT_ACTIVITY_CODE = 1010;
    Context mContext;
    Activity mActivity;
    String dummy_recogType;
    String dummy_card_id;

    String dummy_country_id;
    String dummy_mrzDocumentType;
    String CardSide;
    boolean isCardSideFront = true;

    public CameraActivity(Context context, PluginRegistry.Registrar mPluginRegistrar, int id) {

        Log.e("MethodCalling", "CameraActivity:zz ");
        this.mContext = context;
        this.registrar = mPluginRegistrar;
        this.mActivity = mPluginRegistrar.activity();
        this.cameraid = 0;
        channel = new MethodChannel(mPluginRegistrar.messenger(), "scan_preview");
        scansound = new MethodChannel(mPluginRegistrar.messenger(), "scan_sound");
        scansound.setMethodCallHandler(this);
        message_Channel = new BasicMessageChannel<>(mPluginRegistrar.messenger(), "scan_preview_message", StandardMessageCodec.INSTANCE);
        message_Channel_layout_width_hight = new BasicMessageChannel<>(mPluginRegistrar.messenger(), "layout_width_hight", StandardMessageCodec.INSTANCE);
        scanSound_channel = new BasicMessageChannel<>(mPluginRegistrar.messenger(), "playScanSound", StandardMessageCodec.INSTANCE);
        messageChannel_facematch = new BasicMessageChannel<>(mPluginRegistrar.messenger(), "scan_preview_message", StringCodec.INSTANCE);
        channel.setMethodCallHandler(this);
        initCamera();

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        // Recog type selection base on your license data
        // As like RecogType.OCR, RecogType.MRZ, RecogType.PDF417, RecogType.DL_PLATE, RecogType.BANKCARD
        // initialized camera
    }

    private void initCamera() {
        frameLayout = new FrameLayout(mContext);
        cameraView = new CameraView(mActivity);
    }

    /**
     * To handle camera on window focus update
     *
     * @param hasFocus
     */
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        if (cameraView != null) {
            cameraView.onWindowFocusUpdate(hasFocus);
        }
    }

    @Override
    protected void onResume() {
        if (cameraView != null) {
            cameraView.onResume();
        }
        super.onResume();
    }

    @Override
    protected void onPause() {
        cameraView.onPause();
        super.onPause();
    }

    /**
     * To update your border frame according to width and height
     * it's different for different card
     * Call {@link CameraView#startOcrScan(boolean isReset)} To start Camera Preview
     *
     * @param width  border layout width
     * @param height border layout height
     */
    @Override
    public void onUpdateLayout(int width, int height) {
        isBack = false;
        if (CardSide != null) {
            if (CardSide.equalsIgnoreCase("1") || CardSide.equalsIgnoreCase("2")) {
                if (dummy_recogType.equalsIgnoreCase("1")) {
                    cameraView.setFrontSide();
                } else {
                    isCardSideFront = true;
                }

            } else if (CardSide.equalsIgnoreCase("0") || CardSide.equalsIgnoreCase("3")) {
                if (dummy_recogType.equalsIgnoreCase("1")) {
                    cameraView.setBackSide();
                } else if (dummy_recogType.equalsIgnoreCase("0")) {
                    if (isCardSideFront) {
                        cameraView.setFrontSide();
                    } else {
                        if (cameraView.isBackSideAvailable()) {
                            cameraView.setBackSide();
                        }
                    }
                } else {
                    isCardSideFront = false;
                }
            }
        }

        if (cameraView != null) cameraView.startOcrScan(false);
        Map<String, String> map = new HashMap<>();
        double density = mContext.getResources().getDisplayMetrics().density;
        map.put("Height", String.valueOf(height / mContext.getResources().getDisplayMetrics().density));
        map.put("Width", String.valueOf(width / mContext.getResources().getDisplayMetrics().density));
        ArrayList<Map<String, String>> list = new ArrayList<>();
        list.add(map);
        message_Channel_layout_width_hight.send(list);

        //<editor-fold desc="To set camera overlay Frame and make sure frame is in center of your camera screen.">
    /*    ViewGroup.LayoutParams layoutParams = borderFrame.getLayoutParams();
        layoutParams.width = width;
        layoutParams.height = height;
        borderFrame.setLayoutParams(layoutParams);

        ViewGroup.LayoutParams lpRight = viewRight.getLayoutParams();
        lpRight.height = height;
        viewRight.setLayoutParams(lpRight);

        ViewGroup.LayoutParams lpLeft = viewLeft.getLayoutParams();
        lpLeft.height = height;
        viewLeft.setLayoutParams(lpLeft);*/
        //</editor-fold>
    }

    /**
     * Override this method after scan complete to get data from document
     *
     * @param result is scanned card data
     *               result instance of {@link OcrData} if recog type is {@link com.docrecog.scan.RecogType#OCR}
     *               or {@link com.docrecog.scan.RecogType#DL_PLATE} or {@link com.docrecog.scan.RecogType#BARCODE}
     *               result instance of {@link RecogResult} if recog type is {@link com.docrecog.scan.RecogType#MRZ}
     *               result instance of {@link CardDetails} if recog type is {@link com.docrecog.scan.RecogType#BANKCARD}
     *               result instance of {@link PDF417Data} if recog type is {@link com.docrecog.scan.RecogType#PDF417}
     */

    @Override
    public void onScannedComplete(Object result) {

        // display data on ui thread

        if (result != null) {
            scanSound_channel.send("Play");
            // make sure release camera view before open result screen
            // if (cameraView != null) cameraView.release(true);
            // Do some code for display data
            Log.e("result.toString()r", "onScannedComplete: " + result.toString());
            if (result instanceof OcrData) {

                if (recogType == RecogType.OCR) {
                    List<Map<String, String>> dataList = new ArrayList<>();
                    // @recogType is {@see com.docrecog.scan.RecogType#OCR}
                    if (!TextUtils.isEmpty(CardSide)) {
                        if (CardSide.equalsIgnoreCase("0") || CardSide.equalsIgnoreCase("1")) {
                            OcrData.setOcrResult((OcrData) result);
                            setOcrData((OcrData) result);
                        } else {
                            if (isBack || !cameraView.isBackSideAvailable()) { // To check card has back side or not
                                OcrData.setOcrResult((OcrData) result);
                                setOcrData((OcrData) result);
                            } else {
                                if (CardSide.equalsIgnoreCase("2")) {
                                    isBack = true;
                                    cameraView.setBackSide();
                                } else if (CardSide.equalsIgnoreCase("3")) {
                                    isBack = true;
                                    cameraView.setFrontSide();
                                }
                            }
                        }
                    } else {
                        if (isBack || !cameraView.isBackSideAvailable()) { // To check card has back side or not
                            OcrData.setOcrResult((OcrData) result);
                            setOcrData((OcrData) result);
                        } else {
                            isBack = true;
                            cameraView.setBackSide();
                        }
                    }


                } else if (recogType == RecogType.DL_PLATE || recogType == RecogType.BARCODE) {
                    // @recogType is {@link RecogType#DL_PLATE} or recogType == {@link RecogType#BARCODE}

                    OcrData.setOcrResult((OcrData) result);
                    setOcrData((OcrData) result);

                    // Set data To retrieve it anywhere

                }
            } else if (result instanceof RecogResult) {
                // @recogType is {@see com.docrecog.scan.RecogType#MRZ}
                RecogResult.setRecogResult((RecogResult) result);
                JSONArray main_OCR_Array = new JSONArray();
                JSONObject mainObject = new JSONObject();
                try {
                    mainObject.put("MRZ_Data", setMrzData((RecogResult) result));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (((RecogResult) result).docFrontBitmap != null) {
                    try {
                        mainObject.put("front_Image", getImageByte(((RecogResult) result).docFrontBitmap));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                if (((RecogResult) result).docBackBitmap != null) {
                    try {
                        mainObject.put("back_Image", getImageByte(((RecogResult) result).docBackBitmap));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                if (((RecogResult) result).faceBitmap != null) {
                    try {
                        mainObject.put("Face_Image", getImageByte(((RecogResult) result).faceBitmap));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                main_OCR_Array.put(mainObject);
                JSONObject object = new JSONObject();
                try {
                    object.put("ocr_data", main_OCR_Array);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                Log.e("SCANNEDJSONIS", "onScannedComplete: " + object);

                HashMap<String, String> prodHashMap = new HashMap<String, String>();
                prodHashMap.put("ocr_data", object.toString());
                list.add(prodHashMap);
                message_Channel.send(list);



            } else if (result instanceof CardDetails) {
                //  @recogType is {@see com.docrecog.scan.RecogType#BANKCARD}
                CardDetails.setCardDetails((CardDetails) result);// Set data To retrieve it anywhere
                setBanckCardData((CardDetails) result);

            } else if (result instanceof PDF417Data) {
                //  @recogType is {@see com.docrecog.scan.RecogType#PDF417}


                if (!TextUtils.isEmpty(CardSide)) {
                    if (CardSide.equalsIgnoreCase("0") || CardSide.equalsIgnoreCase("1")) {
                        PDF417Data.setPDF417Result((PDF417Data) result);
                        setPDF417Data((PDF417Data) result);
                    } else {
                        if (isBack || !cameraView.isBackSideAvailable()) { // To check card has back side or not
                            PDF417Data.setPDF417Result((PDF417Data) result);
                            setPDF417Data((PDF417Data) result);
                        } else {
                            if (CardSide.equalsIgnoreCase("2")) {
                                isBack = true;
                                cameraView.setBackSide();
                            } else if (CardSide.equalsIgnoreCase("3")) {
                                isBack = true;
                                cameraView.setFrontSide();
                            }
                        }
                    }
                } else {
                    if (isBack || !cameraView.isBackSideAvailable()) { // To check card has back side or not
                        PDF417Data.setPDF417Result((PDF417Data) result);
                        setPDF417Data((PDF417Data) result);
                    } else {
                        isBack = true;
                        cameraView.setBackSide();
                    }
                }

             /*   if (isBack || !cameraView.isBackSideAvailable()) {
                    PDF417Data.setPDF417Result((PDF417Data) result);
                    setPDF417Data((PDF417Data) result);
                    // Set data To retrieve it anywhere
                    *//*  sendDataToResultActivity(RecogType.PDF417);*//*
                } else {
                    isBack = true;
                    cameraView.setBackSide(); // To recognize data from back side too.
                    *//*     cameraView.flipImage(imageFlip);*//*
                }*/
            }
        } else Toast.makeText(this, "Failed", Toast.LENGTH_SHORT).show();
    }

    private void setBanckCardData(CardDetails result) {
        JSONObject mrzObject = new JSONObject();
        JSONArray mrzArray = new JSONArray();
        JSONArray main_OCR_Array = new JSONArray();
        JSONObject mainObject = new JSONObject();
        try {
            if (!TextUtils.isEmpty(result.getCardType())) {
                mrzObject = new JSONObject();
                mrzObject.put("Bank_key", "Card Type");
                mrzObject.put("Bank_data", result.getCardType());
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(result.getNumber())) {
                mrzObject = new JSONObject();
                mrzObject.put("Bank_key", "Number");
                mrzObject.put("Bank_data", result.getNumber());
                mrzArray.put(mrzObject);
            }

            if (!TextUtils.isEmpty(result.getExpirationMonth())) {
                mrzObject = new JSONObject();
                mrzObject.put("Bank_key", "Expiration Month");
                mrzObject.put("Bank_data", result.getExpirationMonth());
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(result.getExpirationYear())) {
                mrzObject = new JSONObject();
                mrzObject.put("Bank_key", "Expiration Year");
                mrzObject.put("Bank_data", result.getExpirationYear());
                mrzArray.put(mrzObject);
            }

            if (!TextUtils.isEmpty(result.getOwner())) {
                mrzObject = new JSONObject();
                mrzObject.put("Bank_key", "Owner");
                mrzObject.put("Bank_data", result.getOwner());
                mrzArray.put(mrzObject);
            }

            mainObject.put("bank_Data", mrzArray);
            if (result.getBitmap() != null) {
                mainObject.put("front_Image", getImageByte(result.getBitmap()));
            }

            main_OCR_Array.put(mainObject);
            JSONObject object = new JSONObject();
            object.put("ocr_data", main_OCR_Array);
            Log.e("SCANNEDJSONIS", "onScannedComplete: " + object);
            list = new ArrayList<>();
            HashMap<String, String> prodHashMap = new HashMap<String, String>();
            prodHashMap.put("ocr_data", object.toString());
            list.add(prodHashMap);

            message_Channel.send(list);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void setPDF417Data(PDF417Data result) {

        JSONArray mrzArray = new JSONArray();
        JSONArray main_OCR_Array = new JSONArray();
        JSONObject mainObject = new JSONObject();

        try {
            JSONArray Scanned_Front_data_Array = new JSONArray();


            JSONObject front_Object = new JSONObject();
            try {
                if (result.fullName != null && result.fullName != "") {
                    front_Object.put("PDF417_key", "fullName");
                    front_Object.put("PDF417_keydata", result.fullName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.lastName != null && result.lastName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "lastName");
                    front_Object.put("PDF417_keydata", result.lastName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.firstName != null && result.firstName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "firstName");
                    front_Object.put("PDF417_keydata", result.firstName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.middleName != null && result.middleName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "middleName");
                    front_Object.put("PDF417_keydata", result.middleName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.nameSuffix != null && result.nameSuffix != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "nameSuffix");
                    front_Object.put("PDF417_keydata", result.nameSuffix);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.namePrefix != null && result.namePrefix != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "namePrefix");
                    front_Object.put("PDF417_keydata", result.namePrefix);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.address1 != null && result.address1 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MAILING STREET ADDRESS1");
                    front_Object.put("PDF417_keydata", result.address1);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.address2 != null && result.address2 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MAILING STREET ADDRESS2");
                    front_Object.put("PDF417_keydata", result.address2);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.city != null && result.city != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MAILING CITY");
                    front_Object.put("PDF417_keydata", result.city);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.jurisdiction != null && result.jurisdiction != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MAILING JURISDICTION CODE");
                    front_Object.put("PDF417_keydata", result.jurisdiction);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.zipcode != null && result.zipcode != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MAILING POSTAL CODE");
                    front_Object.put("PDF417_keydata", result.zipcode);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.ResidenceAddress2 != null && result.ResidenceAddress2 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RESIDENCE STREET ADDRESS1");
                    front_Object.put("PDF417_keydata", result.ResidenceAddress2);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.ResidenceAddress1 != null && result.ResidenceAddress1 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RESIDENCE STREET ADDRESS2");
                    front_Object.put("PDF417_keydata", result.ResidenceAddress1);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.ResidenceCity != null && result.ResidenceCity != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RESIDENCE CITY");
                    front_Object.put("PDF417_keydata", result.ResidenceCity);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.ResidenceJurisdictionCode != null && result.ResidenceJurisdictionCode != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RESIDENCE JURISDICTION CODE");
                    front_Object.put("PDF417_keydata", result.ResidenceJurisdictionCode);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.ResidencePostalCode != null && result.ResidencePostalCode != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RESIDENCE POSTAL CODE");
                    front_Object.put("PDF417_keydata", result.ResidenceJurisdictionCode);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.licence_number != null && result.licence_number != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENCE OR ID NUMBER");
                    front_Object.put("PDF417_keydata", result.licence_number);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.licenseClassification != null && result.licenseClassification != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENCE CLASSIFICATION CODE");
                    front_Object.put("PDF417_keydata", result.licenseClassification);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.licenseRestriction != null && result.licenseRestriction != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENCE RESTRICTION CODE");
                    front_Object.put("PDF417_keydata", result.licenseClassification);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.licenseEndorsement != null && result.licenseEndorsement != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENCE ENDORSEMENT CODE");
                    front_Object.put("PDF417_keydata", result.licenseEndorsement);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.heightinFT != null && result.heightinFT != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "HEIGHT IN FT_IN");
                    front_Object.put("PDF417_keydata", result.heightinFT);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.heightCM != null && result.heightCM != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "HEIGHT IN CM");
                    front_Object.put("PDF417_keydata", result.heightCM);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.weightLBS != null && result.weightLBS != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "WEIGHT IN LBS");
                    front_Object.put("PDF417_keydata", result.weightLBS);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.heightCM != null && result.heightCM != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "heightCM");
                    front_Object.put("PDF417_keydata", result.heightCM);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.weightKG != null && result.weightKG != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "WEIGHT IN KG");
                    front_Object.put("PDF417_keydata", result.weightKG);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.eyeColor != null && result.eyeColor != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "EYE COLOR");
                    front_Object.put("PDF417_keydata", result.weightKG);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.hairColor != null && result.hairColor != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "HAIR COLOR");
                    front_Object.put("PDF417_keydata", result.hairColor);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.licence_expire_date != null && result.licence_expire_date != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENSE EXPIRATION DATE");
                    front_Object.put("PDF417_keydata", result.licence_expire_date);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.birthday != null && result.birthday != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "DATE OF BIRTH");
                    front_Object.put("PDF417_keydata", result.birthday);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.sex != null && result.sex != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "SEX");
                    front_Object.put("PDF417_keydata", result.sex);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.issueDate != null && result.issueDate != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LICENSE OR ID DOCUMENT ISSUE DATE");
                    front_Object.put("PDF417_keydata", result.issueDate);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.issueTime != null && result.issueTime != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "ISSUE TIMESTAMP");
                    front_Object.put("PDF417_keydata", result.issueTime);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.numberDuplicate != null && result.numberDuplicate != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "NUMBER OF DUPLICATES");
                    front_Object.put("PDF417_keydata", result.numberDuplicate);
                    Scanned_Front_data_Array.put(front_Object);
                }


                if (result.MedicalIndicatorCodes != null && result.MedicalIndicatorCodes != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MEDICAL INDICATOR CODES");
                    front_Object.put("PDF417_keydata", result.MedicalIndicatorCodes);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.organDonor != null && result.organDonor != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "ORGAN DONOR");
                    front_Object.put("PDF417_keydata", result.organDonor);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.NonResidentIndicator != null && result.NonResidentIndicator != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "NON-RESIDENT INDICATOR");
                    front_Object.put("PDF417_keydata", result.NonResidentIndicator);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.uniqueCustomerId != null && result.uniqueCustomerId != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "UNIQUE CUSTOMER IDENTIFIER");
                    front_Object.put("PDF417_keydata", result.uniqueCustomerId);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.socialSecurityNo != null && result.socialSecurityNo != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "SOCIAL SECURITY NUMBER");
                    front_Object.put("PDF417_keydata", result.socialSecurityNo);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.birthday1 != null && result.birthday1 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "DATE OF BIRTH");
                    front_Object.put("PDF417_keydata", result.birthday1);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.socialSecurityNo != null && result.socialSecurityNo != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "SOCIAL SECURITY NUMBER");
                    front_Object.put("PDF417_keydata", result.socialSecurityNo);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.fullName != null && result.fullName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "FULL NAM");
                    front_Object.put("PDF417_keydata", result.fullName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.lastName != null && result.lastName != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LAST NAME");
                    front_Object.put("PDF417_keydata", result.lastName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.firstName != null && result.firstName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "FIRST NAME");
                    front_Object.put("PDF417_keydata", result.firstName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.middleName != null && result.middleName != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MIDDLE NAME");
                    front_Object.put("PDF417_keydata", result.middleName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.Suffix != null && result.Suffix != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "SUFFIX");
                    front_Object.put("PDF417_keydata", result.Suffix);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.Prefix != null && result.Prefix != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PREFIX");
                    front_Object.put("PDF417_keydata", result.Prefix);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.VirginiaSpecificClass != null && result.VirginiaSpecificClass != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "VIRGINIA SPECIFIC CLASS");
                    front_Object.put("PDF417_keydata", result.VirginiaSpecificClass);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.VirginiaSpecificRestrictions != null && result.VirginiaSpecificRestrictions != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "VIRGINIA SPECIFIC RESTRICTIONS");
                    front_Object.put("PDF417_keydata", result.VirginiaSpecificRestrictions);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.VirginiaSpecificEndorsements != null && result.VirginiaSpecificEndorsements != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "VIRGINIA SPECIFIC ENDORSEMENTS");
                    front_Object.put("PDF417_keydata", result.VirginiaSpecificEndorsements);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.PhysicalDescriptionWeight != null && result.PhysicalDescriptionWeight != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PHYSICAL DESCRIPTION WEIGHT RANGE");
                    front_Object.put("PDF417_keydata", result.PhysicalDescriptionWeight);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.documentDiscriminator != null && result.documentDiscriminator != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "DOCUMENT DISCRIMINATOR");
                    front_Object.put("PDF417_keydata", result.documentDiscriminator);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.documentDiscriminator != null && result.documentDiscriminator != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "COUNTRY TERRITORY OF ISSUANCE");
                    front_Object.put("PDF417_keydata", result.CountryTerritoryOfIssuance);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.FederalCommercialVehicleCodes != null && result.FederalCommercialVehicleCodes != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "FEDERAL COMMERCIAL VEHICLE CODES");
                    front_Object.put("PDF417_keydata", result.FederalCommercialVehicleCodes);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.PlaceOfBirth != null && result.PlaceOfBirth != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PLACE OF BIRTH");
                    front_Object.put("PDF417_keydata", result.PlaceOfBirth);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.AuditInformation != null && result.AuditInformation != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "AUDIT INFORMATION");
                    front_Object.put("PDF417_keydata", result.AuditInformation);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.inventoryNo != null && result.inventoryNo != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "INVENTORY CONTROL NUMBER");
                    front_Object.put("PDF417_keydata", result.inventoryNo);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.raceEthnicity != null && result.raceEthnicity != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "RACE ETHNICITY");
                    front_Object.put("PDF417_keydata", result.raceEthnicity);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.standardVehicleClass != null && result.standardVehicleClass != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "STANDARD VEHICLE CLASSIFICATION");
                    front_Object.put("PDF417_keydata", result.standardVehicleClass);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.StandardEndorsementCode != null && result.StandardEndorsementCode != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "STANDARD ENDORSEMENT CODE");
                    front_Object.put("PDF417_keydata", result.StandardEndorsementCode);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.StandardRestrictionCode != null && result.StandardRestrictionCode != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "STANDARD RESTRICTION CODE");
                    front_Object.put("PDF417_keydata", result.StandardRestrictionCode);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.jurisdiction != null && result.jurisdiction != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION");
                    front_Object.put("PDF417_keydata", result.jurisdiction);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.JurisdictionSpecific != null && result.JurisdictionSpecific != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "JURISDICTION-SPECIFIC");
                    front_Object.put("PDF417_keydata", result.JurisdictionSpecific);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.JuriSpeciRestriCodeDescri != null && result.JuriSpeciRestriCodeDescri != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "JJURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION");
                    front_Object.put("PDF417_keydata", result.JuriSpeciRestriCodeDescri);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.FamilyNameTruncation != null && result.FamilyNameTruncation != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "FAMILY NAME");
                    front_Object.put("PDF417_keydata", result.FamilyNameTruncation);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.givenName != null && result.givenName != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "GIVEN NAME");
                    front_Object.put("PDF417_keydata", result.givenName);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.Suffix != null && result.Suffix != "") {

                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "SUFFIX");
                    front_Object.put("PDF417_keydata", result.Suffix);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.ComplianceType != null && result.ComplianceType != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "COMPLIANCE TYPE");
                    front_Object.put("PDF417_keydata", result.ComplianceType);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.CardRevisionDate != null && result.CardRevisionDate != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "CARD REVISION DATE");
                    front_Object.put("PDF417_keydata", result.CardRevisionDate);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.HazMatEndorsementExpiryDate != null && result.HazMatEndorsementExpiryDate != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "HAZMAT ENDORSEMENT EXPIRY DATE");
                    front_Object.put("PDF417_keydata", result.HazMatEndorsementExpiryDate);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.LimitedDurationDocumentIndicator != null && result.LimitedDurationDocumentIndicator != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "LIMITED DURATION DOCUMENT INDICATOR");
                    front_Object.put("PDF417_keydata", result.LimitedDurationDocumentIndicator);
                    Scanned_Front_data_Array.put(front_Object);

                }
                if (result.FamilyNameTruncation != null && result.FamilyNameTruncation != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "FAMILY NAMES TRUNCATION");
                    front_Object.put("PDF417_keydata", result.FamilyNameTruncation);
                    Scanned_Front_data_Array.put(front_Object);

                }

                if (result.MiddleNamesTruncation != null && result.MiddleNamesTruncation != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "MIDDLE NAMES TRUNCATION");
                    front_Object.put("PDF417_keydata", result.MiddleNamesTruncation);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.under18 != null && result.under18 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "UNDER 18 UNTIL");
                    front_Object.put("PDF417_keydata", result.under18);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.under19 != null && result.under19 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "UNDER 19 UNTIL");
                    front_Object.put("PDF417_keydata", result.under19);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.under21 != null && result.under21 != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "UNDER 21 UNTIL");
                    front_Object.put("PDF417_keydata", result.under21);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.OrganDonorIndicator != null && result.OrganDonorIndicator != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "ORGAN DONOR INDICATOR");
                    front_Object.put("PDF417_keydata", result.OrganDonorIndicator);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.veteranIndicator != null && result.veteranIndicator != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "VETERAN INDICATOR");
                    front_Object.put("PDF417_keydata", result.veteranIndicator);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.permitClassification != null && result.permitClassification != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT CLASSIFICATION CODE");
                    front_Object.put("PDF417_keydata", result.permitClassification);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.permitExpire != null && result.permitExpire != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT EXPIRATION DATE");
                    front_Object.put("PDF417_keydata", result.permitExpire);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.PermitIdentifier != null && result.PermitIdentifier != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT IDENTIFIER");
                    front_Object.put("PDF417_keydata", result.PermitIdentifier);
                    Scanned_Front_data_Array.put(front_Object);
                }

                if (result.permitIssue != null && result.permitIssue != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT ISSUE DATE");
                    front_Object.put("PDF417_keydata", result.permitIssue);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.permitRestriction != null && result.permitRestriction != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT RESTRICTION CODE");
                    front_Object.put("PDF417_keydata", result.permitRestriction);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.permitEndorsement != null && result.permitEndorsement != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "PERMIT ENDORSEMENT CODE");
                    front_Object.put("PDF417_keydata", result.permitEndorsement);
                    Scanned_Front_data_Array.put(front_Object);
                }
                if (result.courtRestriction != null && result.courtRestriction != "") {
                    front_Object = new JSONObject();
                    front_Object.put("PDF417_key", "COURT RESTRICTION CODE");
                    front_Object.put("PDF417_keydata", result.courtRestriction);
                    Scanned_Front_data_Array.put(front_Object);
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }


            try {
                mainObject.put("pdf417_data", Scanned_Front_data_Array);
                if (result.docFrontBitmap != null) {
                    mainObject.put("front_Image", getImageByte(result.docFrontBitmap));
                }
                if (result.docBackBitmap != null) {
                    mainObject.put("back_Image", getImageByte(result.docBackBitmap));
                }
                if (result.faceBitmap != null) {
                    mainObject.put("Face_Image", getImageByte(result.faceBitmap));
                }
            } catch (JSONException e) {
                e.printStackTrace();
                Log.e("ScanJsonError", "front_dataonScannedComplete: " + e);
            }
            main_OCR_Array.put(mainObject);
            JSONObject object = new JSONObject();
            object.put("ocr_data", main_OCR_Array);
            Log.e("SCANNEDJSONIS", "onScannedComplete: " + object);
            list = new ArrayList<>();
            HashMap<String, String> prodHashMap = new HashMap<String, String>();
            prodHashMap.put("ocr_data", object.toString());
            list.add(prodHashMap);
            message_Channel.send(list);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private JSONArray setMrzData(RecogResult recogResult) {
        list = new ArrayList<>();
        JSONObject mrzObject = new JSONObject();
        JSONArray mrzArray = new JSONArray();
        ArrayList<RecogResult> list = new ArrayList<>();
        list.add(recogResult);

        try {
            if (!TextUtils.isEmpty(recogResult.lines)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "MRZ");
                mrzObject.put("MRZ_data", recogResult.lines);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.docType)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Document Type");
                mrzObject.put("MRZ_data", recogResult.docType);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.givenname)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "First Name");
                mrzObject.put("MRZ_data", recogResult.givenname);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.surname)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Last Name");
                mrzObject.put("MRZ_data", recogResult.surname);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.docnumber)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Document No.");
                mrzObject.put("MRZ_data", recogResult.docnumber);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.docchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Document check No.");
                mrzObject.put("MRZ_data", recogResult.docchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.correctdocchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Correct Document check No.");
                mrzObject.put("MRZ_data", recogResult.correctdocchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.country)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Country");
                mrzObject.put("MRZ_data", recogResult.country);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.nationality)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Nationality");
                mrzObject.put("MRZ_data", recogResult.nationality);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.sex)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Sex");
                mrzObject.put("MRZ_data", (recogResult.sex.equals("M")) ? "Male" : ((recogResult.sex.equals("F")) ? "Female" : recogResult.sex));
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.birth)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Date of Birth");
                mrzObject.put("MRZ_data", recogResult.birth);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.birthchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Birth Check No.");
                mrzObject.put("MRZ_data", recogResult.birthchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.correctbirthchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Correct Birth Check No.");
                mrzObject.put("MRZ_data", recogResult.correctbirthchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.expirationdate)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Date of Expiry");
                mrzObject.put("MRZ_data", recogResult.expirationdate);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.expirationchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Expiration Check No.");
                mrzObject.put("MRZ_data", recogResult.expirationchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.correctexpirationchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Correct Expiration Check No.");
                mrzObject.put("MRZ_data", recogResult.correctexpirationchecksum);
                mrzArray.put(mrzObject);
            }

            if (!TextUtils.isEmpty(recogResult.otherid)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Other ID");
                mrzObject.put("MRZ_data", recogResult.otherid);
                mrzArray.put(mrzObject);
            }

            if (!TextUtils.isEmpty(recogResult.otheridchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Other ID Check");
                mrzObject.put("MRZ_data", recogResult.otheridchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.otherid2)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Other ID2");
                mrzObject.put("MRZ_data", recogResult.otherid2);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.secondrowchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Second Row Check No.");
                mrzObject.put("MRZ_data", recogResult.secondrowchecksum);
                mrzArray.put(mrzObject);
            }

            if (!TextUtils.isEmpty(recogResult.correctsecondrowchecksum)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Correct Second Row Check No.");
                mrzObject.put("MRZ_data", recogResult.correctsecondrowchecksum);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.issuedate)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Date Of Issue");
                mrzObject.put("MRZ_data", recogResult.issuedate);
                mrzArray.put(mrzObject);
            }
            if (!TextUtils.isEmpty(recogResult.departmentnumber)) {
                mrzObject = new JSONObject();
                mrzObject.put("MRZ_key", "Department No.");
                mrzObject.put("MRZ_data", recogResult.departmentnumber);
                mrzArray.put(mrzObject);
            }


        } catch (JSONException e) {
            e.printStackTrace();
        }
        return mrzArray;

    }

    private void setOcrData(OcrData ocrData) {
        OcrData.MapData frontData = OcrData.getOcrResult().getFrontData();
        OcrData.MapData backData = OcrData.getOcrResult().getBackData();
        JSONArray main_OCR_Array = new JSONArray();
        JSONObject mainObject = new JSONObject();
        try {
            mainObject.put("card_Name", OcrData.getOcrResult());

            if (ocrData.getFaceImage() != null) {
                mainObject.put("Face_Image", getImageByte(OcrData.getOcrResult().getFaceImage()));
            }
            if (ocrData.getBackimage() != null) {
                mainObject.put("back_Image", getImageByte(OcrData.getOcrResult().getBackimage()));
            }
            if (ocrData.getFrontimage() != null) {
                mainObject.put("front_Image", getImageByte(OcrData.getOcrResult().getFrontimage()));
            }

            mainObject.put("recog_type", RecogType.OCR);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (OcrData.getOcrResult().getFrontData() != null) {
            JSONArray Scanned_Front_data_Array = new JSONArray();
            JSONArray mrzArray = new JSONArray();
            for (int i = 0; i < OcrData.getOcrResult().getFrontData().getOcr_data().size(); i++) {

                final OcrData.MapData.ScannedData scannedData = frontData.getOcr_data().get(i);
                if (scannedData != null) {
                    JSONObject front_Object = new JSONObject();

                    try {
                        front_Object.put("scanned_type", scannedData.getType());
                        front_Object.put("front_key", scannedData.getKey());
                        front_Object.put("front_keydata", scannedData.getKey_data());

                        if (scannedData.getType() == 1) {
                            JSONObject mrzObject = new JSONObject();
                            if (scannedData.getKey().toLowerCase().contains("mrz")) {

                                RecogResult recogResult = OcrData.getOcrResult().getMrzData();
                                mainObject.put("MRZ_Data", setMrzData((RecogResult) recogResult));
                            }
                        } else if (scannedData.getType() == 2) {

                        } else if (scannedData.getType() == 3) {

                            front_Object.put("Security", "yes");
                        }
                        Scanned_Front_data_Array.put(front_Object);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }
            }
            try {
                mainObject.put("front_data", Scanned_Front_data_Array);
            } catch (JSONException e) {
                e.printStackTrace();
                Log.e("ScanJsonError", "front_dataonScannedComplete: " + e);
            }
        }
        if (OcrData.getOcrResult().getBackData() != null) {
            JSONArray Scanned_Back_data_Array = new JSONArray();
            JSONArray mrzArray = new JSONArray();
            for (int i = 0; i < OcrData.getOcrResult().getBackData().getOcr_data().size(); i++) {
                final OcrData.MapData.ScannedData scannedData = backData.getOcr_data().get(i);

                if (scannedData != null) {
                    JSONObject back_Object = new JSONObject();

                    try {
                        back_Object.put("scanned_type", scannedData.getType());
                        back_Object.put("back_key", scannedData.getKey());
                        back_Object.put("back_keydata", scannedData.getKey_data());
                        if (scannedData.getType() == 1) {

                            JSONObject mrzObject = new JSONObject();
                            if (scannedData.getKey().toLowerCase().contains("mrz")) {
                                RecogResult recogResult = OcrData.getOcrResult().getMrzData();

                                mainObject.put("MRZ_Data", setMrzData((RecogResult) recogResult));
                            }
                        } else if (scannedData.getType() == 2) {
                            try {
                                if (scannedData.getKey().toLowerCase().contains("face")) {
                                    //                                    if (face1 == null) {
                                    //                                        face1 = scannedData.getImage();
                                    //                                    }
                                } else {

                                    if (scannedData.getImage() != null) {
                                        back_Object.put("Scanned_front_Image", getImageByte(scannedData.getImage()));

                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        } else if (scannedData.getType() == 3) {

                            back_Object.put("Security", "yes");
                        }
                        Scanned_Back_data_Array.put(back_Object);

                    } catch (JSONException e) {
                        e.printStackTrace();
                        Log.e("ScanJsonError", "back_ObjectonScannedComplete: " + e);
                    }

                }

            }
            try {
                mainObject.put("back_data", Scanned_Back_data_Array);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        try {
            main_OCR_Array.put(mainObject);
            JSONObject object = new JSONObject();
            object.put("ocr_data", main_OCR_Array);
            Log.e("SCANNEDJSONIS", "onScannedComplete: " + object);
            list = new ArrayList<>();
            HashMap<String, String> prodHashMap = new HashMap<String, String>();
            prodHashMap.put("ocr_data", object.toString());
            list.add(prodHashMap);
            message_Channel.send(list);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private String getImageByte(Bitmap myBitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        byte[] b = baos.toByteArray();
        String imageEncoded = Base64.encodeToString(b, Base64.NO_WRAP);
        Log.e("base64Image", "getImageByte: " + imageEncoded);
        return imageEncoded;
    }

    /**
     * @param titleCode    to display scan card message on top of border Frame
     * @param errorMessage To display process message.
     *                     null if message is not available
     * @param isFlip       true to set your customize animation for scan back card alert after complete front scan
     *                     and also used cameraView.flipImage(ImageView) for default animation
     */
    @Override
    public void onProcessUpdate(int titleCodetitleCode, String errorMessage, boolean isFlip) {
        // Add UI thread to update UI elements
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (getTitleMessage(titleCodetitleCode) != null) { // check
                    /* Toast.makeText(mContext, getTitleMessage(titleCodetitleCode), Toast.LENGTH_SHORT).show(); // display title*/
                    list = new ArrayList<>();
                    HashMap<String, String> prodHashMap = new HashMap<String, String>();
                    prodHashMap.put("titleMessage", String.valueOf(titleCodetitleCode));
                    list.add(prodHashMap);
                    message_Channel.send(list);

                }
                if (errorMessage != null) {
                    /*Toast.makeText(mContext, getErrorMessage(errorMessage), Toast.LENGTH_SHORT).show(); // display message*/
                    list = new ArrayList<>();
                    HashMap<String, String> errorhashmap = new HashMap<String, String>();
                    errorhashmap.put("errorMessage", errorMessage);
                    list.add(errorhashmap);
                    message_Channel.send(list);
                }
                if (isFlip) {
                    // To set default animation or remove this line to set your custom animation after successfully scan front side.
                    /* CameraView.(imageView);*/


                }
            }
        });
    }

    @Override
    public void onError(String errorMessage) {
        // display data on ui thread
        // stop ocr if failed
        Toast.makeText(mContext, errorMessage, Toast.LENGTH_SHORT).show();
    }

    private String getTitleMessage(int titleCode) {
        if (titleCode < 0) return null;
        switch (titleCode) {
            case RecogEngine.SCAN_TITLE_OCR_FRONT:// for front side ocr;
                return String.format("Scan Front Side of %s");
            case RecogEngine.SCAN_TITLE_OCR_BACK: // for back side ocr
                return String.format("Scan Back Side of %s");
            case RecogEngine.SCAN_TITLE_OCR: // only for single side ocr
                return String.format("Scan s");
            case RecogEngine.SCAN_TITLE_MRZ_PDF417_FRONT:// for front side MRZ, PDF417 and BankCard
                if (recogType == RecogType.BANKCARD) {
                    return "Scan Bank Card";
                } else if (recogType == RecogType.BARCODE) {
                    return "Scan Barcode";
                } else
                    return "Scan Front Side of Document";
            case RecogEngine.SCAN_TITLE_MRZ_PDF417_BACK: // for back side MRZ and PDF417
                return "Now Scan Back Side of Document";
            case RecogEngine.SCAN_TITLE_DLPLATE: // for DL plate
                return "Scan Number Plate";
            default:
                return "";
        }
    }

 /*   private String getErrorMessage(String s) {
        switch (s) {
            case RecogEngine.ACCURA_ERROR_CODE_MOTION:
                return "Keep Document Steady";
            case RecogEngine.ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME:
                return "Keep document in frame";
            case RecogEngine.ACCURA_ERROR_CODE_BRING_DOCUMENT_IN_FRAME:
                return "Bring card near to frame.";
            case RecogEngine.ACCURA_ERROR_CODE_PROCESSING:
                return "Processing...";
            case RecogEngine.ACCURA_ERROR_CODE_BLUR_DOCUMENT:
                return "Blur detect in document";
            case RecogEngine.ACCURA_ERROR_CODE_FACE_BLUR:
                return "Blur detected over face";
            case RecogEngine.ACCURA_ERROR_CODE_GLARE_DOCUMENT:
                return "Glare detect in document";
            case RecogEngine.ACCURA_ERROR_CODE_HOLOGRAM:
                return "Hologram Detected";
            case RecogEngine.ACCURA_ERROR_CODE_DARK_DOCUMENT:
                return "Low lighting detected";
            case RecogEngine.ACCURA_ERROR_CODE_PHOTO_COPY_DOCUMENT:
                return "Can not accept Photo Copy Document";
            case RecogEngine.ACCURA_ERROR_CODE_FACE:
                return "Face not detected";
            case RecogEngine.ACCURA_ERROR_CODE_MRZ:
                return "MRZ not detected";
            case RecogEngine.ACCURA_ERROR_CODE_PASSPORT_MRZ:
                return "Passport MRZ not detected";
            case RecogEngine.ACCURA_ERROR_CODE_ID_MRZ:
                return "ID card MRZ not detected";
            case RecogEngine.ACCURA_ERROR_CODE_VISA_MRZ:
                return "Visa MRZ not detected";
            case RecogEngine.ACCURA_ERROR_CODE_WRONG_SIDE:
                return "Scanning wrong side of document";
            case RecogEngine.ACCURA_ERROR_CODE_UPSIDE_DOWN_SIDE:
                return "Document is upside down. Place it properly";
            default:
                return s;
        }
    }*/

    // After getting result to restart scanning you have to set below code onActivityResult
// when you use startActivityForResult(Intent, RESULT_ACTIVITY_CODE) to open result activity.
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        if (resultCode == RESULT_OK) {
            if (requestCode == RESULT_ACTIVITY_CODE) {
                //<editor-fold desc="Call CameraView#startOcrScan(true) to scan document again">

                if (cameraView != null) cameraView.startOcrScan(true);

                //</editor-fold>
            }
        }
    }

    @Override
    public View getView() {
        return frameLayout;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(@NonNull @NotNull MethodCall call, @NonNull @NotNull MethodChannel.Result result) {
        switch (call.method) {
            case "scan#startCamera":
                dummy_recogType = call.argument("recogType");
                dummy_card_id = call.argument("card_id");
                dummy_country_id = call.argument("country_id");
                dummy_mrzDocumentType = call.argument("mrzDocumentType");
                cameraView = new CameraView(mActivity);
                setupCameraView();
                break;
            case "scan#activitydoOnResume":
                if(cameraView!=null)
                cameraView.onResume();
                break;
            case "scan#stopCamera":
              /*  if(cameraView!=null) {
                    onPause();
                }*/
                if(cameraView!=null)
                    cameraView.onPause();
                    cameraView.onDestroy();
               
                break;
            case "scan#restartCamera":
             /*   dummy_recogType = call.argument("recogType");
                dummy_card_id = call.argument("card_id");
                dummy_card_name = call.argument("card_name");
                dummy_country_id = call.argument("country_id");
                dummy_mrzDocumentType = call.argument("mrzDocumentType");
                cameraView = new CameraView(mActivity);
                setupCameraView();*/
                isBack = false;
                if (cameraView != null) cameraView.startOcrScan(true);
                break;

            case "setCustomSound":
                MediaPlayer mediaPlayer = null;
                mediaPlayer = MediaPlayer.create(mContext, R.raw.beep);
                cameraView.setCustomMediaPlayer(mediaPlayer);
            case "scan#activitypause":
                if(cameraView!=null)
                cameraView.onPause();
                break;
            case "FlipCamera":
                if (cameraView != null) {
                    cameraView.flipCamera();
//                    cameraView.onResume();
                }
                break;
            case "printLogFile":
                String value = call.argument("value");
                if (value.equalsIgnoreCase("1")) {
                    //true
                    AccuraLog.enableLogs(true);
                } else {
                    //false
                    AccuraLog.enableLogs(false);
                }
                break;
            case "setcamerafacing":
                String facing = call.argument("facing");
                if (facing.equalsIgnoreCase("1")) {
                    //CAMERA_FACING_FRONT
                    if (cameraView != null) {
                        cameraView.setCameraFacing(1);
                        cameraView.flipCameraByFacing();
                    }
                } else {
                    //CAMERA_FACING_BACK
                    if (cameraView != null) {
                        cameraView.setCameraFacing(0);
                        cameraView.flipCameraByFacing();
                    }
                }

                break;
            case "setCardSide":
                CardSide = call.argument("cardside");
                //CARDSIDE==0==>BACKSIDE
                //CARDSIDE==1==>FRONTSIDE
                //CARDSIDE==2==>FIRST_FRONT_AFTER_BACK
                //CARDSIDE==3==>FIRST_BACK_AFTER_FRONT
            /*    if (CardSide.equalsIgnoreCase("1") || CardSide.equalsIgnoreCase("2")) {
                    if (dummy_recogType.equalsIgnoreCase("1")) {
                        cameraView.setFrontSide();
                    } else {
                        isCardSideFront = true;
                    }

                } else if (CardSide.equalsIgnoreCase("0") || CardSide.equalsIgnoreCase("3")) {
                    if (dummy_recogType.equalsIgnoreCase("1")) {
                        cameraView.setBackSide();
                    } else {
                        isCardSideFront = false;
                    }
                }*/
                break;

            case "setBarcodeType":
                String barcodeType = call.argument("barcode");
                switch (barcodeType) {
                    case "0":
                        cameraView.setBarcodeFormat(0);
                        break;
                    case "1":
                        cameraView.setBarcodeFormat(4096);
                        break;
                    case "2":
                        cameraView.setBarcodeFormat(8);
                        break;
                    case "3":
                        cameraView.setBarcodeFormat(2);
                        break;
                    case "4":
                        cameraView.setBarcodeFormat(4);
                        break;
                    case "5":
                        cameraView.setBarcodeFormat(1);
                        break;
                    case "6":
                        cameraView.setBarcodeFormat(16);
                        break;
                    case "7":
                        cameraView.setBarcodeFormat(64);
                        break;
                    case "8":
                        cameraView.setBarcodeFormat(32);
                        break;
                    case "9":
                        cameraView.setBarcodeFormat(128);
                        break;
                    case "10":
                        cameraView.setBarcodeFormat(2048);
                        break;
                    case "11":
                        cameraView.setBarcodeFormat(256);
                        break;
                    case "12":
                        cameraView.setBarcodeFormat(512);
                        break;
                    case "13":
                        cameraView.setBarcodeFormat(1024);
                        break;
                    default:
                        cameraView.setBarcodeFormat(0);
                        break;
                }

                break;

            case "scan#restartCameraPreview":
                if (cameraView != null) cameraView.startCamera();
                break;
            case "scan#stopCameraPreview":
                if (cameraView != null)  cameraView.stopCamera();
                break;

            default:
                break;
        }

    }

    private void setupCameraView() {
        cardId = Integer.valueOf(dummy_card_id);
      /*  cardName = dummy_card_name;*/

        switch (dummy_recogType) {
            case "MRZ":
                recogType = RecogType.MRZ;
                break;
            case "0":
                recogType = RecogType.OCR;
                break;
            case "BARCODE":
                recogType = RecogType.BARCODE;
                break;
            case "1":
                recogType = RecogType.PDF417;
                break;
            case "2":
                recogType = RecogType.DL_PLATE;
                break;
            case "BANKCARD":
                recogType = RecogType.BANKCARD;
                break;
            default:
                recogType = RecogType.MRZ;
                break;
        }

        countryId = Integer.valueOf(dummy_country_id);

        if (recogType == RecogType.OCR || recogType == RecogType.DL_PLATE) {
            // must have to set data for RecogType.OCR and RecogType.DL_PLATE
            cameraView.setCountryId(countryId).setCardId(cardId)
                    .setMinFrameForValidate(3); // Set min frame for qatar ID card for Most validated data. minFrame supports only odd numbers like 3,5...
        } else if (recogType == RecogType.PDF417) {
            // must have to set data RecogType.PDF417
            cameraView.setCountryId(countryId);
        }
        MRZDocumentType MRZDOCUMENT = MRZDocumentType.NONE;
        if (recogType == RecogType.MRZ) {
            // Also set MRZ document type to scan specific MRZ document
            // 1. ALL MRZ document       - MRZDocumentType.NONE
            // 2. Passport MRZ document  - MRZDocumentType.PASSPORT_MRZ
            // 3. ID card MRZ document   - MRZDocumentType.ID_CARD_MRZ
            // 4. Visa MRZ document      - MRZDocumentType.VISA_MRZ
            switch (dummy_mrzDocumentType) {
                case "0":
                    MRZDOCUMENT = MRZDocumentType.NONE;
                    break;
                case "1":
                    MRZDOCUMENT = MRZDocumentType.PASSPORT_MRZ;
                    break;
                case "2":
                    MRZDOCUMENT = MRZDocumentType.ID_CARD_MRZ;

                    break;
                case "3":
                    MRZDOCUMENT = MRZDocumentType.VISA_MRZ;

                    break;
                default:
                    MRZDOCUMENT = MRZDocumentType.NONE;
                    break;
            }
            cameraView.setMRZDocumentType(MRZDOCUMENT);
        }
        frameLayout.setLayoutParams(new FrameLayout.LayoutParams(-1, -1));

        cameraView.setView(frameLayout)
                .setOcrCallback(this)
                .setRecogType(recogType)

                // To get feedback and Success Call back
                // To remove Height from Camera View if status bar visible
                // or cameraView.setBackSide(); to scan card side front or back default it's scan front side first
//                Option setup
//                .setEnableMediaPlayer(false) // false to disable default sound and true to enable sound and default it is true
//                .setCustomMediaPlayer(MediaPlayer.create(this, /*custom sound file*/)) // To add your custom sound and Must have to enable media player
                .init();

      /*  if(isCardSideFront){
            cameraView.setFrontSide();
        }
        else{
            cameraView.setBackSide();
        }*/

        // initialized camera
        // To set barcode formate.


    }


  /*  @Override
    protected void onDestroy() {
        cameraView.onDestroy();
        super.onDestroy();
    }*/

    public boolean isPermissionsGranted(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    @Override
    public void onAttachedToEngine(@NonNull @NotNull FlutterPlugin.FlutterPluginBinding binding) {

    }

    @Override
    public void onDetachedFromEngine(@NonNull @NotNull FlutterPlugin.FlutterPluginBinding binding) {

    }


    @Override
    public void onClick(View v) {

    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        return false;
    }

/*public static boolean isPermissionsGranted(Activity context) {
    String permission = Manifest.permission.CAMERA;
//        for (String permission : getRequiredPermissions(context)) {
    if (checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
        return false;
    }
//        }
    return true;
}*/

}