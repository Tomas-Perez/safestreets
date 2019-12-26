package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.core.MongoOperations
import org.springframework.data.mongodb.core.query.BasicQuery
import org.springframework.data.mongodb.core.query.Criteria
import org.springframework.data.mongodb.repository.MongoRepository
import se2.SafeStreets.back.model.ViolationReport
import se2.SafeStreets.back.model.ViolationType
import java.time.LocalDateTime

interface ViolationRepository: MongoRepository<ViolationReport, ObjectId>, ViolationCustomRepository

interface ViolationCustomRepository {
    fun findAllInRadius(lon: Double, lat: Double, radius: Double, from: LocalDateTime, to: LocalDateTime, types: List<ViolationType>): List<ViolationReport>
}

class ViolationRepositoryImpl(private val mongoOperations: MongoOperations): ViolationCustomRepository {
    override fun findAllInRadius(lon: Double, lat: Double, radius: Double, from: LocalDateTime, to: LocalDateTime, types: List<ViolationType>): List<ViolationReport> {
        val q = BasicQuery("{'status': {\$nin: [\"INCOMPLETE\", \"INVALID\"]}, 'location': {\$geoWithin: { \$centerSphere: [[$lon, $lat], ${radius/6378.1}]}}}")
        q.addCriteria(Criteria.where("type").`in`(types))
        q.addCriteria(Criteria.where("dateTime").gte(from).lte(to))
        return mongoOperations.find(q, ViolationReport::class.java)
    }
}