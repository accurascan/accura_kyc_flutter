package com.accurascan.reactnative;

import android.os.Bundle;
import android.os.PersistableBundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
