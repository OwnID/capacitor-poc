/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package com.android.demo.custom;

import android.os.Bundle;
import android.webkit.WebView;

import com.ownid.sdk.OwnId;
import com.ownid.sdk.OwnIdWebViewBridge;

import org.apache.cordova.CordovaActivity;

import java.util.Collections;
import java.util.HashSet;

public class MainActivity extends CordovaActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // enable Cordova apps to be started in the background
        Bundle extras = getIntent().getExtras();
        if (extras != null && extras.getBoolean("cdvStartInBackground", false)) {
            moveTaskToBack(true);
        }

        init();

        OwnIdWebViewBridge webViewBridge = OwnId.createWebViewBridge();
        HashSet<String> allowedOriginRules = new HashSet<>(Collections.singletonList("https://localhost"));
        webViewBridge.injectInto((WebView) appView.getView(), allowedOriginRules, this, true, null);

        // Set by <content src="index.html" /> in config.xml
        loadUrl(launchUrl);
    }
}
