package org.springframework.samples.petclinic.api.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Pet {

    private Integer id;

    private String name;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date birthDate;

    private PetType type;

    private Owner owner;

    private final List<Visit> visits = new ArrayList<>();

    public boolean isNew() {
        return this.id == null;
    }

    public Collection<Visit> getVisits() {
        return this.visits;
    }

    public void addVisit(Visit visit) {
        getVisits().add(visit);
    }

    public void addVisits(List<Visit> visits) {
        getVisits().addAll(visits);
    }

    @Override
    public String toString() {
        return name;
    }
}
