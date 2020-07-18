package com.yourconf.android.features.models

import javax.security.auth.Subject

data class ConferenceInitData(
        val conferenceId: String,
        val conferenceSubject: String,
        val displayName: String,
        val email: String,
        val hasCamera: Boolean,
        val hasMicrophone: Boolean,
        var virtualNumber: String?,
        var userType: String?,
        var auth: String?,
        var language: String?
)