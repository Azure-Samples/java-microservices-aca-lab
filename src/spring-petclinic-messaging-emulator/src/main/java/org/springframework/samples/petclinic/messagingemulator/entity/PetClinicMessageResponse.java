package org.springframework.samples.petclinic.messagingemulator.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PetClinicMessageResponse {
    int requestId;
    Boolean confirmed;
    String reason;
}
