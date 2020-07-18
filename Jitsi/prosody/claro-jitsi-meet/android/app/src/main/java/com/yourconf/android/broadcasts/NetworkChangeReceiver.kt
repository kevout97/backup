package com.yourconf.android.broadcasts

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.ConnectivityManager.CONNECTIVITY_ACTION
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi

class NetworkChangeReceiver (): BroadcastReceiver(){

    private var listener: OnNetworkChangeReceiverListener? = null

    constructor(_listener: OnNetworkChangeReceiverListener) : this() {
        listener = _listener
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive action -> ${intent.action}")

        if(isNetworkConnected(context)){
            Log.d(TAG, "onReceive onConnectedToNetwork")
            listener?.onConnectedToNetwork()
        }else{
            Log.d(TAG, "onReceive onDisconnectedToNetwork")
            listener?.onDisconnectedToNetwork()
        }
    }

    private fun isNetworkConnected(context: Context): Boolean {
        val cm: ConnectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
                ?: return false

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            isNetworkConnected(cm)
        } else {
            isNetworkConnectedPreMarshmallow(cm)
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun isNetworkConnected(cm: ConnectivityManager): Boolean{
        val n = cm.activeNetwork ?: return false
        val nc = cm.getNetworkCapabilities(n)
        return nc.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
            || nc.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
    }

    @Suppress("DEPRECATION")
    private fun isNetworkConnectedPreMarshmallow(cm: ConnectivityManager): Boolean{
        val ni = cm.activeNetworkInfo ?: return false
        return ni.isConnected
            && (ni.type == ConnectivityManager.TYPE_WIFI
            || ni.type == ConnectivityManager.TYPE_MOBILE)
    }

    interface OnNetworkChangeReceiverListener {
        fun onConnectedToNetwork()
        fun onDisconnectedToNetwork()
    }

    companion object {

        private val TAG = NetworkChangeReceiver::class.java.simpleName

        fun registerReceiver(context: Context, listener: OnNetworkChangeReceiverListener) =
            NetworkChangeReceiver(listener).apply {
                @Suppress("DEPRECATION")
                context.registerReceiver(this, IntentFilter(CONNECTIVITY_ACTION))
            }
    }
}