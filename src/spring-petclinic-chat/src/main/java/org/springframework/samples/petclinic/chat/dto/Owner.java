package org.springframework.samples.petclinic.chat.dto;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

import static java.util.stream.Collectors.toList;

@Data
public class Owner {

    private int id;

    private String firstName;

    private String lastName;

    private String address;

    private String city;

    private String telephone;

    private final List<PetDetails> pets = new ArrayList<>();

    public void addPet(PetDetails pet) {
        pets.add(pet);
    }
}
