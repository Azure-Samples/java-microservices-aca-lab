package org.springframework.samples.petclinic.agent.owner;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import org.springframework.samples.petclinic.agent.model.NamedEntity;

@Entity
@Table(name = "types")
public class PetType extends NamedEntity {

}
