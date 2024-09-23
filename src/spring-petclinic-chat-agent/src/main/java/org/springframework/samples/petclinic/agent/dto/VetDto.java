package org.springframework.samples.petclinic.agent.dto;

import lombok.Data;

import java.util.Set;

@Data
public class VetDto {

    private Integer id;

    private String firstName;

    private String lastName;

    private Set<SpecialtyDto> specialties;

}
