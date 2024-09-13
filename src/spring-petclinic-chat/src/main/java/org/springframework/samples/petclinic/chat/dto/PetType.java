package org.springframework.samples.petclinic.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Data;


@Data
@AllArgsConstructor
public class PetType {

    private Integer id;

    private String name;
}
