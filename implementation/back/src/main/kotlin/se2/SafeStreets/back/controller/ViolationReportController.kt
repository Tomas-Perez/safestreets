package se2.SafeStreets.back.controller

import org.bson.types.ObjectId
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.annotation.Secured
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.util.UriComponentsBuilder
import se2.SafeStreets.back.model.Dto.ViolationReportDto
import se2.SafeStreets.back.model.form.RadiusQueryForm
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.service.ViolationService
import javax.validation.Valid

@RestController
@RequestMapping("/violation")
class ViolationReportController(val violationService: ViolationService) {

    @GetMapping("/query")
    @Secured("ROLE_ADMIN")
    fun getAllReports(): List<ViolationReport> = violationService.findAll()

    @PostMapping
    fun submitViolationReport(@Valid @RequestBody violationReportForm: ViolationReportForm, b: UriComponentsBuilder): ResponseEntity<Any> {
        val id = violationService.save(violationReportForm)
        val components = b.path("/violation/{id}").buildAndExpand(id)
        return ResponseEntity.created(components.toUri()).body(id.toHexString())
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

    @PostMapping("/{id}/done")
    fun endReport(@PathVariable("id") id: ObjectId): ResponseEntity<Any> {
        val report = violationService.findById(id)
        return report?.let {
            if(it.status != ViolationReportStatus.INCOMPLETE)
                return ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body("Report already completed.")

            val result = violationService.endReport(it)
            return if (result)
                ResponseEntity.noContent().build<Any>()
            else
                ResponseEntity.status(HttpStatus.NOT_ACCEPTABLE).body("No license plate image present.")
        } ?: ResponseEntity.notFound().build()
    }

    @PostMapping("/query/radius")
    fun getReportsInRadius(@Valid @RequestBody form: RadiusQueryForm): ResponseEntity<List<ViolationReportDto>> {
        return if (form.location.size == 2) {
            val result = violationService.findByRadius(form)
            ResponseEntity.ok(result)
        } else {
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/query/advanced/radius")
    @Secured("ROLE_ADMIN", "ROLE_MUNICIPALITY")
    fun getFullReportsInRadius(@Valid @RequestBody form: RadiusQueryForm): ResponseEntity<List<ViolationReport>> {
        return if (form.location.size == 2) {
            val result = violationService.findFullByRadius(form)
            ResponseEntity.ok(result)
        } else {
            ResponseEntity.badRequest().build()
        }
    }
}