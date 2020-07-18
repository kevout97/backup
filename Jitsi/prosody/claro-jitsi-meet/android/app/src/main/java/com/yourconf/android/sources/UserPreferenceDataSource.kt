package com.yourconf.android.sources

import android.content.SharedPreferences
import android.util.Log
import com.yourconf.android.enums.UserType
import com.yourconf.android.features.models.User
import com.yourconf.android.repositories.LocalUserDataSource
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_AUTH
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_DISPLAY_NAME
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_EMAIL
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_LANGUAGE
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_TYPE
import com.yourconf.android.utils.Constants.PREFERENCE_KEY_USER_VIRTUAL_NUMBER

class UserPreferenceDataSource(
        private val preferences: SharedPreferences
): LocalUserDataSource {

    override fun saveUser(user: User) {
        Log.d(TAG, "saveUser user -> $user")
        preferences.edit().run {
            putString(PREFERENCE_KEY_USER_DISPLAY_NAME, user.displayName)
            putString(PREFERENCE_KEY_USER_EMAIL, user.email)
            putString(PREFERENCE_KEY_USER_VIRTUAL_NUMBER, user.virtualNumber)
            putString(PREFERENCE_KEY_USER_TYPE, user.userType)
            putString(PREFERENCE_KEY_USER_LANGUAGE, user.language)
            putString(PREFERENCE_KEY_USER_AUTH, user.auth)
            apply()
        }
    }

    override fun deleteUser() {
        Log.d(TAG, "deleteUser")
        preferences.edit().run {
            clear()
            apply()
        }
    }

    override fun getUserType(): UserType = when(preferences.getString(PREFERENCE_KEY_USER_TYPE, "")){
        "guest" -> UserType.GUEST
        "user" -> UserType.USER
        else -> UserType.GUEST
    }

    companion object {

        private val TAG: String = UserPreferenceDataSource::class.java.simpleName

    }
}