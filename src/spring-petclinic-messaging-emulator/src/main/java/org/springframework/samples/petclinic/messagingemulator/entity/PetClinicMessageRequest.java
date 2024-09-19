package org.springframework.samples.petclinic.messagingemulator.entity;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PetClinicMessageRequest implements Serializable {
    private static final long serialVersionUID = -249322721255887286L;

    private Integer requestId;
    private Integer petId;
    private String message;

    public PetClinicMessageRequest(Integer ownerId, String message) {
        this.petId = ownerId;
        this.message = message;
    }
}
