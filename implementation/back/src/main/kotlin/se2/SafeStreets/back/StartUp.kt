package se2.SafeStreets.back

import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component
import se2.SafeStreets.back.service.ViolationService

@Component
class StartUp(val violationService: ViolationService) {

    @EventListener
    fun appReady(event: ApplicationReadyEvent) {
        if (violationService.imgDirPath == "") {
            violationService.imgDirPath = (ViolationService::class).java.classLoader.getResource("images")!!.path
                    .replaceFirst("/", "")
                    .replace("%20", " ")
        }
    }

}