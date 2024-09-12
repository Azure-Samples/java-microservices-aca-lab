package org.springframework.samples.petclinic.visits.entities;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VisitRequest implements Serializable {
    private static final long serialVersionUID = -249974321255677286L;

    private Integer requestId;
    private Integer petId;
    private String message;
}
