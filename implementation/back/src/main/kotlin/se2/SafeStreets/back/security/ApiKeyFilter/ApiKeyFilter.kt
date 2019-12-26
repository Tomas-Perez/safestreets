package se2.SafeStreets.back.security.ApiKeyFilter

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.config.annotation.SecurityConfigurerAdapter
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.userdetails.User
import org.springframework.security.web.DefaultSecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.util.StringUtils
import org.springframework.web.filter.GenericFilterBean
import se2.SafeStreets.back.security.ApiKeyFilter.ApiKeyConfigurer.Companion.API_KEY_HEADER
import se2.SafeStreets.back.service.ApiKeyService
import se2.SafeStreets.back.service.UserService
import java.io.IOException
import javax.servlet.FilterChain
import javax.servlet.ServletException
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest

class ApiKeyFilter(private val userService: UserService, private val apiKeyService: ApiKeyService): GenericFilterBean() {

    @Throws(IOException::class, ServletException::class)
    override fun doFilter(servletRequest: ServletRequest, servletResponse: ServletResponse, filterChain: FilterChain) {
        val httpServletRequest = servletRequest as HttpServletRequest
        val key = httpServletRequest.getHeader(API_KEY_HEADER)
        if (key != null && StringUtils.hasText(key)) {
            getAuthentication(key)?.let {
                SecurityContextHolder.getContext().authentication = it
            }
        }
        filterChain.doFilter(servletRequest, servletResponse)
    }


    private fun getAuthentication(key: String): Authentication? {
        val apiKeyUser = apiKeyService.getApiKeyUserByKey(key)
        return apiKeyUser?.let {
            return userService.findById(apiKeyUser.userId)?.let {user ->
                val authorities: Collection<GrantedAuthority?> = arrayListOf(SimpleGrantedAuthority("ROLE_${user.type}"))
                val principal = User(user.username, "", authorities)
                return UsernamePasswordAuthenticationToken(principal, key, authorities)
            }
        }
    }

}

class ApiKeyConfigurer(private val userService: UserService, private val apiKeyService: ApiKeyService): SecurityConfigurerAdapter<DefaultSecurityFilterChain, HttpSecurity>() {

    companion object {
        const val API_KEY_HEADER:String = "x-api-key"
    }

    override fun configure(builder: HttpSecurity) {
        val customFilter = ApiKeyFilter(userService, apiKeyService)
        builder.addFilterBefore(customFilter, UsernamePasswordAuthenticationFilter::class.java)
    }
}
