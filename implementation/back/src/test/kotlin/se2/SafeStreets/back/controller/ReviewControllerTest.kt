package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.repository.findByIdOrNull
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.security.test.context.support.WithMockUser
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import se2.SafeStreets.back.AbstractTest
import se2.SafeStreets.back.model.*
import se2.SafeStreets.back.model.Dto.ReviewDto
import se2.SafeStreets.back.model.form.ReviewForm
import se2.SafeStreets.back.repository.ReviewRepository
import se2.SafeStreets.back.repository.UserRepository
import se2.SafeStreets.back.repository.ViolationRepository
import java.time.LocalDateTime

/**
 * Tests for the ReviewController.
 */
internal class ReviewControllerTest(
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
        lateinit var review1: Review

        fun setup() {
            admin1 = User("admin1@mail.com", "admin1", BCrypt.hashpw("pass", BCrypt.gensalt()), "Admin", "last", UserType.ADMIN)
            user1 = User("user1@mail.com", "username1", BCrypt.hashpw("pass1", BCrypt.gensalt()), "User1", "last1", UserType.USER)
            user1.pendingReviews = 1
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

            report1 = ViolationReport(user2.id!!,"EX215GC", "bad parking", LocalDateTime.now(), ViolationType.PARKING, Location(arrayOf(9.225708, 45.479183)))
            report1.status = ViolationReportStatus.REVIEW
            val image1Id = ObjectId.get()
            report1.licenseImage = Image(image1Id, image1Id.toHexString())
            violationRepository.save(report1)
            review1 = Review(user1.id!!, report1.id!!, ReviewStatus.PENDING)
            reviewRepository.save(review1)
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
    fun getCurrentPendingReviewsShouldReturnReviews() {
        val uri = "/review/pending/me"
        val getPendingResult = mvc.perform(MockMvcRequestBuilders.get(uri)
                .accept(MediaType.APPLICATION_JSON_VALUE))
                .andExpect(status().isOk)
                .andReturn()
        val getPendingContent = getPendingResult.response.contentAsString
        val gottenPending = super.mapFromJson(getPendingContent, Array<ReviewDto>::class.java)
        assertEquals(data.review1.id, gottenPending[0].id)
    }

    @Test
    @WithMockUser(username = "user1@mail.com")
    fun submitReviewShouldUpdateIt() {
        val uri = "/review"
        val review = data.review1
        val reviewForm = ReviewForm(review.id.toHexString(), "EX215GC", true)
        mvc.perform(MockMvcRequestBuilders.post(uri)
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(mapToJson(reviewForm)))
                .andExpect(status().isNoContent)
        val updatedReview = reviewRepository.findByIdOrNull(review.id)!!
        assertEquals(ReviewStatus.COMPLETED, updatedReview.status)
        assertEquals(reviewForm.licensePlate, updatedReview.license)
        assertEquals(reviewForm.clear, updatedReview.clear)
    }

}
