package org.springframework.samples.petclinic.agent.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.agent.model.Pet;
import org.springframework.samples.petclinic.agent.model.PetRequest;
import org.springframework.samples.petclinic.agent.model.PetType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class PetService {

    private final RestTemplate restTemplate;

    @Autowired
    public PetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void addPet(int ownerId, PetRequest pet) {
        restTemplate.postForEntity("http://customers-service/owners/" + ownerId + "/pets", pet, Pet.class);
    }

    public Pet findPetByName(String petName) {
        return restTemplate.getForObject("http://customers-service/owners/*/pets?petName=" + petName, Pet.class);
    }

    public PetType findPetTypeByName(String typeName) {
        return restTemplate.getForObject("http://customers-service/petType?typeName=" + typeName, PetType.class);
    }
}
