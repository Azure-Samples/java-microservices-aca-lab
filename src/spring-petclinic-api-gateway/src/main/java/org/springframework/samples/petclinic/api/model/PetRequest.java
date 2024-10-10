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
package org.springframework.samples.petclinic.api.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Date;


import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PetRequest {
    private Integer id;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birthDate;

    private String name;

    private int typeId;

    public static PetRequest fromPet(Pet pet) {
        PetRequest petRequest = new PetRequest();
        petRequest.setId(pet.getId());
        petRequest.setBirthDate(pet.getBirthDate());
        petRequest.setName(pet.getName());
        petRequest.setTypeId(pet.getType().getId());
        return petRequest;
    }
}
