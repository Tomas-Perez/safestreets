package se2.SafeStreets.back.repository

import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.MongoRepository
import se2.SafeStreets.back.model.ViolationReport

interface ViolationRepository: MongoRepository<ViolationReport, ObjectId> {
}