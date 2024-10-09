package org.springframework.samples.petclinic.api.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

@Data
@AllArgsConstructor
public class Visit {

    public Visit() {
        this.date = new Date();
    }

    private Integer id;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date date;

    private Integer petId = null;

	private String description;

    public boolean isNew() {
        return this.id == null;
    }

}
