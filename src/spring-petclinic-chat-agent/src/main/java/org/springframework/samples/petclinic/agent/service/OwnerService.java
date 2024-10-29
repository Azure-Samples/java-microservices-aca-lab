/*
 * Copyright 2002-2024 the original author or authors.
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
package org.springframework.samples.petclinic.agent.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.samples.petclinic.agent.model.Owner;
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

    public List<Owner> findByFirstName(String firstName) {
        var owners = restTemplate.getForObject("http://customers-service/owners/firstname?firstName=" + firstName, Owner[].class);
        if (owners != null) {
            return List.of(owners);
        } else {
            return new ArrayList<>();
        }
    }

    public Owner findById(int ownerId) {
        return restTemplate.getForObject("http://customers-service/owners/{ownerId}", Owner.class, ownerId);
    }

    public void save(Owner owner) {
        restTemplate.postForEntity("http://customers-service/owners", owner, Owner.class);
    }

    public void updateOwner(Owner owner) {
        restTemplate.put("http://customers-service/owners/" + owner.getId(), owner);
    }
}
