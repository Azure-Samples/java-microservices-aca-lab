package org.springframework.samples.petclinic.agent.dto;

import lombok.Data;

import java.util.Set;

@Data
public class OwnerDto {

    private Integer id;

    private String firstName;

    private String lastName;

    private String address;

    private String city;

    private String telephone;

    private Set<PetDto> pets;
}
