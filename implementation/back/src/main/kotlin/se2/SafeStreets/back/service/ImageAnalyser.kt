package se2.SafeStreets.back.service

import com.openalpr.jni.Alpr
import org.springframework.stereotype.Component
import se2.SafeStreets.back.model.RecognisedLicense

/**
 * Image analysing through openAlpr.
 */
@Component
class ImageAnalyser {

    lateinit var alpr: Alpr

    fun initializeAlpr(path: String) {
        alpr = Alpr("eu", "$path/runtime_data/config/default.conf", "$path/runtime_data")
        alpr.setTopN(15)
    }

    fun analyse(imagePath: String): List<RecognisedLicense> {
        val result: ArrayList<RecognisedLicense> = ArrayList()
        val alprResults = alpr.recognize(imagePath)
        //System.out.format("  %-15s%-8s\n", "Plate Number", "Confidence")
        for (plates in alprResults.plates) {
            for (plate in plates.topNPlates) {
                result.add(RecognisedLicense(plate.characters, plate.overallConfidence))
                //print("  * ")
                //System.out.format("%-15s%-8f\n", plate.characters, plate.overallConfidence)
            }
        }
        return result
    }
}