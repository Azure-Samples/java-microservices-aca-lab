package org.springframework.samples.petclinic.agent.chat;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.samples.petclinic.agent.model.Owner;
import org.springframework.samples.petclinic.agent.model.PetRequest;
import org.springframework.samples.petclinic.agent.service.OwnerService;
import org.springframework.samples.petclinic.agent.service.PetService;

import java.util.Date;
import java.util.function.Function;

@Configuration
public class PetTools {

    private final OwnerService ownerService;

    private final PetService petService;

    public PetTools(OwnerService ownerService, PetService petService) {
        this.ownerService = ownerService;
        this.petService = petService;
    }

    @Bean
    @Description("Add a new pet for an owner by providing the owner's first name, pet name, pet's birth date, and pet type")
    public Function<PetCreateRequest, PetRequest> addPet() {
        return petCreateRequest -> {
            var ownerOptional = ownerService.findByFirstName(petCreateRequest.firstName).stream().findFirst();
            if (ownerOptional.isEmpty()) {
                return null;
            }
            Owner owner = ownerOptional.get();

            PetRequest pet = new PetRequest();
            pet.setName(petCreateRequest.name);
            pet.setBirthDate(petCreateRequest.birthDate);
            pet.setTypeId(
                petService.findPetTypeByName(petCreateRequest.typeName).getId()
            );
            petService.addPet(owner.getId(), pet);
            return pet;
        };
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonClassDescription("Pet Create Request.")
    public record PetCreateRequest(
        @JsonProperty(required = true,
            value = "firstName") @JsonPropertyDescription("The Owner first name") String firstName,
        @JsonProperty(required = false,
            value = "petId") @JsonPropertyDescription("The Pet Id") Integer petId,
        @JsonProperty(required = true,
            value = "name") @JsonPropertyDescription("The Pet Name") String name,
        @JsonProperty(required = true,
            value = "birthDate") @JsonPropertyDescription("The Pet Birth Date") Date birthDate,
        @JsonProperty(required = true,
            value = "petType") @JsonPropertyDescription("The Pet Type") String typeName) {
    }
}
