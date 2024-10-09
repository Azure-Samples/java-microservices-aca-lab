package org.springframework.samples.petclinic.api.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.core.style.ToStringCreator;
import org.springframework.util.Assert;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static java.util.stream.Collectors.toList;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Owner {

    private Integer id;

    private String firstName;

    private String lastName;

    private String address;

    private String city;

    private String telephone;

    private Set<Pet> pets = new HashSet<>();

    public boolean isNew() {
        return this.id == null;
    }

    public List<Integer> getPetIds() {
        return pets.stream()
            .map(Pet::getId)
            .collect(toList());
    }

    public void addPet(Pet pet) {
        getPets().add(pet);
    }

    /**
     * Return the Pet with the given name, or null if none found for this Owner.
     * @param name to test
     * @return a pet if pet name is already in use
     */
    public Pet getPet(String name) {
        return getPet(name, false);
    }

    public Pet getPet(Integer id) {
        for (Pet pet : getPets()) {
            if (!pet.isNew()) {
                Integer compId = pet.getId();
                if (compId.equals(id)) {
                    return pet;
                }
            }
        }

        return null;
    }

    public Pet getPet(String name, boolean ignoreNew) {
        name = name.toLowerCase();
        for (Pet pet : getPets()) {
            String compName = pet.getName();
            if (compName != null && compName.equalsIgnoreCase(name)) {
                if (!ignoreNew || !pet.isNew()) {
                    return pet;
                }
            }
        }
        return null;
    }

    @Override
    public String toString() {
        return new ToStringCreator(this)
            .append("id", this.getId())
            .append("new", this.isNew())
            .append("lastName", this.getLastName())
            .append("firstName", this.getFirstName())
            .append("address", this.address)
            .append("city", this.city)
            .append("telephone", this.telephone)
            .append("pets", this.pets.toString())
            .toString();
    }

    public void addVisit(Integer petId, Visit visit) {
        Assert.notNull(petId, "Pet identifier must not be null!");
        Assert.notNull(visit, "Visit must not be null!");

        Pet pet = getPet(petId);
        Assert.notNull(pet, "Invalid Pet identifier!");

        pet.addVisit(visit);
    }
}
