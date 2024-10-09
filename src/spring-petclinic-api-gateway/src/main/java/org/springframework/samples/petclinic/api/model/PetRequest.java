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
