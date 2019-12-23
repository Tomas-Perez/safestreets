package se2.SafeStreets.back.controller

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import se2.SafeStreets.back.AbstractTest
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.model.ViolationType
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.repository.UserRepository
import java.time.LocalDateTime

class ViolationReportControllerTest(
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
            admin1 = User("admin1", BCrypt.hashpw("pass", BCrypt.gensalt()), "Admin", "last", UserType.ADMIN)
            user1 = User("username1", BCrypt.hashpw("pass1", BCrypt.gensalt()), "User1", "last1", UserType.USER)
            user2 = User("username2", BCrypt.hashpw("pass2", BCrypt.gensalt()), "User2", "last2", UserType.USER)
            user3 = User("username3", BCrypt.hashpw("pass3", BCrypt.gensalt()), "User3", "last3", UserType.USER)
            user4 = User("username4", BCrypt.hashpw("pass4", BCrypt.gensalt()), "User4", "last4", UserType.USER)
            user5 = User("username5", BCrypt.hashpw("pass5", BCrypt.gensalt()), "User5", "last5", UserType.USER)
            user6 = User("username6", BCrypt.hashpw("pass6", BCrypt.gensalt()), "User6", "last6", UserType.USER)
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
    @WithMockUser(username = "username1")
    fun submitReportShouldReturnCreated() {
        val uri = "/violation"
        val report = ViolationReportForm("EX2631", "bad parking", LocalDateTime.now(), ViolationType.PARKING)
        val mvcResult = mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(report))).andReturn()
        val status = mvcResult.response.status
        assertEquals(201, status)
    }

}

