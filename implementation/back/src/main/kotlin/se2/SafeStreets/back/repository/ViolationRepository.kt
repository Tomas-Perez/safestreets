package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.core.MongoOperations
import org.springframework.data.mongodb.core.query.BasicQuery
import org.springframework.data.mongodb.core.query.Criteria
import org.springframework.data.mongodb.repository.MongoRepository
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.ViolationReportStatus
import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

/**
 * Repository for ViolationReport objects.
 */
interface ViolationRepository: MongoRepository<ViolationReport, ObjectId>, ViolationCustomRepository

interface ViolationCustomRepository {
    fun findAllInRadius(lon: Double, lat: Double, radius: Double, from: LocalDateTime, to: LocalDateTime, status: List<ViolationReportStatus>, types: List<ViolationType>): List<ViolationReport>
    fun findAllInBounds(bllon: Double, bllat: Double, urlon: Double, urlat: Double, from: LocalDateTime, to: LocalDateTime, status: List<ViolationReportStatus>, types: List<ViolationType>): List<ViolationReport>
}

/**
 * Class that implements ViolationCustomRepository since MongoOperations injection is needed.
 */
class ViolationRepositoryImpl(private val mongoOperations: MongoOperations): ViolationCustomRepository {
    override fun findAllInRadius(lon: Double, lat: Double, radius: Double, from: LocalDateTime, to: LocalDateTime, status: List<ViolationReportStatus>, types: List<ViolationType>): List<ViolationReport> {
        val q = BasicQuery("{'location': {\$geoWithin: { \$centerSphere: [[$lon, $lat], ${radius/6378.1}]}}}")
        q.addCriteria(Criteria.where("status").`in`(status))
        q.addCriteria(Criteria.where("type").`in`(types))
        q.addCriteria(Criteria.where("dateTime").gte(from).lte(to))
        return mongoOperations.find(q, ViolationReport::class.java)
    }

    override fun findAllInBounds(bllon: Double, bllat: Double, urlon: Double, urlat: Double, from: LocalDateTime, to: LocalDateTime, status: List<ViolationReportStatus>, types: List<ViolationType>): List<ViolationReport> {
        val q = BasicQuery("{'location': {\$geoWithin: { \$box: [[$bllon, $bllat], [$urlon, $urlat]]}}}")
        q.addCriteria(Criteria.where("status").`in`(status))
        q.addCriteria(Criteria.where("type").`in`(types))
        q.addCriteria(Criteria.where("dateTime").gte(from).lte(to))
        return mongoOperations.find(q, ViolationReport::class.java)
    }
}