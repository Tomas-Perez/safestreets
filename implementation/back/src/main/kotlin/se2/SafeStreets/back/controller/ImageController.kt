package se2.SafeStreets.back.controller

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import se2.SafeStreets.back.service.ViolationService
import java.io.File

/**
 * Controller that handles querying of images.
 */
@RestController
@RequestMapping("/image")
class ImageController(val violationService: ViolationService) {

    @GetMapping("/{name}", produces = ["image/png"])
    fun getImageByName(@PathVariable("name") name: String): ResponseEntity<ByteArray> {
        return try {
            val result = File("${violationService.imgDirPath}/$name")
            ResponseEntity.ok(result.readBytes())
        } catch (e: Exception) {
            ResponseEntity.notFound().build()
        }
    }

}