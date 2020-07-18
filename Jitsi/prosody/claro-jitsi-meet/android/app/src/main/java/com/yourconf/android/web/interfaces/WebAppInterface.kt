package com.yourconf.android.web.interfaces

import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.yourconf.android.features.models.ConferenceInitData
import com.yourconf.android.features.models.User
import com.yourconf.android.parsers.Parsers
import org.json.JSONObject

class WebAppInterface(
        private val listener: OnWebAppInterfaceListener
) {

    @JavascriptInterface
    fun execute(action: String, parameters: String){
        Log.d(TAG, "JavascriptInterface execute action, parameters -> $action, $parameters")
        when(MobileActions.valueOf(action)){
            MobileActions.JoinConference -> validateJoinConference(parameters)
            MobileActions.LoginUser -> validateLogInUser(parameters)
            MobileActions.LogOut -> listener.logOut()
            MobileActions.StartConference -> validateStartConference(parameters)
            MobileActions.OAuthLogin -> validateOAuthLogin(parameters)
            MobileActions.OAuthLogout -> validateOAuthLogout()
        }
    }

    fun notifyDemo(webView: WebView){
        webView.evaluateJavascript("document.ClaroConnectWebViewNotifier.execute('DEMO','Hello')", null)
    }

    fun notifyAlert(webView: WebView){
        webView.evaluateJavascript("document.ClaroConnectWebViewNotifier.execute('ALERTA','Hello alert!')", null)
    }

    //region Private Methods

    private fun validateStartConference(parameters: String){
        try{
            listener.startConference(
                Parsers.parseConferenceInitData(JSONObject(parameters))
            )
        }catch (e: Exception){
            e.printStackTrace()
        }
    }

    private fun validateJoinConference(parameters: String){
        try{
            listener.joinConference(
                Parsers.parseConferenceInitData(JSONObject(parameters))
            )
        }catch (e: Exception){
            e.printStackTrace()
        }
    }

    private fun validateLogInUser(parameters: String){
        try{
            listener.logIn(
                Parsers.parseUser(JSONObject(parameters))
            )
        }catch (e: Exception){
            e.printStackTrace()
        }
    }

    private fun validateOAuthLogin(parameters: String){
        try{
            listener.OAuthLogin()
        }catch (e: Exception){
            e.printStackTrace()
        }
    }

    private fun validateOAuthLogout(){
        try{
            listener.OAuthLogout()
        }catch (e: Exception){
            e.printStackTrace()
        }
    }

    //endregion

    //region Inner Classes & Interfaces

    sealed class MobileActions {
        object JoinConference: MobileActions()
        object LoginUser: MobileActions()
        object LogOut: MobileActions()
        object StartConference: MobileActions()
        object OAuthLogin: MobileActions()
        object OAuthLogout : MobileActions()

        companion object {
            fun valueOf(action: String?): MobileActions? = when (action) {
                "StartConference" -> StartConference
                "LoginUser" -> LoginUser
                "JoinConference" -> JoinConference
                "LogOut" -> LogOut
                "OAuthLogin" -> OAuthLogin
                "OAuthLogout" -> OAuthLogout
                else -> null
            }
        }
    }

    interface OnWebAppInterfaceListener {
        fun logIn(user: User)
        fun startConference(conferenceInitData: ConferenceInitData)
        fun OAuthLogin()
        fun OAuthLogout()
        fun joinConference(conferenceInitData: ConferenceInitData)
        fun logOut()
    }

    //endregion

    companion object {

        private val TAG = WebAppInterface::class.java.simpleName

    }
}