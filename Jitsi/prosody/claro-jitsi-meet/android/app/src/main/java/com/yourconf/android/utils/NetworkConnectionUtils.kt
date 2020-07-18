package com.yourconf.android.utils

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkInfo
import com.yourconf.android.MainApplication

object NetworkConnectionUtils {

    fun isConnectedToNetwork(): Boolean {
        val cm = MainApplication.instance.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val activeNetwork: NetworkInfo? = cm.activeNetworkInfo
        return activeNetwork?.isConnectedOrConnecting == true
    }

}