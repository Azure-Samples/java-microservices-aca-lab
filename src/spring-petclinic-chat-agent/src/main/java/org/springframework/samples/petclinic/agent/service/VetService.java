package org.springframework.samples.petclinic.agent.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.agent.dto.VetDto;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class VetService {

    private final RestTemplate restTemplate;

    @Autowired
    public VetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<VetDto> findAll() {
        var vets = restTemplate.getForObject("http://vets-service/vets", VetDto[].class);
        if (vets != null) {
            return List.of(vets);
        } else {
            return new ArrayList<>();
        }
    }

}
