package org.springframework.samples.petclinic.agent;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ImportRuntimeHints;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@ImportRuntimeHints(PetClinicRuntimeHints.class)
public class ChatAgentApplication {

	public static void main(String[] args) {
		SpringApplication.run(ChatAgentApplication.class, args);
	}

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
