package com.yourconf.android.features.models

data class WebViewModel(
        val isJavaScriptEnabled: Boolean,
        val isDomStorageEnabled: Boolean,
        val cacheMode: Int,
        val userAgentString: String,
        val url: String
)