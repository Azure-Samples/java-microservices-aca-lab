package org.springframework.samples.petclinic.agent.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.samples.petclinic.agent.model.Visit;
import org.springframework.web.client.RestTemplate;

@Configuration
public class VisitService {

    private final RestTemplate restTemplate;

    @Autowired
    public VisitService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void addVisit(int petId, Visit visit) {
        restTemplate.postForEntity("http://visits-service/owners/*/pets/" + petId + "/visits", visit, Visit.class);
    }

}
