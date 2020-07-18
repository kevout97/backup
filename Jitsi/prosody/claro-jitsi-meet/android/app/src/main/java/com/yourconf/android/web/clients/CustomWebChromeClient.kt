package com.yourconf.android.web.clients

import android.util.Log
import android.webkit.JsResult
import android.webkit.WebView
import android.webkit.WebChromeClient

class CustomWebChromeClient : WebChromeClient() {

    override fun onJsAlert(view: WebView, url: String, message: String, result: JsResult): Boolean {
        Log.d(TAG, "onJsAlert message -> $message")
        result.confirm()
        return true
    }

    companion object {

        private val TAG = CustomWebChromeClient::class.java.simpleName

    }
}