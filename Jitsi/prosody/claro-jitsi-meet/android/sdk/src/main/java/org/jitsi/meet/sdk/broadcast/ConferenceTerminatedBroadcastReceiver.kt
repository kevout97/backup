package org.jitsi.meet.sdk.broadcast

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import timber.log.Timber

class ConferenceTerminatedBroadcastReceiver(
        private val listener: OnConferenceTerminatedBroadcastReceiverListener
) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        val action: String? = intent?.action
        Timber.d(TAG, "onReceive action -> $action")
        if(action != null){
            when(action){
                CONFERENCE_TERMINATED_RECEIVE -> listener.validateConferenceTerminatedEvent()
            }
        }
    }

    interface OnConferenceTerminatedBroadcastReceiverListener {
        fun validateConferenceTerminatedEvent()
    }

    companion object {

        private val TAG = ConferenceTerminatedBroadcastReceiver::class.java.simpleName

        val CONFERENCE_TERMINATED_RECEIVE = "CONFERENCE_TERMINATED_RECEIVE"

    }
}