package se2.SafeStreets.back.controller

import com.fasterxml.jackson.databind.ObjectMapper
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import se2.SafeStreets.back.AbstractTest
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.model.form.LoginForm
import se2.SafeStreets.back.repository.UserRepository

/**
 * Tests for the AuthController.
 */
internal class AuthControllerTest(
        @Autowired val userRepository: UserRepository
) : AbstractTest() {

    val data: Data = Data()

    inner class Data {

        lateinit var admin1: User
        lateinit var user1: User
        lateinit var user2: User
        lateinit var user3: User
        lateinit var user4: User
        lateinit var user5: User
        lateinit var user6: User

        fun setup() {
            admin1 = User("admin1@mail.com", "admin1", BCrypt.hashpw("password", BCrypt.gensalt()), "Admin", "last", UserType.ADMIN)
            user1 = User("user1@mail.com", "username1", BCrypt.hashpw("password1", BCrypt.gensalt()), "User1", "last1", UserType.USER)
            user2 = User("user2@mail.com", "username2", BCrypt.hashpw("password2", BCrypt.gensalt()), "User2", "last2", UserType.USER)
            user3 = User("user3@mail.com", "username3", BCrypt.hashpw("password3", BCrypt.gensalt()), "User3", "last3", UserType.USER)
            user4 = User("user4@mail.com", "username4", BCrypt.hashpw("password4", BCrypt.gensalt()), "User4", "last4", UserType.USER)
            user5 = User("user5@mail.com", "username5", BCrypt.hashpw("password5", BCrypt.gensalt()), "User5", "last5", UserType.USER)
            user6 = User("user6@mail.com", "username6", BCrypt.hashpw("password6", BCrypt.gensalt()), "User6", "last6", UserType.USER)
            userRepository.save(admin1)
            userRepository.save(user1)
            userRepository.save(user2)
            userRepository.save(user3)
            userRepository.save(user4)
            userRepository.save(user5)
            userRepository.save(user6)
        }

        fun rollback(){
            userRepository.deleteAll()
        }
    }

    @BeforeEach
    fun setUpDb() {
        data.setup()
    }

    @AfterEach
    fun rollBackDb() {
        data.rollback()
    }

    @Test
    fun logInWithCorrectDataShouldReturnToken() {
        val uri = "/auth"
        val loginForm = LoginForm("user1@mail.com", "password1")
        val loginResult = mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(loginForm)))
                .andExpect(status().isOk)
                .andReturn()

        val mapper = ObjectMapper()
        val loginContent = loginResult.response.contentAsString
        val tokenJson = mapper.readTree(loginContent)

        assertTrue(tokenJson["token"].toString().isNotEmpty())
    }

    @Test
    fun logInWithIncorrectPasswordShouldReturnUnauthorized() {
        val uri = "/auth"
        val loginForm = LoginForm("user1@mail.com", "wrongPassword")
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(loginForm)))
                .andExpect(status().isUnauthorized)
    }

    @Test
    fun logInWithIncorrectUsernameShouldReturnUnauthorized() {
        val uri = "/auth"
        val loginForm = LoginForm("wrong@test.com", "password1")
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .accept(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(loginForm)))
                .andExpect(status().isUnauthorized)
    }
}
