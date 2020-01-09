package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.data.repository.findByIdOrNull
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.stereotype.Service
import se2.SafeStreets.back.model.Dto.UserDto
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.repository.UserRepository

@Service
class UserService(private val userRepository: UserRepository) {

    fun findAll(): List<User> {
        return userRepository.findAllByActiveIsTrue()
    }

    fun findById(id: ObjectId): User? = userRepository.findByIdOrNull(id)

    fun save(user: User): ObjectId {
        user.password = BCrypt.hashpw(user.password, BCrypt.gensalt())
        userRepository.save(user)
        return user.id!!
    }

    fun findCurrent(): User? {
        val email = (SecurityContextHolder.getContext().authentication.principal as org.springframework.security.core.userdetails.User).username
        return userRepository.findFirstByEmailAndActiveIsTrue(email)
    }

    fun findCurrentOrException(): User {
        return findCurrent()?.let { it } ?: throw NoSuchElementException("User does not exist.")
    }

    fun updateCurrent(userForm: UserDto): User? {
        val optUser = findCurrent()
        optUser?.let { user ->
            user.name = userForm.name
            user.surname = userForm.surname
            user.email = userForm.email
            userRepository.save(user)
            return user
        }
        return null
    }
}