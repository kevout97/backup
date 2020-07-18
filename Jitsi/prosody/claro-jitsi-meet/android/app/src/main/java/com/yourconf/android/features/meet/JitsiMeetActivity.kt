package com.yourconf.android.features.meet

import android.content.Context
import android.content.Intent
import org.jitsi.meet.sdk.JitsiMeetActivityInterface
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import org.jitsi.meet.sdk.JitsiMeetOngoingConferenceService
import org.jitsi.meet.sdk.JitsiMeetViewListener
import org.jitsi.meet.sdk.broadcast.ConferenceTerminatedBroadcastReceiver
import org.jitsi.meet.sdk.log.JitsiMeetLogger


class JitsiMeetActivity : org.jitsi.meet.sdk.JitsiMeetActivity(), JitsiMeetActivityInterface, JitsiMeetViewListener {

    override fun onUserLeaveHint() {
       //TODO: [AMX HINT] Enable PIP here (remove override)
    }

    override fun onConferenceJoined(data: HashMap<String, Any>) {
        JitsiMeetLogger.i("Conference joined: $data")
        // Launch the service for the ongoing notification.
        JitsiMeetOngoingConferenceService.launch(this)
    }

    override fun onConferenceTerminated(data: HashMap<String, Any>) {
        JitsiMeetLogger.i("Conference terminated: $data")
    }

    override fun onConferenceWillJoin(data: HashMap<String, Any>) {
        JitsiMeetLogger.i("Conference will join: $data")
    }

    override fun onConferenceRoomLeave(data: HashMap<String, Any>) {
        JitsiMeetLogger.i("Conference room leave: $data")
        val intent = Intent(ConferenceTerminatedBroadcastReceiver.CONFERENCE_TERMINATED_RECEIVE)
        sendBroadcast(intent)
        finish()
    }

    companion object {

        protected val TAG = JitsiMeetActivity::class.java.simpleName
        const val ACTION_JITSI_MEET_CONFERENCE = "org.jitsi.meet.CONFERENCE"
        const val JITSI_MEET_CONFERENCE_OPTIONS = "JitsiMeetConferenceOptions"

        // Helpers for starting the activity
        //

        fun launch(context: Context, options: JitsiMeetConferenceOptions) {
            val intent = Intent(context, JitsiMeetActivity::class.java)
            intent.action = ACTION_JITSI_MEET_CONFERENCE
            intent.putExtra(JITSI_MEET_CONFERENCE_OPTIONS, options)
            context.startActivity(intent)
        }

        fun launch(context: Context, url: String) {
            val options = JitsiMeetConferenceOptions.Builder().setRoom(url).build()
            launch(context, options)
        }
    }
}
