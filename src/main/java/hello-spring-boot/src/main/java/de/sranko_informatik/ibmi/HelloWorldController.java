package de.sranko_informatik.ibmi;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.file.FileSystems;
import java.io.File;
import java.io.IOException;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.MediaType;

@RestController
public class HelloWorldController {

	@RequestMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
	public String index(@RequestParam String fileSize) {
		
		System.out.println(FileSystems.getDefault().getPath(".").toString());
		
		//create ObjectMapper instance
		ObjectMapper objectMapper = new ObjectMapper();

		String output = new String ("{\"error\" : \"Filesize not found.\"}" );
		
		String fileName = new String(getFileName(fileSize, "config.json", objectMapper));
		
		if (fileName != null && !fileName.isEmpty()) {
			output = getFileData(fileName, objectMapper);
		}
		return output;
	}
	
	private String getFileName(String fileName, String configurationFile, ObjectMapper mapper) {
		
		String file = new String();
		try {
			JsonNode rootNode = mapper.readTree(new File(configurationFile));
			file = rootNode.path("files").path(fileName).asText();
		} catch (IOException e) {
			return null;
		}		
		return file;
	}

	private String getFileData(String fileName, ObjectMapper mapper) {
		
		String data = new String();
		try {
			JsonNode rootNode = mapper.readTree(new File(fileName));
			data = rootNode.toString();
		} catch (IOException e) {
			
		}		
		return data;
	}
}
