package org.springframework.samples.petclinic.agent.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.agent.dto.OwnerDto;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class OwnerService {

    private final RestTemplate restTemplate;

    @Autowired
    public OwnerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<OwnerDto> findByFirstName(String firstName) {
        var owners = restTemplate.getForObject("http://customers-service/owners/firstname/{firstName}", OwnerDto[].class, firstName);
        if (owners != null) {
            return List.of(owners);
        } else {
            return new ArrayList<>();
        }
    }

    public OwnerDto findById(int ownerId) {
        return restTemplate.getForObject("http://customers-service/owners/{ownerId}", OwnerDto.class, ownerId);
    }

    public void save(OwnerDto owner) {
        restTemplate.postForEntity("http://customers-service/owners", owner, OwnerDto.class);
    }
}
