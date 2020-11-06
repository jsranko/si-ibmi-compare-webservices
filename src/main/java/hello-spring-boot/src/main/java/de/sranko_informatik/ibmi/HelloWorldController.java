package de.sranko_informatik.ibmi;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.file.FileSystems;
import java.io.File;
import java.io.IOException;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class HelloWorldController {

	@RequestMapping("/")
	public String index() {
		
		System.out.println(FileSystems.getDefault().getPath(".").toString());
		
		//create ObjectMapper instance
		ObjectMapper objectMapper = new ObjectMapper();

		String output = new String ();
		
		try {
			//read customer.json file into tree model
			JsonNode rootNode = objectMapper.readTree(new File("config.json"));
			output = rootNode.path("library").asText();
		} catch (IOException e) {
			
		}
		
		return output;
	}

}
