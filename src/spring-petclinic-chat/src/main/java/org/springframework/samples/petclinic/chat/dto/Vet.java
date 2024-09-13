package org.springframework.samples.petclinic.chat.dto;


import lombok.Data;

import java.util.Set;

@Data
public class Vet {

    private Integer id;

    private String firstName;

    private String lastName;

    private Set<Specialty> specialties;

}
