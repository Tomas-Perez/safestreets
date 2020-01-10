package se2.SafeStreets.back.security


import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.http.HttpStatus
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.authentication.HttpStatusEntryPoint
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import se2.SafeStreets.back.security.ApiKeyFilter.ApiKeyConfigurer
import se2.SafeStreets.back.security.jwt.JWTConfigurer
import se2.SafeStreets.back.service.ApiKeyService
import se2.SafeStreets.back.service.AuthService
import se2.SafeStreets.back.service.UserService

/**
 * Spring security configuration.
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true)
class SecurityConfiguration {

    /**
     * Jason Web Token chain configuration.
     */
    @Configuration
    @Order(2)
    class JWTSecurityConfiguration(val jwtConfigurer: JWTConfigurer, val authService: AuthService): WebSecurityConfigurerAdapter() {

        @Throws(Exception::class)
        override fun configure(http: HttpSecurity) {
            http
                    .exceptionHandling()
                    .authenticationEntryPoint(HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
                    .and()
                    .csrf()
                    .disable()
                    .headers()
                    .frameOptions()
                    .disable()
                    .and()
                    .sessionManagement()
                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    .authorizeRequests()
                    .antMatchers("/user/sign-up").permitAll()
                    .antMatchers("/auth/**").permitAll()
                    .anyRequest().authenticated()
                    .and()
                    .apply(jwtConfigurer)
                    .and()
                    .cors()
        }

        override fun configure(auth: AuthenticationManagerBuilder) {
            auth.authenticationProvider(authService)
        }
    }

    /**
     * Jason Web Token and ApiKey chain configuration.
     */
    @Configuration
    @Order(1)
    class ApiKeySecurityConfiguration(val authService: AuthService, val userService: UserService, val jwtConfigurer: JWTConfigurer, val apiKeyService: ApiKeyService): WebSecurityConfigurerAdapter() {

        @Throws(Exception::class)
        override fun configure(http: HttpSecurity) {
            http
                    .antMatcher("/violation/query/**")
                    .exceptionHandling()
                    .authenticationEntryPoint(HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
                    .and()
                    .csrf()
                    .disable()
                    .headers()
                    .frameOptions()
                    .disable()
                    .and()
                    .sessionManagement()
                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                    .and()
                    .authorizeRequests()
                    .antMatchers("/violation/query/**").authenticated()
                    .and()
                    .apply(jwtConfigurer)
                    .and()
                    .apply(apiKeyConfigurerAdapter())
                    .and()
                    .cors()
        }

        private fun apiKeyConfigurerAdapter(): ApiKeyConfigurer {
            return ApiKeyConfigurer(userService, apiKeyService)
        }

        override fun configure(auth: AuthenticationManagerBuilder) {
            auth.authenticationProvider(authService)
        }
    }


    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource? {
        val configuration = CorsConfiguration()
        configuration.allowedOrigins = listOf("*")
        configuration.allowedMethods = listOf("*")
        configuration.allowCredentials = true
        configuration.allowedHeaders = listOf("*")
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", configuration)
        return source
    }
}
