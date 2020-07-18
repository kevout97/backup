package com.yourconf.android.features.webview

import com.yourconf.android.R
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.webkit.WebChromeClient
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Observer
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import com.yourconf.android.broadcasts.NetworkChangeReceiver
import com.yourconf.android.features.models.ConferenceInitData
import com.yourconf.android.features.models.User
import com.yourconf.android.features.models.WebViewModel
import com.yourconf.android.features.noconnection.NoNetworkConnectionDialog
import com.yourconf.android.repositories.UserRepository
import com.yourconf.android.sources.UserPreferenceDataSource
import com.yourconf.android.usecases.DeleteUserInformationUseCase
import com.yourconf.android.usecases.GetUserTypeUseCase
import com.yourconf.android.usecases.SaveUserInformationUseCase
import com.yourconf.android.utils.Constants.EXTRA_WEB_VIEW_INTERFACE_NAME
import com.yourconf.android.utils.getViewModel
import com.yourconf.android.web.clients.CustomWebViewClient
import com.yourconf.android.web.interfaces.WebAppInterface
import kotlinx.android.synthetic.main.activity_example.*
import org.jitsi.meet.sdk.broadcast.ConferenceTerminatedBroadcastReceiver
import org.jitsi.meet.sdk.broadcast.ConferenceTerminatedBroadcastReceiver.Companion.CONFERENCE_TERMINATED_RECEIVE


class WebViewActivity :
    AppCompatActivity(),
    WebAppInterface.OnWebAppInterfaceListener,
    ConferenceTerminatedBroadcastReceiver.OnConferenceTerminatedBroadcastReceiverListener,
    NetworkChangeReceiver.OnNetworkChangeReceiverListener,
    NoNetworkConnectionDialog.OnNoNetworkConnectionDialogListener,
    CustomWebViewClient.OnCustomWebViewClientListener {

    //region Fields

    private val preferences: SharedPreferences by lazy {
        applicationContext.getSharedPreferences("NativeStorage", Context.MODE_PRIVATE)
    }

    private val userRepository: UserRepository by lazy {
        UserRepository(
                UserPreferenceDataSource(preferences)
        )
    }

    private val saveUserInformationUseCase: SaveUserInformationUseCase by lazy {
        SaveUserInformationUseCase(userRepository)
    }

    private val deleteUserInformationUseCase: DeleteUserInformationUseCase by lazy {
        DeleteUserInformationUseCase(userRepository)
    }

    private val getUserTypeUseCase: GetUserTypeUseCase by lazy {
        GetUserTypeUseCase(userRepository)
    }

    private val viewModel: WebViewViewModel by lazy {
        getViewModel { WebViewViewModel(
                saveUserInformationUseCase,
                deleteUserInformationUseCase,
                getUserTypeUseCase
        ) }
    }

    private val webAppInterface: WebAppInterface by lazy {
        WebAppInterface(this@WebViewActivity)
    }

    private val broadcastReceiver: ConferenceTerminatedBroadcastReceiver by lazy {
        ConferenceTerminatedBroadcastReceiver(this)
    }

    private var networkChangeReceiver: NetworkChangeReceiver? = null

    //endregion

    //region Override Methods & Callbacks

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate")
        setContentView(R.layout.activity_example)

        viewModel.webViewModel.observe(this, Observer(::initWebView))

        viewModel.onInitConferenceDefaultOptions()
        viewModel.onInitWebView(intent)

        registerReceiver(broadcastReceiver, IntentFilter().apply {
            addAction(CONFERENCE_TERMINATED_RECEIVE)
        })
    }

    override fun onStart() {
        super.onStart()
        if(networkChangeReceiver == null){
            networkChangeReceiver = NetworkChangeReceiver.registerReceiver(this, this)
        }
    }

    override fun onStop() {
        super.onStop()
        if(networkChangeReceiver != null){
            unregisterReceiver(networkChangeReceiver)
            networkChangeReceiver = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy")
        unregisterReceiver(broadcastReceiver)
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        Log.d(TAG, "onNewIntent data -> ${intent?.data}")
        if (intent != null && intent.data is Uri) {
            viewModel.onValidateDeepLink(intent.data)
        }else{
            //viewModel.onWebViewRetry()
        }
    }

    override fun OAuthLogin() {
        Log.d(TAG, "OAuthLogin")
        viewModel.onRequestOAuthLogin(this)
    }

    override fun OAuthLogout(){
        Log.d(TAG,"OAuthLogout")
        viewModel.onRequestOauthLogout(this)

    }

    override fun logIn(user: User) {
        Log.d(TAG, "logIn")
        viewModel.onSaveUserInformation(user)
    }

    override fun startConference(conferenceInitData: ConferenceInitData) {
        Log.d(TAG, "startConference conferenceInitData -> $conferenceInitData")
        viewModel.onStartConference(this, conferenceInitData)
    }

    override fun joinConference(conferenceInitData: ConferenceInitData) {
        Log.d(TAG, "joinConference conferenceInitData -> $conferenceInitData")
        viewModel.onSaveUserInformationFromJoinConference(conferenceInitData)
        viewModel.onStartConference(this, conferenceInitData)
    }

    override fun logOut() {
        Log.d(TAG, "logOut")
        viewModel.onDeleteUserInformation()
    }

    override fun validateConferenceTerminatedEvent() {
        viewModel.validateConferenceTerminatedEventByUserType()
    }

    override fun onConnectedToNetwork() {
        NoNetworkConnectionDialog.enableRetryJoinOption(supportFragmentManager)
    }

    override fun onDisconnectedToNetwork() {
        NoNetworkConnectionDialog.showNewInstance(supportFragmentManager)
        NoNetworkConnectionDialog.disableRetryJoinOption(supportFragmentManager)
    }

    override fun retry() {
        NoNetworkConnectionDialog.dismissInstance(supportFragmentManager)
        viewModel.onWebViewRetry()
    }

    override fun exit() {
        finish()
    }

    override fun sendCurrentFinishedPage(url: String) {
        viewModel.onUpdateWebViewSaveState(url)
    }

    //endregion

    //region Private Methods

    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebView(webViewModel: WebViewModel) {
        webView.run {
            var userAgent = settings.userAgentString
            if(!userAgent.contains(webViewModel.userAgentString)){
                userAgent += " ${webViewModel.userAgentString}"
            }

            settings.javaScriptEnabled = webViewModel.isJavaScriptEnabled
            settings.domStorageEnabled = webViewModel.isDomStorageEnabled
            settings.cacheMode = webViewModel.cacheMode
            settings.userAgentString = userAgent

            webViewClient = CustomWebViewClient(this@WebViewActivity)
            webChromeClient = WebChromeClient()

            addJavascriptInterface(webAppInterface, EXTRA_WEB_VIEW_INTERFACE_NAME)
            loadUrl(webViewModel.url)
        }
    }

    //endregion

    //region Companion Object

    companion object {

        private val TAG = WebViewActivity::class.java.simpleName

    }

    //endregion

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d(TAG, "[AMX DEBUG] onActivityResult" + (resultCode.toString()));
        if (requestCode == 666){
            val task: Task<GoogleSignInAccount> = GoogleSignIn.getSignedInAccountFromIntent(data)
            try {
                val account: GoogleSignInAccount? = task.getResult(ApiException::class.java)
                if (account is GoogleSignInAccount) {
                    val authCode: String? = account.getServerAuthCode()
                    if (authCode is String){
                        Log.d(TAG, "[AMX DEBUG] AuthCode" + authCode);
                        this.webView.evaluateJavascript("document.ClaroConnectWebViewNotifier.execute('OAuthCode','"+authCode+"')",null);
                    }
                    // Show signed-un UI
                    //updateUI(account)
                    // TODO(developer): send code to server and exchange for access/refresh/ID tokens
                }
            } catch (e: ApiException) {
                //Log.d(TAG, ));
                Log.w(TAG, "[AMX DEBUG] onActivityResultFailed" + (resultCode.toString()), e);
                this.webView.evaluateJavascript("document.ClaroConnectWebViewNotifier.execute('OAuthReject','')",null);
            }
        }else{
            this.webView.evaluateJavascript("document.ClaroConnectWebViewNotifier.execute('OAuthReject','')",null);
        }
    }



}