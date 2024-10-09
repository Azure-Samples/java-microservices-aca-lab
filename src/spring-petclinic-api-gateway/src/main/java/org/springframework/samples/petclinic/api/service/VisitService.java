package org.springframework.samples.petclinic.api.service;

import org.springframework.samples.petclinic.api.model.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

import static java.util.stream.Collectors.joining;

@Service
public class VisitService {

    private final String hostname = "http://visits-service/";

    private final RestTemplate restTemplate;

    public VisitService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void addNewVisit(Owner owner, int petId, Visit visit) {
        restTemplate.postForEntity(hostname + "owners/" + owner.getId() + "/pets/" + petId + "/visits", visit, Visit.class).getBody();
    }

    public Visits getVisitsForPets(List<Integer> petIds) {
        return restTemplate.getForObject(hostname + "pets/visits?petId=" + joinIds(petIds), Visits.class);
    }

    private String joinIds(List<Integer> petIds) {
        return petIds.stream().map(Object::toString).collect(joining(","));
    }
}
