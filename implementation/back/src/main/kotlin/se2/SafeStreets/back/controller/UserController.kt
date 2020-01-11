package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.annotation.Secured
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.bind.annotation.*
import org.springframework.web.util.UriComponentsBuilder
import se2.SafeStreets.back.model.Dto.UserDto
import se2.SafeStreets.back.model.User
import se2.SafeStreets.back.model.UserType
import se2.SafeStreets.back.model.form.SignUpForm
import se2.SafeStreets.back.security.jwt.JWTConfigurer
import se2.SafeStreets.back.security.jwt.JWTToken
import se2.SafeStreets.back.security.jwt.TokenProvider
import se2.SafeStreets.back.service.UserService
import javax.validation.Valid

/**
 * Controller that handles user information.
 */
@RestController
@RequestMapping("/user")
class UserController(private val userService: UserService, private val tokenProvider: TokenProvider) {

    @PostMapping("/sign-up")
    fun signUp(@Valid @RequestBody form: SignUpForm): ResponseEntity<Any> {
        if(form.password.length < 8) return ResponseEntity.badRequest().build()
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
        if(user.password.length < 8) return ResponseEntity.badRequest().build()
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
    fun modifyCurrentUser(@Valid @RequestBody userForm: UserDto): ResponseEntity<Any> {
        val result: User? = userService.updateCurrent(userForm)
        return result?.let {user ->
            val authentication = UsernamePasswordAuthenticationToken(user.email, user.password, mutableListOf(SimpleGrantedAuthority(user.type.toString())))
            SecurityContextHolder.getContext().authentication = authentication
            val jwt = tokenProvider.createToken(authentication)
            val headers = HttpHeaders()
            headers.add(JWTConfigurer.AUTHORIZATION_HEADER, "Bearer $jwt")
            return ResponseEntity<Any>(JWTToken(jwt), headers, HttpStatus.OK)
        } ?: ResponseEntity.notFound().build()
    }
}