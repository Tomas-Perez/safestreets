package se2.SafeStreets.back.controller

import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.bind.annotation.*
import se2.SafeStreets.back.model.form.LoginForm
import se2.SafeStreets.back.security.jwt.JWTConfigurer
import se2.SafeStreets.back.security.jwt.JWTToken
import se2.SafeStreets.back.security.jwt.TokenProvider
import javax.validation.Valid

@RestController
@RequestMapping("/auth")
class AuthController(val tokenProvider: TokenProvider, val authenticationProvider: AuthenticationProvider) {

    @PostMapping
    fun authenticate(@Valid @RequestBody loginForm: LoginForm): ResponseEntity<Any> {
        val authenticationToken = UsernamePasswordAuthenticationToken(loginForm.username, loginForm.password)
        val authentication = authenticationProvider.authenticate(authenticationToken)
        SecurityContextHolder.getContext().authentication = authentication
        val jwt = tokenProvider.createToken(authentication)
        val headers = HttpHeaders()
        headers.add(JWTConfigurer.AUTHORIZATION_HEADER, "Bearer $jwt")
        return ResponseEntity(JWTToken(jwt), headers, HttpStatus.OK)
    }


    @GetMapping("/ping")
    fun ping(): String = "pong"
}


