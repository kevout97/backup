package com.yourconf.android.states

sealed class WebViewState {
    object Congratulations: WebViewState()
    object Invitation: WebViewState()
    object Management: WebViewState()
}