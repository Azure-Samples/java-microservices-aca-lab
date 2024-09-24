package org.springframework.samples.petclinic.agent.dto;

import lombok.Data;

import java.util.Date;

@Data
public class PetDto {

    private Integer id;

    private String name;

    private Date birthDate;

    private PetTypeDto type;

    private OwnerDto owner;
}
