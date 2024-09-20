package org.springframework.samples.petclinic.agent.model;

import lombok.Data;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;

/**
 * Simple JavaBean domain object adds a name property to <code>BaseEntity</code>. Used as
 * a base class for objects needing these properties.
 */
@MappedSuperclass
@Data
public class NamedEntity extends BaseEntity {

	@Column(name = "name")
	private String name;

	@Override
	public String toString() {
		return this.getName();
	}

}
