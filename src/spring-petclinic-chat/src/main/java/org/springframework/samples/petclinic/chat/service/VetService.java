package org.springframework.samples.petclinic.chat.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.chat.dto.Vet;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class VetService {

    private final RestTemplate restTemplate;

    @Autowired
    public VetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<Vet> listAllVets() {
        var vets = restTemplate.getForObject("http://vets-service/vets", Vet[].class);
        return List.of(vets);
    }

}

