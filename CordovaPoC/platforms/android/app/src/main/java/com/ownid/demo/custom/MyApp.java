package com.ownid.demo.custom;

import android.app.Application;

import com.ownid.sdk.OwnId;

public class MyApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();

        OwnId.createInstanceFromJson(
                this,
                "{\"appId\": \"xc675hd2el6tzq\", \"env\": \"dev\", \"enableLogging\": true}",
                "DirectIntegration/3.4.0"
        );
    }
}
