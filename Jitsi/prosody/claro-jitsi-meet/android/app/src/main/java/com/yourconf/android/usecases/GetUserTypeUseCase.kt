package com.yourconf.android.usecases

import com.yourconf.android.repositories.UserRepository

class GetUserTypeUseCase(
        private val userRepository: UserRepository
) {

    fun invoke() = userRepository.getUserType()

}