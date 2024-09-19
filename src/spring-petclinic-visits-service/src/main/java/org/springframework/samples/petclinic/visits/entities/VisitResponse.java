package org.springframework.samples.petclinic.visits.entities;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VisitResponse {
    Integer requestId;
    Boolean confirmed;
    String reason;
}
