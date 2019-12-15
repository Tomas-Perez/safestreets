package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.stereotype.Service
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.repository.UserRepository
import java.util.*

@Service
class UserService(private val userRepository: UserRepository) {

    fun findAll(): List<User> {
        return userRepository.findAllByActiveIsTrue()
    }

    fun findById(id: ObjectId): Optional<User> = userRepository.findById(id)

    fun save(user: User): ObjectId {
        user.type = UserType.USER
        user.password = BCrypt.hashpw(user.password, BCrypt.gensalt())
        userRepository.save(user)
        return user.id!!
    }
}