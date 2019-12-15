package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.util.UriComponentsBuilder
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.service.UserService
import javax.validation.Valid

@RestController
@RequestMapping("user")
class UserController(private val userService: UserService) {

    @GetMapping()
    fun getAllUsers(): List<User> {
        return userService.findAll()
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable("id") id:ObjectId): ResponseEntity<User> {
        val user = userService.findById(id)
        return user.map { ResponseEntity.ok(it) }.orElse(ResponseEntity.notFound().build())
    }

    @PostMapping
    fun createUser(@Valid @RequestBody user: User, b: UriComponentsBuilder): ResponseEntity<Any> {
        val id = userService.save(user)
        val components = b.path("/user/{id}").buildAndExpand(id)
        return ResponseEntity.created(components.toUri()).build<Any>()
    }

}