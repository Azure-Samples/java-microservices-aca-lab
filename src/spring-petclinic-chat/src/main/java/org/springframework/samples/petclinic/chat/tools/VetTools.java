package org.springframework.samples.petclinic.chat.tools;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.samples.petclinic.chat.service.VetService;
import org.springframework.samples.petclinic.chat.dto.Vet;

import java.util.Collection;
import java.util.function.Function;

@Configuration
public class VetTools {

    private final VetService vetService;

    @Autowired
    public VetTools(VetService vetService) {
        this.vetService = vetService;
    }

    @Bean
    @Description("return list of Vets, include their specialties")
    public Function<Request, Collection<Vet>> queryVets() {
        return request -> vetService.listAllVets();
    }


    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonClassDescription("Query vets request")
    public record Request(
        @JsonProperty(required = false, value = "specialty") @JsonPropertyDescription("The specialty") String specialty) {
    }

}
