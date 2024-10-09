package org.springframework.samples.petclinic.api.formatter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.Formatter;
import org.springframework.samples.petclinic.api.model.PetType;
import org.springframework.samples.petclinic.api.service.OwnerService;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.List;
import java.util.Locale;

/**
 * Instructs Spring MVC on how to parse and print elements of type 'PetType'. Starting
 * from Spring 3.0, Formatters have come as an improvement in comparison to legacy
 * PropertyEditors. See the following links for more details: - The Spring ref doc:
 * https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#format
 */

@Component
public class PetTypeFormatter implements Formatter<PetType> {

	private final OwnerService ownerService;

	@Autowired
	public PetTypeFormatter(OwnerService ownerService) {
		this.ownerService = ownerService;
	}

	@Override
	public String print(PetType petType, Locale locale) {
        return petType.getName();
	}

	@Override
	public PetType parse(String text, Locale locale) throws ParseException {
        List<PetType> findPetTypes = ownerService.findPetTypes();
        for (PetType type : findPetTypes) {
            if (type.getName().equals(text)) {
                return type;
            }
        }

        throw new ParseException("type not found: " + text, 0);
	}

}
