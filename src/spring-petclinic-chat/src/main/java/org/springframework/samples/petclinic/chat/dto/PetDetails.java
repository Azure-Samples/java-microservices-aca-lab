package org.springframework.samples.petclinic.chat.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Data
public class PetDetails {

    private int id;

    private String name;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birthDate;

    private PetType type;

    private final List<VisitDetails> visits = new ArrayList<>();

}
