package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.ResponseEntity
import org.springframework.security.access.annotation.Secured
import org.springframework.web.bind.annotation.*
import org.springframework.web.util.UriComponentsBuilder
import se2.SafeStreets.back.model.Dto.UserDto
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.model.form.SignUpForm
import se2.SafeStreets.back.service.UserService
import javax.validation.Valid

@RestController
@RequestMapping("/user")
class UserController(private val userService: UserService) {

    @PostMapping("/sign-up")
    fun signUp(@Valid @RequestBody form: SignUpForm): ResponseEntity<Any> {
        userService.save(User(form.email, form.username, form.password, form.name, form.surname, UserType.USER))
        return ResponseEntity.noContent().build<Any>()
    }

    @GetMapping
    fun getAllUsers(): List<User> {
        return userService.findAll()
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable("id") id: ObjectId): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return user?.let {
            ResponseEntity.ok(UserDto(it.id!!, it.email, it.username, it.name, it.surname, it.type))
        } ?: ResponseEntity.notFound().build()
    }

    @PostMapping
    @Secured("ROLE_ADMIN")
    fun createUser(@Valid @RequestBody user: User, b: UriComponentsBuilder): ResponseEntity<Any> {
        val id = userService.save(user)
        val components = b.path("/user/{id}").buildAndExpand(id)
        return ResponseEntity.created(components.toUri()).build<Any>()
    }

    @GetMapping("/me")
    fun getCurrentUser(): ResponseEntity<UserDto> {
        return userService.findCurrent()?.let {
            ResponseEntity.ok(UserDto(it.id!!, it.email, it.username, it.name, it.surname, it.type))
        } ?: ResponseEntity.notFound().build()
    }

    @PutMapping("/me")
    fun modifyCurrentUser(@Valid @RequestBody user: UserDto): ResponseEntity<Any> {
        val result: User? = userService.updateCurrent(user)
        return result?.let { ResponseEntity.noContent().build<Any>() } ?: ResponseEntity.notFound().build()
    }
}