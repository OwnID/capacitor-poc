package com.android.demo.custom

import android.os.Bundle
import com.getcapacitor.BridgeActivity
import com.ownid.sdk.OwnId

class MainActivity : BridgeActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        OwnId.instance.ownIdCore.createWebViewBridge().injectInto(bridge.webView, setOf("https://dev.ownid.com"), owner = this) {
            bridge.reload()
        }
    }
}