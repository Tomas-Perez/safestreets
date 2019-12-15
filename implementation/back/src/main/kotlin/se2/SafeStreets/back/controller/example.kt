package se2.SafeStreets.back.controller

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.service.UserService

@RestController
@RequestMapping("/api")
class ArticleController(private val userService: UserService) {

    @GetMapping("/ping")
    fun getTest(): String = "pong"

    @GetMapping()
    fun getAllUsers(): List<User> {
        return userService.findAll()
    }

}