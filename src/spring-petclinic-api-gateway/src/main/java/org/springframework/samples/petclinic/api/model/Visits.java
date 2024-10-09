package org.springframework.samples.petclinic.api.model;

import lombok.Value;

import java.util.ArrayList;
import java.util.List;

@Value
public class Visits {

    List<Visit> items = new ArrayList<>();

}
