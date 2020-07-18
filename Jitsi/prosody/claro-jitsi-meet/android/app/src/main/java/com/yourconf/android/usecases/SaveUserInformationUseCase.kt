package com.yourconf.android.usecases

import com.yourconf.android.features.models.User
import com.yourconf.android.repositories.UserRepository

class SaveUserInformationUseCase(
        private val userRepository: UserRepository
) {

    fun invoke(user: User){
        userRepository.saveUser(user)
    }

}