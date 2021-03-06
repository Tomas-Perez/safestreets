package se2.SafeStreets.back.service

import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.crypto.bcrypt.BCrypt
import org.springframework.stereotype.Service
import se2.SafeStreets.back.repository.UserRepository

/**
 * Service for authentication related actions.
 */
@Service
class AuthService(val userRepository: UserRepository): AuthenticationProvider {

    override fun authenticate(authentication: Authentication): Authentication {

        val email = authentication.name
        val password = authentication.credentials.toString()

        return userRepository.findFirstByEmailAndActiveIsTrue(email)?.let { user ->
            if(BCrypt.checkpw(password, user.password)) {
                val authorities: ArrayList<GrantedAuthority> = ArrayList()
                authorities.add(SimpleGrantedAuthority(user.type.toString()))
                return UsernamePasswordAuthenticationToken(email, password, authorities)
            } else {
                throw BadCredentialsException("Invalid credentials")
            }
        } ?: throw BadCredentialsException("Invalid credentials")
    }

    fun checkEmail(email:String): Boolean {
        return userRepository.findFirstByEmailAndActiveIsTrue(email) != null
    }

    override fun supports(authentication: Class<*>?): Boolean {
        return authentication?.equals(UsernamePasswordAuthenticationToken::class) ?: false
    }

}