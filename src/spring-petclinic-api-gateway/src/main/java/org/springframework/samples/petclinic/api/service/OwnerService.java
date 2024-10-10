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
