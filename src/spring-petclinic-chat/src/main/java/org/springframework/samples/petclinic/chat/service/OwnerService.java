package org.springframework.samples.petclinic.chat.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.chat.dto.Owner;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class OwnerService {

    private final RestTemplate restTemplate;

    @Autowired
    public OwnerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public Owner findById(final int ownerId) {
        return restTemplate.getForObject("http://customers-service/owners/{ownerId}", Owner.class, ownerId);
    }

    public List<Owner> queryOwners(String name) {
        var owners = restTemplate.getForObject("http://customers-service/owners/witname/{name}", Owner[].class, name);
        return List.of(owners);
    }

    public void save(Owner owner) {
        restTemplate.postForEntity("http://customers-service/owners", owner, Owner.class);
    }
}

