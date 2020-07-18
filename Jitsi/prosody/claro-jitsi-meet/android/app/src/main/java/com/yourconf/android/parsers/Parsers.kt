package com.yourconf.android.parsers

import com.yourconf.android.features.models.ConferenceInitData
import com.yourconf.android.features.models.User
import com.yourconf.android.utils.Constants
import org.json.JSONObject
import java.lang.Exception

object Parsers {

    @Throws(Exception::class)
    fun parseUser(json: JSONObject): User =
        User(
            displayName = json.getString(Constants.JSON_PARAMETER_USER_NAME),
            email = json.getString(Constants.JSON_PARAMETER_USER_EMAIL),
            virtualNumber = json.getString(Constants.JSON_PARAMETER_USER_VIRTUAL_NUMBER),
            userType = json.getString(Constants.JSON_PARAMETER_USER_TYPE),
            language = json.optString(Constants.JSON_PARAMETER_USER_LANGUAGE),
            auth = json.optString(Constants.JSON_PARAMETER_USER_AUTH)
        )

    @Throws(Exception::class)
    fun parseConferenceInitData(json: JSONObject): ConferenceInitData =
        ConferenceInitData(
            conferenceId = json.getString(Constants.JSON_PARAMETER_CONFERENCE_ID),
            conferenceSubject = json.getString(Constants.JSON_PARAMETER_CONFERENCE_SUBJECT),
            displayName = json.optString(Constants.JSON_PARAMETER_USER_NAME, ""),
            email = json.optString(Constants.JSON_PARAMETER_USER_EMAIL, ""),
            hasCamera = json.optBoolean(Constants.JSON_PARAMETER_CONFERENCE_HAS_CAMERA, true),
            hasMicrophone = json.optBoolean(Constants.JSON_PARAMETER_CONFERENCE_HAS_MICROPHONE, true),
            auth = json.optString(Constants.JSON_PARAMETER_USER_AUTH, ""),
            virtualNumber = json.optString(Constants.JSON_PARAMETER_USER_VIRTUAL_NUMBER),
            userType = json.optString(Constants.JSON_PARAMETER_USER_TYPE),
            language = json.optString(Constants.JSON_PARAMETER_USER_LANGUAGE)
        )

}