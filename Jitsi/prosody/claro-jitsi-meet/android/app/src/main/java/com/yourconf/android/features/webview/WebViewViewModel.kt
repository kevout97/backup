package com.yourconf.android.features.webview

import android.R
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings.Global.getString
import android.util.Log
import android.webkit.WebSettings
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.auth.api.signin.GoogleSignInOptions.Builder
import com.google.android.gms.common.api.Scope
import com.yourconf.android.BuildConfig
import com.yourconf.android.enums.UserType
import com.yourconf.android.features.meet.JitsiMeetActivity
import com.yourconf.android.features.models.ConferenceInitData
import com.yourconf.android.features.models.User
import com.yourconf.android.features.models.WebViewModel
import com.yourconf.android.states.WebViewState
import com.yourconf.android.usecases.DeleteUserInformationUseCase
import com.yourconf.android.usecases.GetUserTypeUseCase
import com.yourconf.android.usecases.SaveUserInformationUseCase
import com.yourconf.android.utils.NetworkConnectionUtils
import com.yourconf.android.utils.Utils
import com.yourconf.android.utils.Utils.generateUserAgent
import org.jitsi.meet.sdk.JitsiMeet
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import org.jitsi.meet.sdk.JitsiMeetUserInfo
import java.net.MalformedURLException
import java.net.URL


class WebViewViewModel(
        private val saveUserInformationUseCase: SaveUserInformationUseCase,
        private val deleteUserInformationUseCase: DeleteUserInformationUseCase,
        private val getUserTypeUseCase: GetUserTypeUseCase
) : ViewModel(){

    //region Fields

    private val _webViewModel = MutableLiveData<WebViewModel>()
    val webViewModel: LiveData<WebViewModel> get() = _webViewModel

    private val _webViewState = MutableLiveData<WebViewState>()
    val webViewState: LiveData<WebViewState>
        get(){
            if(_webViewState.value == null){
                _webViewState.value = WebViewState.Management
            }

            return _webViewState
        }

    //endregion

    //region Public Methods

    fun onInitConferenceDefaultOptions(){
        val serverURL: URL
        try {
            serverURL = URL(BuildConfig.CONFERENCE_SERVER_URL)
        } catch (e: MalformedURLException) {
            e.printStackTrace()
            throw RuntimeException("Invalid server URL!")
        }

        val defaultOptions = JitsiMeetConferenceOptions.Builder()
                .setServerURL(serverURL)
                .setWelcomePageEnabled(false)
                .build()
        JitsiMeet.setDefaultConferenceOptions(defaultOptions)
    }

    fun onInitWebView(intent: Intent){
        val action = intent.action

        if (Intent.ACTION_VIEW == action) run {
            val uri = intent.data
            if (uri != null) {
                initWebViewModelByDeepLink(uri)
                return
            }
        }

        initWebViewModel()
    }

    fun onSaveUserInformation(user: User) {
        saveUserInformationUseCase.invoke(user)
    }

    fun onSaveUserInformationFromJoinConference(conferenceInitData: ConferenceInitData) {
        val type = conferenceInitData.userType
        if(type == "guest"){
            val user = User(
                    displayName = conferenceInitData.displayName,
                    email = conferenceInitData.email,
                    virtualNumber = conferenceInitData.virtualNumber ?: "",
                    userType = type,
                    language = conferenceInitData.language ?: "",
                    auth = conferenceInitData.auth
            )
            saveUserInformationUseCase.invoke(user)
        }
    }

    fun onDeleteUserInformation(){
        deleteUserInformationUseCase.invoke()
    }

    fun validateConferenceTerminatedEventByUserType() {
        val userType = getUserTypeUseCase.invoke()

        Log.d(TAG, "validateConferenceTerminatedEventByUserType user type -> $userType")
        Log.d(TAG, "validateConferenceTerminatedEventByUserType web view state -> ${_webViewState.value?.javaClass?.simpleName}")

        if(userType == UserType.USER){
            //TODO: Now always refreshes WebView. In the future, we'll implement a WebSocket
            //if(_webViewState.value !== WebViewState.Management){
                initWebViewModel(true)
            //}
        }else{
            initWebViewModelCongratulationsPage()
            return
        }
    }

    fun onValidateDeepLink(data: Uri?) {
        data?.let {
            initWebViewModelByDeepLink(it)
        }
    }

    fun onWebViewRetry(){
        val userType = getUserTypeUseCase.invoke()

        Log.d(TAG, "onWebViewRetry user type -> $userType")
        Log.d(TAG, "onWebViewRetry web view state -> ${_webViewState.value?.javaClass?.simpleName}")

        when(_webViewState.value){
            WebViewState.Congratulations -> initWebViewModelCongratulationsPage()
            WebViewState.Invitation -> {
                if(userType == UserType.USER){
                    initWebViewModel(true)
                }else {
                    initWebViewModel()
                }
            }
            WebViewState.Management -> initWebViewModel()
        }
    }

    fun onUpdateWebViewSaveState(url: String){
        _webViewState.value = Utils.getWebViewStateByUrl(url)
    }

    fun onStartConference(context: Context, conferenceInitData: ConferenceInitData){
        val user = JitsiMeetUserInfo().apply {
            displayName = conferenceInitData.displayName
            email = conferenceInitData.email
        }

        val options = JitsiMeetConferenceOptions.Builder()
            .setFeatureFlag("pip.enabled", false)
            .setRoom(conferenceInitData.conferenceId)
            .setSubject(conferenceInitData.conferenceSubject)
            .setAudioMuted(!conferenceInitData.hasMicrophone)
            .setVideoMuted(!conferenceInitData.hasCamera)
            .setUserInfo(user)
            .build()

        JitsiMeetActivity.launch(context, options)
    }

    fun onRequestOAuthLogin(context: Context){
        val serverClientId: String = BuildConfig.CLIENT_ID_SERVER;
        val gso: GoogleSignInOptions = Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestScopes(Scope(BuildConfig.SCOPE_CALENDAR_GOOGLE))
            .requestServerAuthCode(serverClientId)
            .requestEmail()
            .build()

        var mGoogleSignInClient = GoogleSignIn.getClient(context, gso);
        val signInIntent = mGoogleSignInClient.signInIntent;
        mGoogleSignInClient.signOut()

        var activity =  context as Activity;
        activity.startActivityForResult(signInIntent, 666);
    }

    fun onRequestOauthLogout(Context: Context){
        val serverClientId: String = BuildConfig.CLIENT_ID_SERVER;
        val gso: GoogleSignInOptions = Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestScopes(Scope(BuildConfig.SCOPE_CALENDAR_GOOGLE))
            .requestServerAuthCode(serverClientId)
            .requestEmail()
            .build()
        var mGoogleSignInClient = GoogleSignIn.getClient(Context, gso);
        mGoogleSignInClient.signOut()
    }

    //endregion

    //region Private Methods

    private fun initWebViewModelByDeepLink(uri: Uri) {
        _webViewState.value = WebViewState.Invitation
        initWebViewModel(url = uri.toString())
    }

    private fun initWebViewModelCongratulationsPage(){
        _webViewState.value = WebViewState.Congratulations
        initWebViewModel(url = BuildConfig.WEB_VIEW_URL_CONGRATULATIONS)
    }

    private fun initWebViewModel(isLoggedIn: Boolean = false){
        _webViewState.value = WebViewState.Management
        initWebViewModel(
            url = if (isLoggedIn) BuildConfig.WEB_VIEW_URL_MANAGEMENT else BuildConfig.WEB_VIEW_URL
        )
    }

    private fun initWebViewModel(url: String){
        if(!NetworkConnectionUtils.isConnectedToNetwork()){
            return
        }

        val webViewModel = WebViewModel(
            isJavaScriptEnabled = true,
            isDomStorageEnabled = true,
            cacheMode = WebSettings.LOAD_NO_CACHE,
            userAgentString = generateUserAgent(),
            url = url
        )
        _webViewModel.value = webViewModel
    }

    //endregion

    companion object {

        private val TAG = WebViewViewModel::class.java.simpleName

    }

}