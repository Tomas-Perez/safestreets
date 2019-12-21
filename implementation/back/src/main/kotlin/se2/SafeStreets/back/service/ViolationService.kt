package se2.SafeStreets.back.service

import org.bson.types.ObjectId
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.ApplicationContext
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import se2.SafeStreets.back.model.Image
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.form.ViolationReportForm
import se2.SafeStreets.back.repository.ViolationRepository
import java.io.File

@Service
class ViolationService(
        val userService: UserService,
        val violationRepository: ViolationRepository
        ) {


    @Value("\${imgpath:}")
    lateinit var imgDirPath: String

    fun save(violationForm: ViolationReportForm): ObjectId {
        val user = userService.findCurrentOrException()
        val violation = ViolationReport(user.id!!, violationForm.licensePlate, violationForm.description, violationForm.dateTime, violationForm.type)
        violationRepository.save(violation)
        return violation.id!!
    }

    fun findById(id: ObjectId): ViolationReport? = violationRepository.findByIdOrNull(id)

    fun findAll(): List<ViolationReport> = violationRepository.findAll()

    fun saveImage(report: ViolationReport, file: MultipartFile, isLicense: Boolean) {
        val id = ObjectId.get()
        val image = Image(id, id.toHexString())
        //TODO png is just for testing here, remove it
        val destFile = File("$imgDirPath\\${image.name}.png")
        file.transferTo(destFile)
        if (isLicense)
            report.licenseImage = image
        else
            report.images.add(image)
        violationRepository.save(report)
    }

}