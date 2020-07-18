package com.yourconf.android.features.models

data class User(
        val displayName: String,
        val email: String,
        val virtualNumber: String,
        val userType: String,
        val language: String,
        val auth: String?
)