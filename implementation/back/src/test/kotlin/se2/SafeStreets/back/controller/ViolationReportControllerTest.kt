package se2.SafeStreets.back.controller

import org.apache.tomcat.util.http.fileupload.FileUtils
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.MediaType
import org.springframework.mock.web.MockMultipartFile
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.util.ResourceUtils
import se2.SafeStreets.back.AbstractTest
import se2.SafeStreets.back.model.*
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.repository.ReviewRepository
import se2.SafeStreets.back.repository.UserRepository
import se2.SafeStreets.back.repository.ViolationRepository
import java.time.LocalDateTime

class ViolationReportControllerTest(
        @Autowired val userRepository: UserRepository,
        @Autowired val violationRepository: ViolationRepository,
        @Autowired val reviewRepository: ReviewRepository
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
            violationRepository.deleteAll()
            reviewRepository.deleteAll()
            // Clean image temporal dir
            val path = (this::class).java.classLoader.getResource("images")!!.path
                    .replaceFirst("/", "")
                    .replace("%20", " ")
            val dir = ResourceUtils.getFile(path)
            FileUtils.cleanDirectory(dir)
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
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(report)))
                .andExpect(status().`is`(201))
    }

    @Test
    @WithMockUser(username = "username1")
    fun uploadImageShouldSaveImage() {
        val uri = "/violation"
        val report = ViolationReport(data.user1.id!! ,"EX2631", "bad parking", LocalDateTime.now(), ViolationType.PARKING)
        violationRepository.save(report)
        val image = ResourceUtils.getFile("classpath:../resources/test.jpg")
        val multipartFile = MockMultipartFile("file", "test.jpg", "image/jpg", image.readBytes())
        mvc.perform(MockMvcRequestBuilders.multipart("$uri/${report.id!!.toHexString()}/image")
                .file(multipartFile))
                .andExpect(status().`is`(204))
        val updatedReport = violationRepository.findByIdOrNull(report.id!!)!!
        assertEquals(1, updatedReport.images.size)
    }

    @Test
    @WithMockUser(username = "username1")
    fun endReportShouldAnalyseIt() {
        val uri = "/violation"
        val report = ViolationReport(data.user1.id!! ,"EX215GC", "bad parking", LocalDateTime.now(), ViolationType.PARKING)
        violationRepository.save(report)

        val image = ResourceUtils.getFile("classpath:../resources/test.jpg")
        val multipartFile = MockMultipartFile("file", "test.jpg", "image/jpg", image.readBytes())
        mvc.perform(MockMvcRequestBuilders.multipart("$uri/${report.id!!.toHexString()}/license-image")
                .file(multipartFile))
                .andExpect(status().`is`(204))

        mvc.perform(MockMvcRequestBuilders.post("$uri/${report.id!!}/done"))
                .andExpect(status().`is`(204))

        val updatedReport = violationRepository.findByIdOrNull(report.id!!)!!
        assertNotNull(updatedReport.licenseImage)
        assertEquals(ViolationReportStatus.HIGH_CONFIDENCE, updatedReport.status)
    }

}

