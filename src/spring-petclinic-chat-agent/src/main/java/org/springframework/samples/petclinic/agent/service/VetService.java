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
import org.springframework.samples.petclinic.agent.model.Vet;
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

    public List<Vet> findAll() {
        var vets = restTemplate.getForObject("http://vets-service/vets", Vet[].class);
        if (vets != null) {
            return List.of(vets);
        } else {
            return new ArrayList<>();
        }
    }

}
