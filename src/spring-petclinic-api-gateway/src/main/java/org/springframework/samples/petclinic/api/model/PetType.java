package org.springframework.samples.petclinic.api.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PetType {

    private Integer id;

    public boolean isNew() {
        return this.id == null;
    }

    private String name;

    @Override
    public String toString() {
        return this.name;
    }
}
