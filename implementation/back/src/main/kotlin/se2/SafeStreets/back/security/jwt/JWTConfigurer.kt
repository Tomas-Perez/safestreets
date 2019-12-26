package se2.SafeStreets.back.security.jwt

import org.springframework.security.config.annotation.SecurityConfigurerAdapter
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.DefaultSecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.stereotype.Component

@Component
class JWTConfigurer(val tokenProvider:TokenProvider): SecurityConfigurerAdapter<DefaultSecurityFilterChain, HttpSecurity>() {

    companion object {
        val AUTHORIZATION_HEADER:String = "Authorization"
    }

    override fun configure(builder: HttpSecurity) {
        val customFilter = JWTFilter(tokenProvider)
        builder.addFilterBefore(customFilter, UsernamePasswordAuthenticationFilter::class.java)
    }
}