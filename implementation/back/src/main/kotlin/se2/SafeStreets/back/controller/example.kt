package se2.SafeStreets.back.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
class ArticleController {

    @GetMapping("/test")
    fun getTest(): List<String> =
            listOf("hello", "there")

}