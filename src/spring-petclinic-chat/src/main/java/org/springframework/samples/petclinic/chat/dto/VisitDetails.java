package org.springframework.samples.petclinic.chat.dto;

import lombok.Data;

@Data
public class VisitDetails {

    private Integer id = null;

    private Integer petId = null;

    private String date = null;

    private String description = null;
}
