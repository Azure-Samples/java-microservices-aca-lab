package org.springframework.samples.petclinic.agent.chat;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.samples.petclinic.agent.dto.VetDto;
import org.springframework.samples.petclinic.agent.service.VetService;

import java.util.Collection;
import java.util.function.Function;

@Configuration
public class VetTools {

	private final VetService vetService;

	public VetTools(VetService vetService) {
		this.vetService = vetService;
	}

	@Bean
	@Description("return list of Vets, include their specialties")
	public Function<Request, Collection<VetDto>> queryVets() {
		return request -> {
			return vetService.findAll();
		};
	}

	@JsonInclude(JsonInclude.Include.NON_NULL)
	@JsonClassDescription("Query vets request")
	public record Request(@JsonProperty(required = false,
			value = "specialty") @JsonPropertyDescription("The specialty") String specialty) {
	}

}
