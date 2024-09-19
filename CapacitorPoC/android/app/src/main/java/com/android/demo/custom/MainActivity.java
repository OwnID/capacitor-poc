package com.android.demo.custom;

import android.os.Bundle;

import com.getcapacitor.BridgeActivity;
import com.ownid.sdk.OwnId;
import com.ownid.sdk.OwnIdWebViewBridge;

import java.util.Collections;
import java.util.HashSet;

public class MainActivity extends BridgeActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        OwnIdWebViewBridge webViewBridge = OwnId.createWebViewBridge();
        HashSet<String> allowedOriginRules = new HashSet<>(Collections.singletonList("https://dev.ownid.com"));
        webViewBridge.injectInto(bridge.getWebView(), allowedOriginRules, this, true, null);
    }
}