package com.accurascan.mrz.liveness.fm;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Base64;
import android.util.Log;

import com.accurascan.facedetection.model.AccuraVerificationResult;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.accurascan.mrz.liveness.fm.UnsafeOkHttpClient.getUnsafeOkHttpClient;
import static com.accurascan.mrz.liveness.fm.getMRZList.liveness_result;

import androidx.annotation.NonNull;

/** AccuraemiratesPlugin */
public class AccuraKycFlutterPlugin implements ActivityAware,PluginRegistry.ActivityResultListener {

public static Context mContext;
    public static Activity mActivity;
    public static void registerWith(Registrar registrar) {

        final AccuraKycFlutterPlugin plugin = new AccuraKycFlutterPlugin();
        getUnsafeOkHttpClient();
        Log.e("FlutterLivenessFactory", "registerWith: "+registrar );
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "scan_preview", new FlutterUnityViewFactory(registrar));
        registrar.addActivityResultListener(plugin);
/*        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "check_live_ness", new FlutterLivenessFactory(registrar));*/
        mActivity = registrar.activity();
        mContext=registrar.context();
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "getMrzAndCountryList");
        channel.setMethodCallHandler(new getMRZList(mActivity,mContext));

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode ==1212 ||requestCode ==1010) {
            if (liveness_result != null) {
                Log.e("BroadcastReceiver", "onReceive: ");
                JSONObject mainObject = new JSONObject();
                AccuraVerificationResult accuraVerificationResult_facematch = data.getParcelableExtra("Accura.fm");
                if (accuraVerificationResult_facematch == null) {
                    AccuraVerificationResult accuraVerificationResult_liveness = data.getParcelableExtra("Accura.liveness");
                    Log.e("BroadcastReceiver", "onReceive: " + accuraVerificationResult_liveness);
                    try {
                        if (accuraVerificationResult_liveness.getStatus() != null) {
                            mainObject.put("Status", accuraVerificationResult_liveness.getStatus());
                        }
                        if (accuraVerificationResult_liveness.getErrorMessage() != null) {
                            mainObject.put("ErrorMessage", accuraVerificationResult_liveness.getErrorMessage());
                        }

                        /*         mainObject.put("videoPath",accuraVerificationResult_liveness.getVideoPath());*/

                        if (accuraVerificationResult_liveness.getFaceBiometrics() != null) {
                            mainObject.put("imagePath", getbase64(accuraVerificationResult_liveness.getFaceBiometrics()));
                        }

                        if (accuraVerificationResult_liveness.getLivenessResult() != null) {

                            mainObject.put("livenessStatus", accuraVerificationResult_liveness.getLivenessResult().getLivenessStatus());
                            double scrore_double = accuraVerificationResult_liveness.getLivenessResult().getLivenessScore();
                            String score = String.valueOf(scrore_double * 100);
                            Log.e("accuraVerificati", "onReceive: " + score);
                            mainObject.put("livenessScore", "" + score.substring(0, 4) + "%");
                        }
                        liveness_result.success(mainObject.toString());
                    } catch (JSONException e) {

                    }

                } else {

                    if (accuraVerificationResult_facematch.getFaceBiometrics() != null) {
                        try {
                            mainObject.put("imagePath", getbase64(accuraVerificationResult_facematch.getFaceBiometrics()));
                            liveness_result.success(mainObject.toString());
                        } catch (JSONException e) {

                        }
                    }
                }
            }
        }
        return  true;
    }
    private String getbase64(Bitmap myBitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        myBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        byte[] b = baos.toByteArray();
        String imageEncoded = Base64.encodeToString(b, Base64.NO_WRAP);
        Log.e("base64Image", "getImageByte: " + imageEncoded);
        return imageEncoded;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        mActivity=binding.getActivity();
        getUnsafeOkHttpClient();
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
