package se2.SafeStreets.back.controller

import org.apache.tomcat.util.http.fileupload.FileUtils
import org.bson.types.ObjectId
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
import se2.SafeStreets.back.model.Dto.ViolationReportDto
import se2.SafeStreets.back.model.form.BoundsQueryForm
import se2.SafeStreets.back.model.form.RadiusQueryForm
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
        lateinit var report1: ViolationReport
        lateinit var report2: ViolationReport

        fun setup() {
            admin1 = User("admin1@mail.com", "admin1", BCrypt.hashpw("pass", BCrypt.gensalt()), "Admin", "last", UserType.ADMIN)
            user1 = User("user1@mail.com", "username1", BCrypt.hashpw("pass1", BCrypt.gensalt()), "User1", "last1", UserType.USER)
            user2 = User("user2@mail.com", "username2", BCrypt.hashpw("pass2", BCrypt.gensalt()), "User2", "last2", UserType.USER)
            user3 = User("user3@mail.com", "username3", BCrypt.hashpw("pass3", BCrypt.gensalt()), "User3", "last3", UserType.USER)
            user4 = User("user4@mail.com", "username4", BCrypt.hashpw("pass4", BCrypt.gensalt()), "User4", "last4", UserType.USER)
            user5 = User("user5@mail.com", "username5", BCrypt.hashpw("pass5", BCrypt.gensalt()), "User5", "last5", UserType.USER)
            user6 = User("user6@mail.com", "username6", BCrypt.hashpw("pass6", BCrypt.gensalt()), "User6", "last6", UserType.USER)
            userRepository.save(admin1)
            userRepository.save(user1)
            userRepository.save(user2)
            userRepository.save(user3)
            userRepository.save(user4)
            userRepository.save(user5)
            userRepository.save(user6)

            report1 = ViolationReport(user2.id!!,"EX215GC", "bad parking", LocalDateTime.now(), ViolationType.PARKING, Location(arrayOf(45.479183, 9.225708)))
            report1.status = ViolationReportStatus.REVIEW
            val image1Id = ObjectId.get()
            report1.licenseImage = Image(image1Id, image1Id.toHexString())
            violationRepository.save(report1)

            report2 = ViolationReport(user3.id!!,"AG310PX", "", LocalDateTime.now(), ViolationType.POOR_CONDITION, Location(arrayOf(47.5681668,10.1290574)))
            report2.status = ViolationReportStatus.HIGH_CONFIDENCE
            val image2Id = ObjectId.get()
            report2.licenseImage = Image(image2Id, image2Id.toHexString())
            violationRepository.save(report2)
        }

        fun rollback(){
            userRepository.deleteAll()
            violationRepository.deleteAll()
            reviewRepository.deleteAll()
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
    @WithMockUser(username = "user1@mail.com")
    fun submitReportShouldReturnCreated() {
        val uri = "/violation"
        val report = ViolationReportForm("EX2631", "bad parking", LocalDateTime.now(), ViolationType.PARKING, arrayOf(45.479183, 9.225708))
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(report)))
                .andExpect(status().isCreated)
    }

    @Test
    @WithMockUser(username = "user1@mail.com")
    fun uploadImageShouldSaveImage() {
        val uri = "/violation"
        val report = ViolationReport(data.user1.id!! ,"EX2631", "bad parking", LocalDateTime.now(), ViolationType.PARKING, Location(arrayOf(45.479183, 9.225708)))
        violationRepository.save(report)
        val image = ResourceUtils.getFile("classpath:../resources/test.jpg")
        val multipartFile = MockMultipartFile("file", "test.jpg", "image/jpg", image.readBytes())
        mvc.perform(MockMvcRequestBuilders.multipart("$uri/${report.id!!.toHexString()}/image")
                .file(multipartFile))
                .andExpect(status().isNoContent)
        val updatedReport = violationRepository.findByIdOrNull(report.id!!)!!
        assertEquals(1, updatedReport.images.size)

        // Clean image temporal dir
        val path = (this::class).java.classLoader.getResource("images")!!.path
                .replaceFirst("/", "")
                .replace("%20", " ")
        val dir = ResourceUtils.getFile(path)
        FileUtils.cleanDirectory(dir)
    }

    @Test
    @WithMockUser(username = "user1@mail.com")
    fun endReportShouldAnalyseIt() {
        val uri = "/violation"
        val report = ViolationReport(data.user1.id!! ,"DX034PS", "bad parking", LocalDateTime.now(), ViolationType.PARKING, Location(arrayOf(45.479183, 9.225708)))
        violationRepository.save(report)

        val image = ResourceUtils.getFile("classpath:../resources/test.jpg")
        val multipartFile = MockMultipartFile("file", "test.jpg", "image/jpg", image.readBytes())
        mvc.perform(MockMvcRequestBuilders.multipart("$uri/${report.id!!.toHexString()}/license-image")
                .file(multipartFile))
                .andExpect(status().isNoContent)

        mvc.perform(MockMvcRequestBuilders.post("$uri/${report.id!!}/done"))
                .andExpect(status().isNoContent)

        val updatedReport = violationRepository.findByIdOrNull(report.id!!)!!
        assertNotNull(updatedReport.licenseImage)
        assertEquals(ViolationReportStatus.HIGH_CONFIDENCE, updatedReport.status)
    }


    @Test
    @WithMockUser(username = "user1@mail.com")
    fun getReportsInRadiusShouldReturnCorrectReports() {
        val uri = "/violation/query/radius"
        val radiusForm = RadiusQueryForm(arrayOf(45.463213, 9.1812342), 10.0, data.report1.dateTime.minusHours(3), data.report1.dateTime.plusHours(3), arrayListOf(ViolationReportStatus.LOW_CONFIDENCE, ViolationReportStatus.REVIEW, ViolationReportStatus.HIGH_CONFIDENCE), arrayListOf(ViolationType.PARKING))
        val getReportsResult = mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(radiusForm)))
                .andExpect(status().isOk)
                .andReturn()
        val getReportsContent = getReportsResult.response.contentAsString
        val gottenReports = super.mapFromJson(getReportsContent, Array<ViolationReportDto>::class.java)
        assertEquals(1, gottenReports.size)
        assertEquals(data.report1.dateTime, gottenReports[0].dateTime)
    }

    @Test
    @WithMockUser(username = "user1@mail.com")
    fun getReportsInBoundsShouldReturnCorrectReports() {
        val uri = "/violation/query/bounds"
        val boundsForm = BoundsQueryForm(arrayOf(43.0, 8.0), arrayOf(45.5, 10.0), data.report1.dateTime.minusHours(3), data.report1.dateTime.plusHours(3), arrayListOf(ViolationReportStatus.LOW_CONFIDENCE, ViolationReportStatus.REVIEW, ViolationReportStatus.HIGH_CONFIDENCE), arrayListOf(ViolationType.PARKING))
        val getReportsResult = mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(boundsForm)))
                .andExpect(status().isOk)
                .andReturn()
        val getReportsContent = getReportsResult.response.contentAsString
        val gottenReports = super.mapFromJson(getReportsContent, Array<ViolationReportDto>::class.java)
        assertEquals(1, gottenReports.size)
        assertEquals(data.report1.dateTime, gottenReports[0].dateTime)
    }

}

