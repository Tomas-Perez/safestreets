package se2.SafeStreets.back

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import com.openalpr.jni.AlprPlate
import com.openalpr.jni.AlprPlateResult
import com.openalpr.jni.AlprResults
import com.openalpr.jni.Alpr
import org.hibernate.validator.internal.util.privilegedactions.GetClassLoader
import org.springframework.util.ResourceUtils


@SpringBootApplication
class BackApplication

fun main(args: Array<String>) {
    //---- OPENALPR TEST ----

	/*
    var path = (BackApplication::class).java.classLoader.getResource("openalpr").path

	// delete first '/' from path
	path = path.replaceFirst("/", "")
	// replace $20 with actual spaces
	path = path.replace("%20", " ")

	val alpr = Alpr("us", "$path/runtime_data/config/default.conf", "$path/runtime_data")

	// Set top N candidates returned to 20
	alpr.setTopN(9)

	// Set pattern to Maryland
	alpr.setDefaultRegion("md")

	val results = alpr.recognize("$path/test.jpg")
	System.out.format("  %-15s%-8s\n", "Plate Number", "Confidence")
	for (result in results.plates) {
		for (plate in result.topNPlates) {
			if (plate.isMatchesTemplate) {
				print("  * ")
				System.out.format("%-15s%-8f\n", plate.characters, plate.overallConfidence)
			}
		}
	}

	// Release memory
	alpr.unload()
    */


	runApplication<BackApplication>(*args)
}

