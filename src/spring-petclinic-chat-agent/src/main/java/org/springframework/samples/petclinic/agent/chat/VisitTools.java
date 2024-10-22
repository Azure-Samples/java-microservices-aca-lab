package org.springframework.samples.petclinic.agent.chat;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.samples.petclinic.agent.model.Pet;
import org.springframework.samples.petclinic.agent.model.Visit;
import org.springframework.samples.petclinic.agent.service.PetService;
import org.springframework.samples.petclinic.agent.service.VisitService;

import java.util.Date;
import java.util.function.Function;

@Configuration
public class VisitTools {

    private final VisitService visitService;

    private final PetService petService;

    public VisitTools(VisitService visitService, PetService petService) {
        this.visitService = visitService;
        this.petService = petService;
    }

    @Bean
    @Description("Add a visit for a pet by providing the pet name, visit date, and description")
    public Function<VisitCreateRequest, Visit> addVisit() {
        return visitCreateRequest -> {
            Pet pet = petService.findPetByName(visitCreateRequest.petName);

            Visit visit = new Visit();
            visit.setDate(visitCreateRequest.visitDate);
            visit.setDescription(visitCreateRequest.description);
            visitService.addVisit(pet.getId(), visit);
            return visit;
        };
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonClassDescription("Visit Create Request.")
    public record VisitCreateRequest(
        @JsonProperty(required = true,
            value = "petName") @JsonPropertyDescription("The Pet Name") String petName,
        @JsonProperty(required = true,
            value = "visitDate") @JsonPropertyDescription("The Visit Date") Date visitDate,
        @JsonProperty(required = true,
            value = "description") @JsonPropertyDescription("The Visit Description") String description) {
    }
}
