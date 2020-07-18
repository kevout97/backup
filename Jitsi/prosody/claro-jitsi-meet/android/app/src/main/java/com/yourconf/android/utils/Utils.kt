package com.yourconf.android.utils

import android.net.Uri
import com.yourconf.android.BuildConfig
import com.yourconf.android.states.WebViewState

object Utils {

    private const val USER_AGENT_PLATFORM = "D-Android"
    private const val USER_AGENT_APP_NAME = "ClaroConnect"

    fun getWebViewStateByUrl(url: String?): WebViewState{
        val uri: Uri? = Uri.parse(url)
        val path: String? = uri?.path
        if(path != null){
            if (path.startsWith("/iam/congrats")) {
                return WebViewState.Congratulations
            }

            if (path.startsWith("/iam/c")) {
                return WebViewState.Invitation
            }
        }

        return WebViewState.Management
    }

    fun generateUserAgent(): String = "[$USER_AGENT_PLATFORM; " +
        "$USER_AGENT_APP_NAME/" +
        getVersionForUserAgent() + "]"

    private fun getVersionForUserAgent() = BuildConfig.VERSION_NAME
}