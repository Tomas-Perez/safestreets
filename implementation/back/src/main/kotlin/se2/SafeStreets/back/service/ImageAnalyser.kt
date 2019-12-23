package se2.SafeStreets.back.service

import com.openalpr.jni.Alpr
import org.springframework.stereotype.Component
import se2.SafeStreets.back.model.RecognisedLicense

@Component
class ImageAnalyser {

    lateinit var alpr: Alpr

    init {
        var path = (ImageAnalyser::class).java.classLoader.getResource("openalpr")!!.path
        path = path.replaceFirst("/", "")
        path = path.replace("%20", " ")

        alpr = Alpr("us", "$path/runtime_data/config/default.conf", "$path/runtime_data")
        // Set top N candidates returned to 20
        alpr.setTopN(9)
        // Set pattern to Maryland
        //alpr.setDefaultRegion("md")

        // Release memory
        //alpr.unload()
    }

    fun analyse(imagePath: String): List<RecognisedLicense> {
        val result: ArrayList<RecognisedLicense> = ArrayList()
        val alprResults = alpr.recognize(imagePath)
        System.out.format("  %-15s%-8s\n", "Plate Number", "Confidence")
        for (plates in alprResults.plates) {
            for (plate in plates.topNPlates) {
                //if (plate.isMatchesTemplate) {
                result.add(RecognisedLicense(plate.characters, plate.overallConfidence))
                print("  * ")
                System.out.format("%-15s%-8f\n", plate.characters, plate.overallConfidence)
                //}
            }
        }
        return result
    }
}