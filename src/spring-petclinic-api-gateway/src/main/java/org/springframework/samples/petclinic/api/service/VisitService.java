/*
 * Copyright 2002-2021 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
