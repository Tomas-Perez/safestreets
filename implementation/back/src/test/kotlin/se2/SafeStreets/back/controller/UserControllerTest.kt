package se2.SafeStreets.back.controller

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import se2.SafeStreets.back.AbstractTest
import se2.SafeStreets.back.model.Dto.UserDto
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.model.form.SignUpForm
import se2.SafeStreets.back.repository.UserRepository

/**
 * Tests for the UserController.
 */
class UserControllerTest(
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
    fun getUserByIdShouldReturnUser() {
        val uri = "/user"
        val user = data.user1
        val getUserResult = mvc.perform(MockMvcRequestBuilders.get("$uri/${user.id}")
                .accept(MediaType.APPLICATION_JSON_VALUE)).andReturn()
        val getUserContent = getUserResult.response.contentAsString
        val gottenUser = super.fullMapFromJson(getUserContent, User::class.java)
        assertEquals(user.id, gottenUser.id)
    }

    @Test
    fun getNonexistentUserByIdShouldReturnNotFound() {
        val uri = "/user"
        val user = data.user1
        userRepository.delete(user)
        val getUserResult = mvc.perform(MockMvcRequestBuilders.get("$uri/${user.id}")
                .accept(MediaType.APPLICATION_JSON_VALUE)).andReturn()
        val status = getUserResult.response.status
        assertEquals(404, status)
    }

    @Test
    fun signUpShouldCreateUser() {
        val uri = "/user/sign-up"
        val form = SignUpForm("test1", "testlast", "testusername", "test@test.com", "password")
        val mvcResult = mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(form))).andReturn()
        val status = mvcResult.response.status
        assertEquals(204, status)
        assertNotNull(userRepository.findFirstByEmailAndActiveIsTrue("test@test.com"))
    }

    @Test
    @WithMockUser(username = "admin1@mail.com", roles = ["ADMIN"])
    fun createUserShouldBeCreated() {
        val uri = "/user"
        val user = User("test@mail.com", "testusername", "password", "test1", "testlast1", UserType.USER)
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(user)))
                .andExpect(status().isCreated)
        assertNotNull(userRepository.findFirstByEmailAndActiveIsTrue("test@mail.com"))
    }

    @Test
    @WithMockUser(username = "user1@mail.com")
    fun getCurrentUserShouldReturnUser1() {
        val uri = "/user/me"
        val getCurrentResult = mvc.perform(MockMvcRequestBuilders.get(uri)
                .accept(MediaType.APPLICATION_JSON_VALUE))
                .andExpect(status().isOk)
                .andReturn()
        val getCurrentContent = getCurrentResult.response.contentAsString
        val gottenUser = super.fullMapFromJson(getCurrentContent, UserDto::class.java)
        assertEquals(data.user1.id, gottenUser.id)
    }

}

