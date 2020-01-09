package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.beans.factory.annotation.Value
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import se2.SafeStreets.back.model.Dto.ViolationReportDto
import se2.SafeStreets.back.model.Image
import se2.SafeStreets.back.model.Location
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.form.BoundsQueryForm
import se2.SafeStreets.back.model.form.RadiusQueryForm
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.repository.ViolationRepository
import java.io.File

@Service
class ViolationService(
        val userService: UserService,
        val violationRepository: ViolationRepository,
        val imageAnalyser: ImageAnalyser,
        val reviewRecruiter: ReviewRecruiter
        ) {


    @Value("\${imgpath}")
    lateinit var imgDirPath: String

    fun save(violationForm: ViolationReportForm): ObjectId {
        val user = userService.findCurrentOrException()
        val violation = ViolationReport(user.id!!, violationForm.licensePlate.toUpperCase(), violationForm.description, violationForm.dateTime, violationForm.type, Location(violationForm.location))
        violationRepository.save(violation)
        return violation.id!!
    }

    fun findById(id: ObjectId): ViolationReport? = violationRepository.findByIdOrNull(id)

    fun findAll(): List<ViolationReport> = violationRepository.findAll()

    fun saveImage(report: ViolationReport, file: MultipartFile, isLicense: Boolean) {
        val id = ObjectId.get()
        val image = Image(id, id.toHexString())
        val destFile = File("$imgDirPath/${image.name}")
        file.transferTo(destFile)
        if (isLicense)
            report.licenseImage = image
        else
            report.images.add(image)
        violationRepository.save(report)
    }

    fun saveImage(report: ViolationReport, file: File, isLicense: Boolean) {
        val id = ObjectId.get()
        val image = Image(id, id.toHexString())
        val destFile = File("$imgDirPath/${image.name}")
        file.copyTo(destFile)
        if (isLicense)
            report.licenseImage = image
        else
            report.images.add(image)
        violationRepository.save(report)
    }

    fun endReport(report: ViolationReport): Boolean {
        report.licenseImage?.let {
            val reportLicense = report.licensePlate
            val recognisedPlates = imageAnalyser.analyse("$imgDirPath/${it.name}")
            for (plate in recognisedPlates) {
                if(plate.license == reportLicense) {
                    report.confidence = plate.confidence
                    if (plate.confidence >= 80) {
                        // valid
                        report.status = ViolationReportStatus.HIGH_CONFIDENCE
                        violationRepository.save(report)
                    } else {
                        // send for review
                        report.status = ViolationReportStatus.REVIEW
                        violationRepository.save(report)
                        reviewRecruiter.sendForReview(report)
                    }
                    return true
                }
            }
            report.status = ViolationReportStatus.INVALID
            violationRepository.save(report)
            return true
        } ?: return false
    }

    fun findByRadius(form: RadiusQueryForm): List<ViolationReportDto> {
        val reports = violationRepository.findAllInRadius(form.southWest[0], form.southWest[1], form.northEast, form.from, form.to, form.status, form.types)
        return reports.map { ViolationReportDto.fromReport(it) }
    }

    fun findFullByRadius(form: RadiusQueryForm): List<ViolationReport> {
        return violationRepository.findAllInRadius(form.southWest[0], form.southWest[1], form.northEast, form.from, form.to, form.status, form.types)
    }

    fun findByBounds(form: BoundsQueryForm): List<ViolationReportDto> {
        val reports = violationRepository.findAllInBounds(form.southWest[0], form.southWest[1], form.northEast[0], form.northEast[1], form.from, form.to, form.status, form.types)
        return reports.map { ViolationReportDto.fromReport(it) }
    }

    fun findFullByBounds(form: BoundsQueryForm): List<ViolationReport> {
        return violationRepository.findAllInBounds(form.southWest[0], form.southWest[1], form.northEast[0], form.northEast[1], form.from, form.to, form.status, form.types)
    }

}