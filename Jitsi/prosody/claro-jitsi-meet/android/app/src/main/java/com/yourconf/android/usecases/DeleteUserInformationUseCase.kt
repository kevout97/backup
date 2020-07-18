package com.yourconf.android.usecases

import com.yourconf.android.repositories.UserRepository

class DeleteUserInformationUseCase(
        private val userRepository: UserRepository
) {

    fun invoke(){
        userRepository.deleteUser()
    }

}