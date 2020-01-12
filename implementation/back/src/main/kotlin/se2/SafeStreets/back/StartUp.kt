package se2.SafeStreets.back

import org.apache.tomcat.util.http.fileupload.FileUtils
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Component
import org.springframework.util.ResourceUtils
import se2.SafeStreets.back.model.*
import se2.SafeStreets.back.repository.ApiKeyRepository
import se2.SafeStreets.back.repository.ReviewRepository
import se2.SafeStreets.back.repository.UserRepository
import se2.SafeStreets.back.repository.ViolationRepository
import se2.SafeStreets.back.service.ImageAnalyser
import se2.SafeStreets.back.service.ReviewRecruiter
import se2.SafeStreets.back.service.UserService
import se2.SafeStreets.back.service.ViolationService
import java.io.File
import java.time.LocalDateTime

/**
 * Class for initialization stuff, like setting up openAlpr and database initialization.
 */
@Component
class StartUp(
        val violationRepository: ViolationRepository,
        val violationService: ViolationService,
        val reviewRecruiter: ReviewRecruiter,
        val imageAnalyser: ImageAnalyser,
        val userService: UserService,
        val apiKeyRepository: ApiKeyRepository,
        val reviewRepository: ReviewRepository,
        val userRepository: UserRepository
) {

    @Value("\${spring.profiles.active:Unknown}")
    lateinit var profile: String

    var initImgPath: String? = null

    @EventListener
    fun appReady(event: ApplicationReadyEvent) {
        if (violationService.imgDirPath == "") {
            violationService.imgDirPath = (this::class).java.classLoader.getResource("images")!!.path
                    .replaceFirst("/", "")
                    .replace("%20", " ")
        }

        var openalprPath = event.applicationContext.environment.getProperty("openalpr")
        when {
            openalprPath != null -> {
                imageAnalyser.initializeAlpr(openalprPath)
            }
            profile == "test" -> {
                openalprPath = (ImageAnalyser::class).java.classLoader.getResource("openalpr")!!.path
                        .replaceFirst("/", "")
                        .replace("%20", " ")
                imageAnalyser.initializeAlpr(openalprPath)
            }
            else -> throw RuntimeException("openalpr path not present in environment variables.")
        }

        val init = event.applicationContext.environment.getProperty("initdb")
        initImgPath = event.applicationContext.environment.getProperty("initImgPath")
        if (init != null) {
            if(init == "true") initdb()
            else if(init == "reinit") reinitializedb()
        }
    }

    fun generateUser(name: String, surname: String, type: UserType = UserType.USER): User {
        val user = User("${name.toLowerCase()}@mail.com", "${name.toLowerCase()}${surname.toLowerCase()}", "password", name, surname, type)
        userService.save(user)
        return user
    }

    fun initdb() {
        try {
            userService.save(User("admin@mail.com", "admin", "password", "Admin", "AdminLast", UserType.ADMIN))
            userService.save(User("user0@mail.com", "user1", "password1", "User1", "last1", UserType.USER))
            userService.save(User("municipality0@mail.com", "municipality1", "password1", "Muni1", "MuniLast1", UserType.MUNICIPALITY))

            generateUser("Corben", "Contreras", UserType.MUNICIPALITY)
            generateUser("Everett", "Giles", UserType.MUNICIPALITY)
            generateUser("Ismael", "Hammond", UserType.MUNICIPALITY)
            generateUser("Fallon", "Jarvis")
            generateUser("Clyde", "Peralta")
            val user1 = generateUser("Padraig", "Gallagher")
            val user2 = generateUser("Ewan", "Shepard")
            val user3 = generateUser("Fox", "Halliday")
            val user4 = generateUser("Mahek", "Maddox")
            val user5 = generateUser("Alysha", "Walsh")
            val user6 = generateUser("Zacharia", "Mcloughlin")
            val user7 = generateUser("Isma", "Drake")
            val user8 = generateUser("Abraham", "Schultz")
            val user9 = generateUser("Kris", "Kirkland")
            val user10 = generateUser("Fatema", "Gamble")
            val user11 = generateUser("Aleesha", "Workman")
            val user12 = generateUser("Aryaan", "Burton")
            val user13 = generateUser("Abdullahi", "Neill")
            val user14 = generateUser("Amira", "Ruiz")

            if (initImgPath != null) {
                val violation0 = ViolationReport(user1.id!!, "EX215GC", "The car is parked in the middle of the street", LocalDateTime.now().minusDays(2).minusHours(8).minusMinutes(25), ViolationType.PARKING, Location(arrayOf(9.225708, 45.479183)))
                val violation1 = ViolationReport(user1.id!!, "DA102GE", "Crashing cars", LocalDateTime.now().minusDays(4).minusHours(3).minusMinutes(2), ViolationType.CRASH, Location(arrayOf(9.191353, 45.465978)))
                val violation2 = ViolationReport(user2.id!!, "FH712CL", "Wont move", LocalDateTime.now().minusDays(4).minusHours(10).minusMinutes(21), ViolationType.PARKING, Location(arrayOf(8.698427, 45.384839)))
                val violation3 = ViolationReport(user3.id!!, "DX034PS", "Old car", LocalDateTime.now().minusDays(5).minusHours(7).minusMinutes(13), ViolationType.POOR_CONDITION, Location(arrayOf(9.176277, 45.457854)))
                val violation4 = ViolationReport(user4.id!!, "FX213AH", "Car in bad condition", LocalDateTime.now().minusDays(3).minusHours(6).minusMinutes(48), ViolationType.POOR_CONDITION, Location(arrayOf(9.169583, 45.470074)))

                val violation5 = ViolationReport(user4.id!!, "EG341W2", "", LocalDateTime.now().minusDays(1).minusHours(6).minusMinutes(9), ViolationType.PARKING, Location(arrayOf(9.192506, 45.467035)))
                val violation6 = ViolationReport(user5.id!!, "BL445VR", "Look at this parking", LocalDateTime.now().minusDays(11).minusHours(9).minusMinutes(21), ViolationType.PARKING, Location(arrayOf(9.219410, 45.477851)))
                val violation7 = ViolationReport(user5.id!!, "DN424MF", "Outside the yellow line", LocalDateTime.now().minusDays(10).minusHours(2).minusMinutes(8), ViolationType.PARKING, Location(arrayOf(9.230906, 45.478392)))
                val violation8 = ViolationReport(user5.id!!, "FX932VR", "Horrible parking!", LocalDateTime.now().minusDays(2).minusHours(28).minusMinutes(11), ViolationType.PARKING, Location(arrayOf(9.217351, 45.468883)))
                val violation9 = ViolationReport(user6.id!!, "DB2388V", "This car has been here for a week", LocalDateTime.now().minusDays(9).minusHours(2).minusMinutes(51), ViolationType.PARKING, Location(arrayOf(9.211250, 45.459673)))
                val violation10 = ViolationReport(user7.id!!, "AA489KJ", "", LocalDateTime.now().minusDays(4).minusHours(1).minusMinutes(28), ViolationType.POOR_CONDITION, Location(arrayOf(9.198170, 45.459841)))
                val violation11 = ViolationReport(user7.id!!, "FK415XR", "", LocalDateTime.now().minusDays(3).minusHours(6).minusMinutes(48), ViolationType.PARKING, Location(arrayOf(9.199403, 45.466776)))
                val violation12 = ViolationReport(user8.id!!, "EAO46RB", "Incredible", LocalDateTime.now().minusDays(0).minusHours(8).minusMinutes(31), ViolationType.PARKING, Location(arrayOf(9.198545, 45.454314)))
                val violation13 = ViolationReport(user9.id!!, "EV886VB", "", LocalDateTime.now().minusDays(3).minusHours(6).minusMinutes(48), ViolationType.PARKING, Location(arrayOf(9.186791, 45.472434)))
                val violation14 = ViolationReport(user9.id!!, "EK376LT", "", LocalDateTime.now().minusDays(5).minusHours(6).minusMinutes(13), ViolationType.PARKING, Location(arrayOf(9.175809, 45.466415)))

                val violations = arrayOf(violation0, violation1, violation2, violation3, violation4, violation5, violation6, violation7, violation8, violation9, violation10, violation11, violation12, violation13, violation14)

                violations.forEach { v -> violationRepository.save(v) }

                val imageDir = File(initImgPath)
                // Files named: <violationNumber>-<isLicense>-<whatever> Example: 2-true.jpg
                for (imageFile in imageDir.listFiles()) {
                    val name = imageFile.nameWithoutExtension.split("-")
                    val index = name[0].toInt()
                    val isLicense = name[1] == "true"

                    violationService.saveImage(violations[index], imageFile, isLicense)
                }

                rigReport(violation0, 76.02543F)
                rigReport(violation4, 71.18932F)
                rigReport(violation6, 80.61874F)
                rigReport(violation7, 85.35184F)
                rigReport(violation8, 81.21505F)
                rigReport(violation9, 84.63543F)
                rigReport(violation10, 87.10189F)
                rigReport(violation11, 90.18389F)

                violations.forEach { v ->
                    if (v.status == ViolationReportStatus.INCOMPLETE) {
                        violationService.endReport(v)
                    }
                }

                completeReviews(violation4, intArrayOf(0,2,4), intArrayOf(5,8))
            }

        } catch (e: Exception) {
        }
    }

    fun completeReviews(v: ViolationReport, correct: IntArray, incorrect: IntArray) {
        val pending = reviewRepository.findAllByReportIdAndStatus(v.id!!, ReviewStatus.PENDING)
        incorrect.forEach {
            pending[it].let { p ->
                val revuser = userRepository.findByIdOrNull(p.userId)!!
                val last = v.licensePlate.substring(4, v.licensePlate.length)
                reviewRecruiter.submitReview(revuser, p.id, "$last${v.licensePlate.take(4)}", true)
            }
        }
        correct.forEach {
            pending[it].let { p ->
                val revuser = userRepository.findByIdOrNull(p.userId)!!
                reviewRecruiter.submitReview(revuser, p.id, v.licensePlate, true)
            }
        }
    }

    fun rigReport(v: ViolationReport, c: Float) {
        v.confidence = c
        if (c >= 80) {
            v.status = ViolationReportStatus.HIGH_CONFIDENCE
            violationRepository.save(v)
        } else {
            v.status = ViolationReportStatus.REVIEW
            violationRepository.save(v)
            reviewRecruiter.sendForReview(v)
        }
    }

    fun reinitializedb() {
        userRepository.deleteAll()
        reviewRepository.deleteAll()
        apiKeyRepository.deleteAll()
        violationRepository.deleteAll()
        FileUtils.cleanDirectory(ResourceUtils.getFile(violationService.imgDirPath))
        initdb()
    }

}