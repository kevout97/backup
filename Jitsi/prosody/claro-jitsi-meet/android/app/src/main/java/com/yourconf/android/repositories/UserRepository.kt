package com.yourconf.android.repositories

import com.yourconf.android.enums.UserType
import com.yourconf.android.features.models.User

class UserRepository(
        private val localUserDataSource: LocalUserDataSource
){

    fun saveUser(user: User){
        localUserDataSource.saveUser(user)
    }

    fun deleteUser(){
        localUserDataSource.deleteUser()
    }

    fun getUserType(): UserType = localUserDataSource.getUserType()

}