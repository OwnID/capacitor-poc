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
        webViewBridge.injectInto(bridge.getWebView(), new HashSet<>(Collections.singletonList("https://dev.ownid.com")), this, true, null);
    }
}