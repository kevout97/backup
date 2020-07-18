package com.yourconf.android.features.splash

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.yourconf.android.R
import com.yourconf.android.features.webview.WebViewActivity
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;
import com.yourconf.android.sources.UserPreferenceDataSource

class SplashActivity : FragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        if (!isTaskRoot()) {
            super.onCreate(savedInstanceState)
            finish()
            return
        }
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)
        Handler().postDelayed(::startExample, SPLASH_DURATION)
        AppCenter.start(application, "0b7c95d7-aa55-4e0e-ae5e-7eab34b975e4", Analytics::class.java, Crashes::class.java)
    }

    private fun startExample(){
        startActivity(Intent(this, WebViewActivity::class.java))
        finish()
    }

    companion object {
        const val SPLASH_DURATION = 2000L
    }
}