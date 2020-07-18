package com.yourconf.android.web.clients

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.net.http.SslError
import android.util.Log
import android.webkit.*
import com.yourconf.android.R


class CustomWebViewClient(
    private val listener: OnCustomWebViewClientListener
) : WebViewClient() {

    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        Log.d(TAG, "shouldOverrideUrlLoading")
        return false
    }

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        Log.d(TAG, "onPageFinished url -> $url")
        listener.sendCurrentFinishedPage(url)
    }

    override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
        super.onReceivedError(view, request, error)
        Log.d(TAG, "onReceivedError")
    }

    override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, error: SslError) {
        Log.d(TAG, "onReceivedSslError")
        val builder: AlertDialog.Builder = AlertDialog.Builder(view.context)
        builder.setMessage(view.context.getString(R.string.notification_error_ssl_cert_invalid))
        builder.setPositiveButton(view.context.getString(R.string.btn_accept), DialogInterface.OnClickListener { dialog, which -> handler.proceed() })
        builder.setNegativeButton(view.context.getString(R.string.btn_cancel), DialogInterface.OnClickListener { dialog, which -> run {
            handler.cancel()
            if (view.context is Activity)  (view.context as Activity).finish()
        } })
        val dialog: AlertDialog = builder.create()
        dialog.show()
    }

    interface OnCustomWebViewClientListener {
        fun sendCurrentFinishedPage(url: String)
    }

    companion object {

        private val TAG = CustomWebViewClient::class.java.simpleName

    }
}