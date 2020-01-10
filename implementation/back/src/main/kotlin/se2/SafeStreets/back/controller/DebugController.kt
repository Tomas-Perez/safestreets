package se2.SafeStreets.back.controller

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import se2.SafeStreets.back.StartUp

/**
 * Controller with utility methods for debug purposes.
 */
@RestController
@RequestMapping("/debug")
class DebugController(val startUp: StartUp) {

    @GetMapping("/reinitializedb")
    fun reinitializedb(): ResponseEntity<Any> {
        startUp.reinitializedb()
        return ResponseEntity.noContent().build()
    }

}