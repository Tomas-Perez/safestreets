package se2.SafeStreets.back.security.jwt

import io.jsonwebtoken.*
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.stereotype.Component
import se2.SafeStreets.back.service.AuthService
import java.util.*
import java.util.stream.Collectors
import javax.annotation.PostConstruct

@Component
class TokenProvider(val authService: AuthService) {
    val log: Logger? = LoggerFactory.getLogger(TokenProvider::class.java)
    val AUTHORITIES_KEY:String = "auth"
    lateinit var secretKey:String

    @PostConstruct
    fun init() {
        this.secretKey = "SECRET"
    }

    fun createToken(authentication: Authentication): String {
        val authorities = authentication.authorities.stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.joining(","))

        val now = Date().time
        val time = 86400000
        val validity = Date(now + time)

        return Jwts.builder()
            .setSubject(authentication.name)
            .setExpiration(validity)
            .claim(AUTHORITIES_KEY, authorities)
            .signWith(SignatureAlgorithm.HS512, secretKey)
            .compact()
    }

    fun getAuthentication(token: String): Authentication {
        val claims = Jwts.parser()
                .setSigningKey(secretKey)
                .parseClaimsJws(token)
                .body
        val authorities: Collection<GrantedAuthority?> = Arrays.stream(claims[AUTHORITIES_KEY].toString().split(",").toTypedArray())
                .map { role: String -> SimpleGrantedAuthority("ROLE_$role") }
                .collect(Collectors.toList())
        val principal = User(claims.subject, "", authorities)
        return UsernamePasswordAuthenticationToken(principal, token, authorities)
    }

    fun validateToken(authToken: String): Boolean {
        try {
            val claims = Jwts.parser().setSigningKey(secretKey).parseClaimsJws(authToken)
            return !claims.body.expiration.before(Date()) &&
                    authService.checkUsername(claims.body.subject)
        } catch (e: SignatureException) {
            log?.info("Invalid JWT signature.")
            log?.trace("Invalid JWT signature trace: {}", e)
        } catch (e: MalformedJwtException) {
            log?.info("Invalid JWT token.")
            log?.trace("Invalid JWT token trace: {}", e)
        } catch (e: ExpiredJwtException) {
            log?.info("Expired JWT token.")
            log?.trace("Expired JWT token trace: {}", e)
        } catch (e: UnsupportedJwtException) {
            log?.info("Unsupported JWT token.")
            log?.trace("Unsupported JWT token trace: {}", e)
        } catch (e: IllegalArgumentException) {
            log?.info("JWT token compact of handler are invalid.")
            log?.trace("JWT token compact of handler are invalid trace: {}", e)
        }
        return false
    }
}