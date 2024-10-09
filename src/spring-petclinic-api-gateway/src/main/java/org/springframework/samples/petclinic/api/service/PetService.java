package org.springframework.samples.petclinic.api.service;

import org.springframework.samples.petclinic.api.model.Owner;
import org.springframework.samples.petclinic.api.model.Pet;
import org.springframework.samples.petclinic.api.model.PetRequest;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class PetService {

    private final String hostname = "http://customers-service/";

    private final RestTemplate restTemplate;

    public PetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void createNewPet(Owner owner, Pet pet) {
        PetRequest petRequest = PetRequest.fromPet(pet);
        restTemplate.postForEntity(hostname + "owners/" + owner.getId() + "/pets", petRequest, Pet.class).getBody();
    }

    public void updateExistingPet(Owner owner, Pet pet) {
        PetRequest petRequest = PetRequest.fromPet(pet);
        restTemplate.put(hostname + "owners/" + owner.getId() + "/pets/" + pet.getId(), petRequest);
    }

}
