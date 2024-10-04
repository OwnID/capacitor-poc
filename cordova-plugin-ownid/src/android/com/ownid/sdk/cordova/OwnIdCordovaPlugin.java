package com.ownid.sdk.cordova;

import android.webkit.WebView;

import com.ownid.sdk.OwnId;
import com.ownid.sdk.OwnIdWebViewBridge;

import org.apache.cordova.CordovaPlugin;

import java.util.Collections;
import java.util.HashSet;

public class OwnIdCordovaPlugin extends CordovaPlugin {

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        OwnId.createInstanceFromFile(cordova.getActivity(), "ownIdSdkConfig.json", "OwnIdCordovaPlugin/3.4.0");

        OwnIdWebViewBridge webViewBridge = OwnId.createWebViewBridge();
        HashSet<String> allowedOriginRules = new HashSet<>(Collections.singletonList("https://localhost"));
        webViewBridge.injectInto((WebView) webView.getView(), allowedOriginRules, cordova.getActivity(), true, null);
    }
}