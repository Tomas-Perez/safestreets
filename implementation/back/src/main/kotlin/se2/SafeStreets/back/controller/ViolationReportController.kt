package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.ResponseEntity
import org.springframework.security.access.annotation.Secured
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.service.ViolationService
import javax.validation.Valid

@RestController
@RequestMapping("/violation")
class ViolationReportController(val violationService: ViolationService) {

    @GetMapping
    @Secured("ROLE_ADMIN")
    fun getAllReports(): List<ViolationReport> = violationService.findAll()

    @PostMapping
    fun submitViolationReport(@Valid @RequestBody violationReportForm: ViolationReportForm): ResponseEntity<String> {
        val id = violationService.save(violationReportForm)
        return ResponseEntity.ok(id.toHexString())
    }

    @PostMapping("/{id}/image")
    fun uploadImage(@PathVariable("id") id: ObjectId, @RequestParam("file") file: MultipartFile): ResponseEntity<Any>  {
        val report = violationService.findById(id)
        return report?.let {
            violationService.saveImage(it, file, false)
            return ResponseEntity.noContent().build<Any>()
        } ?: ResponseEntity.notFound().build()
    }

    @PostMapping("/{id}/license-image")
    fun uploadLicenseImage(@PathVariable("id") id: ObjectId, @RequestParam("file") file: MultipartFile): ResponseEntity<Any> {
        val report = violationService.findById(id)
        return report?.let {
            violationService.saveImage(it, file, true)
            return ResponseEntity.noContent().build<Any>()
        } ?: ResponseEntity.notFound().build()
    }
}