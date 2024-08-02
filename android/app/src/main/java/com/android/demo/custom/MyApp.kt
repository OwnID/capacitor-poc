package com.android.demo.custom

import android.app.Application
import com.ownid.sdk.OwnId

class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        OwnId.createInstanceFromJson(
            this,
            "{\"appId\": \"xotvc7yff9clvn\", \"env\": \"dev\", \"enableLogging\": true}",
            "DirectIntegration/3.4.0"
        )
    }
}
