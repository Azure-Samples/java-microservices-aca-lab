package org.springframework.samples.petclinic.agent;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ImportRuntimeHints;

/**
 * PetClinic Spring Boot Application.
 */
@SpringBootApplication
@ImportRuntimeHints(PetClinicRuntimeHints.class)
public class ChatAgentApplication {

	public static void main(String[] args) {
		SpringApplication.run(ChatAgentApplication.class, args);
	}

}
