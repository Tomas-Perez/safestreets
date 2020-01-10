package se2.SafeStreets.back.model

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.JsonSerializer
import com.fasterxml.jackson.databind.SerializerProvider
import org.bson.types.ObjectId
import java.io.IOException

/**
 * Object id serializer to write them as a string when mapping to json.
 */
class ObjectIDSerializer : JsonSerializer<ObjectId?>() {
    @Throws(IOException::class, JsonProcessingException::class)
    override fun serialize(objid: ObjectId?, jsongen: JsonGenerator, provider: SerializerProvider) {
        if (objid == null) {
            jsongen.writeNull()
        } else {
            jsongen.writeString(objid.toString())
        }
    }
}