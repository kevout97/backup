package com.yourconf.android.repositories

import com.yourconf.android.enums.UserType
import com.yourconf.android.features.models.User

interface LocalUserDataSource {
    fun saveUser(user: User)
    fun deleteUser()
    fun getUserType(): UserType
}