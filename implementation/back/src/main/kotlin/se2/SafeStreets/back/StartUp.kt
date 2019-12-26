package se2.SafeStreets.back

import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.service.UserService
import se2.SafeStreets.back.service.ViolationService

@Component
class StartUp(
        val violationService: ViolationService,
        val userService: UserService
) {

    @EventListener
    fun appReady(event: ApplicationReadyEvent) {
        if (violationService.imgDirPath == "") {
            violationService.imgDirPath = (this::class).java.classLoader.getResource("images")!!.path
                    .replaceFirst("/", "")
                    .replace("%20", " ")
        }

        val init = event.applicationContext.environment.getProperty("initdb")
        if (init != null && init == "true") {
            try {
                userService.save(User("admin@admin.com", "admin", "pass", "Admin", "AdminLast", UserType.ADMIN))
                userService.save(User("user1@user.com", "user1", "pass1", "User1", "last1", UserType.USER))
            } catch (e: Exception) {
            }
        }
    }

}