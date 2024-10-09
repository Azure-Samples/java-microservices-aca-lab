package org.springframework.samples.petclinic.api.service;

import org.springframework.samples.petclinic.api.model.Owner;
import org.springframework.samples.petclinic.api.model.PetType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class OwnerService {

    private final String hostname = "http://customers-service/";

    private final RestTemplate restTemplate;

    public OwnerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<Owner> findOwnersByFirstName(String firstName) {
        var owners = restTemplate.getForObject(hostname + "owners/firstname?firstName={firstName}", Owner[].class, firstName);
        if (owners != null) {
            return List.of(owners);
        } else {
            return new ArrayList<>();
        }
    }

    public Owner findOwnerById(int ownerId) {
        return restTemplate.getForObject(hostname + "owners/{ownerId}", Owner.class, ownerId);
    }

    public Owner createNewOwner(Owner owner) {
        return restTemplate.postForEntity(hostname + "owners", owner, Owner.class).getBody();
    }

    public void updateExistingOwner(Owner owner, int ownerId) {
        restTemplate.put(hostname + "owners/" + ownerId, owner);
    }

    public List<PetType> findPetTypes() {
        var petTypes = restTemplate.getForObject(hostname + "petTypes", PetType[].class);
        if (petTypes != null) {
            return List.of(petTypes);
        } else {
            return new ArrayList<>();
        }
    }
}
