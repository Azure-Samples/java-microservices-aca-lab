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
import org.springframework.samples.petclinic.api.model.Pet;
import org.springframework.samples.petclinic.api.model.PetRequest;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class PetService {

    private final String hostname = "http://customers-service/";

    private final RestTemplate restTemplate;

    public PetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public void createNewPet(Owner owner, Pet pet) {
        PetRequest petRequest = PetRequest.fromPet(pet);
        restTemplate.postForEntity(hostname + "owners/" + owner.getId() + "/pets", petRequest, Pet.class).getBody();
    }

    public void updateExistingPet(Owner owner, Pet pet) {
        PetRequest petRequest = PetRequest.fromPet(pet);
        restTemplate.put(hostname + "owners/" + owner.getId() + "/pets/" + pet.getId(), petRequest);
    }

}
