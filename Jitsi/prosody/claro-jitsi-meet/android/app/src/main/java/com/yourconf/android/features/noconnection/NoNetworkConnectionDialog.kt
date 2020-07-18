package com.yourconf.android.features.noconnection

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import androidx.fragment.app.FragmentManager
import com.crashlytics.android.Crashlytics
import kotlinx.android.synthetic.main.dialog_no_network_connection.*
import com.yourconf.android.R
import com.yourconf.android.utils.NetworkConnectionUtils

class NoNetworkConnectionDialog : androidx.fragment.app.DialogFragment(), View.OnClickListener {

    //region Fields

    private lateinit var listener: OnNoNetworkConnectionDialogListener

    //endregion

    //region Override Methods && Callbacks

    override fun onAttach(context: Context) {
        super.onAttach(context)
        try {
            this.listener = context as OnNoNetworkConnectionDialogListener
        } catch (e: ClassCastException) {
            Crashlytics.logException(e)
            throw ClassCastException("$context must implement OnNoNetworkConnectionDialogListener")
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.dialog_no_network_connection, container)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setCustomBackground()

        btnRetry.setOnClickListener(this)
        btnExit.setOnClickListener(this)
    }

    override fun onStart() {
        super.onStart()
        dialog?.run {
            setCancelable(false)
            setCanceledOnTouchOutside(false)

            window?.run {
                val width = ViewGroup.LayoutParams.MATCH_PARENT
                val height = ViewGroup.LayoutParams.MATCH_PARENT
                setLayout(width, height)
            }
        }
    }

    override fun onClick(v: View) {
        when (v.id) {
            R.id.btnRetry -> retryJoinConference()
            R.id.btnExit -> listener.exit()
        }
    }

    //endregion

    //region Public Methods

    fun enableRetry() {
        btnRetry.visibility = View.VISIBLE
    }

    fun disableRetry() {
        btnRetry.visibility = View.GONE
    }

    //endregion

    //region Private Methods

    private fun setCustomBackground() {
        dialog?.run {
            requestWindowFeature(Window.FEATURE_NO_TITLE)
            window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        }

        setStyle(STYLE_NO_FRAME, android.R.style.Theme)
    }

    private fun retryJoinConference() {
        if (NetworkConnectionUtils.isConnectedToNetwork()) {
            listener.retry()
        }
    }

    //endregion

    //region Inner Classes & Interfaces

    interface OnNoNetworkConnectionDialogListener {
        fun retry()
        fun exit()
    }

    companion object {

        private val TAG = NoNetworkConnectionDialog::class.java.simpleName

        @JvmStatic
        fun showNewInstance(fragmentManager: FragmentManager){
            var dialog = fragmentManager.findFragmentByTag(TAG)
            if (dialog != null && dialog is NoNetworkConnectionDialog) return

            dialog = NoNetworkConnectionDialog()
            dialog.showNow(fragmentManager, TAG)
        }

        @JvmStatic
        fun dismissInstance(fragmentManager: FragmentManager){
            val dialog = fragmentManager.findFragmentByTag(TAG)
            if (dialog == null || dialog !is NoNetworkConnectionDialog) return
            dialog.dismiss()
        }

        @JvmStatic
        fun enableRetryJoinOption(fragmentManager: FragmentManager){
            val dialog = fragmentManager.findFragmentByTag(TAG)
            if (dialog == null || dialog !is NoNetworkConnectionDialog) return
            dialog.enableRetry()
        }

        @JvmStatic
        fun disableRetryJoinOption(fragmentManager: FragmentManager){
            val dialog = fragmentManager.findFragmentByTag(TAG)
            if (dialog == null || dialog !is NoNetworkConnectionDialog) return
            dialog.disableRetry()
        }
    }

    //endregion
}