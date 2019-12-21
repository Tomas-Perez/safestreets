package se2.SafeStreets.back.controller

import org.springframework.boot.web.servlet.error.DefaultErrorAttributes
import org.springframework.dao.DuplicateKeyException
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.context.request.WebRequest
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler
import java.util.regex.Pattern

@RestControllerAdvice
class ExceptionMapper: ResponseEntityExceptionHandler() {

    private val msgPattern = Pattern.compile("E11000 duplicate key error collection:.*index: (.*) dup")

    @ExceptionHandler(value = [DuplicateKeyException::class])
    protected fun handleException(ex: DuplicateKeyException, request: WebRequest): ResponseEntity<Any> {
        val errorAttributes = DefaultErrorAttributes().getErrorAttributes(request, false)

        val message = ex.message
        var duplicateKey = "Duplicated key"
        if (message != null) {
            val m = msgPattern.matcher(message)
            duplicateKey += if (m.find()) String.format(": %s", m.group(1)) else ""
        }

        errorAttributes["status"] = HttpStatus.CONFLICT.value()
        errorAttributes["message"] = duplicateKey
        errorAttributes["error"] = HttpStatus.CONFLICT.reasonPhrase
        return handleExceptionInternal(ex, errorAttributes, HttpHeaders(), HttpStatus.CONFLICT, request)
    }

    @ExceptionHandler(value = [BadCredentialsException::class])
    protected fun handleException(ex: BadCredentialsException, request: WebRequest?): ResponseEntity<Any?>? {
        val errorAttributes = DefaultErrorAttributes().getErrorAttributes(request, false)
        errorAttributes["status"] = HttpStatus.UNAUTHORIZED.value()
        errorAttributes["message"] = ex.message
        errorAttributes["error"] = HttpStatus.UNAUTHORIZED.reasonPhrase
        return handleExceptionInternal(ex, errorAttributes, HttpHeaders(), HttpStatus.UNAUTHORIZED, request!!)
    }
}
