package org.springframework.samples.petclinic.agent.vet;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import org.springframework.samples.petclinic.agent.model.NamedEntity;

/**
 * Models a {@link Vet Vet's} specialty (for example, dentistry).
 */
@Entity
@Table(name = "specialties")
public class Specialty extends NamedEntity {

}
