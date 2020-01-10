package se2.SafeStreets.back.controller

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import se2.SafeStreets.back.service.ApiKeyService
import se2.SafeStreets.back.service.UserService

/**
 * Controller that handles the generation and queries of api keys.
 */
@RestController
@RequestMapping("/api-key")
class ApiKeyController(private val userService: UserService, private val apiKeyService: ApiKeyService) {

    @GetMapping("/me")
    fun getCurrentApiKey(): ResponseEntity<String> {
        return userService.findCurrent()?.let {
            val result = apiKeyService.getApiKeyByUserId(it.id!!)
            return ResponseEntity.ok(result)
        } ?: ResponseEntity.notFound().build()
    }

}
