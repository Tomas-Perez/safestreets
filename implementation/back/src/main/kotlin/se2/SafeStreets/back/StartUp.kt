package se2.SafeStreets.back

import org.apache.tomcat.util.http.fileupload.FileUtils
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
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
        val user = User("${name.toLowerCase()}@mail.com", "${name.toLowerCase()}${surname.toLowerCase()}", "pass", name, surname, type)
        userService.save(user)
        return user
    }

    fun initdb() {
        try {
            userService.save(User("admin@mail.com", "admin", "pass", "Admin", "AdminLast", UserType.ADMIN))
            userService.save(User("user0@mail.com", "user1", "pass1", "User1", "last1", UserType.USER))
            userService.save(User("municipality0@mail.com", "municipality1", "pass1", "Muni1", "MuniLast1", UserType.MUNICIPALITY))

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
                val violation4 = ViolationReport(user4.id!!, "KX618KJ", "", LocalDateTime.now().minusDays(3).minusHours(6).minusMinutes(48), ViolationType.PARKING, Location(arrayOf(9.169583, 45.470074)))

                violationRepository.save(violation0)
                violationRepository.save(violation1)
                violationRepository.save(violation2)
                violationRepository.save(violation3)
                violationRepository.save(violation4)

                val violations = arrayOf(violation0, violation1, violation2, violation3, violation4)

                val imageDir = File(initImgPath)
                // Files named: <violationNumber>-<isLicense>-<whatever> Example: 2-true.jpg
                for (imageFile in imageDir.listFiles()) {
                    val name = imageFile.nameWithoutExtension.split("-")
                    val index = name[0].toInt()
                    val isLicense = name[1] == "true"

                    violationService.saveImage(violations[index], imageFile, isLicense)
                }

                violations.forEach { v ->
                    if (v.id == violation0.id) {
                        v.confidence = 76.02543F
                        v.status = ViolationReportStatus.REVIEW
                        violationRepository.save(v)
                        reviewRecruiter.sendForReview(v)
                    } else {
                        v.licenseImage?.let { violationService.endReport(v) }
                    }
                }
            }

        } catch (e: Exception) {
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