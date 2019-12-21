package se2.SafeStreets.back

import com.fasterxml.jackson.databind.ser.std.ToStringSerializer
import org.bson.types.ObjectId
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Configuration
import org.springframework.http.converter.HttpMessageConverter
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter


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

