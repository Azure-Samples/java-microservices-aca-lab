/*
 * Copyright 2002-2021 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.api.controller;

import org.springframework.samples.petclinic.api.model.Owner;
import org.springframework.samples.petclinic.api.model.Pet;
import org.springframework.samples.petclinic.api.model.Visit;
import org.springframework.samples.petclinic.api.model.Visits;
import org.springframework.samples.petclinic.api.service.OwnerService;
import org.springframework.samples.petclinic.api.service.VisitService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
class VisitController {

	private final OwnerService ownerService;

    private final VisitService visitService;

	public VisitController(OwnerService ownerService, VisitService visitService) {
		this.ownerService = ownerService;
        this.visitService = visitService;
	}

	@InitBinder
	public void setAllowedFields(WebDataBinder dataBinder) {
		dataBinder.setDisallowedFields("id");
	}

	/**
	 * Called before each and every @RequestMapping annotated method. 2 goals: - Make sure
	 * we always have fresh data - Since we do not use the session scope, make sure that
	 * Pet object always has an id (Even though id is not part of the form fields)
	 * @param petId
	 * @return Pet
	 */
	@ModelAttribute("visit")
	public Visit loadPetWithVisit(@PathVariable("ownerId") int ownerId, @PathVariable("petId") int petId, Map<String, Object> model) {
		Owner owner = ownerService.findOwnerById(ownerId);

        Visits visits = visitService.getVisitsForPets(owner.getPetIds());
        // add visit for owner
        owner.getPets().forEach(pet -> {
            List<Visit> petVisits =visits.getItems().stream().filter(visit -> visit.getPetId() == pet.getId()).toList();
            pet.addVisits(petVisits);
        });

		Pet pet = owner.getPet(petId);
		model.put("pet", pet);
		model.put("owner", owner);

		Visit visit = new Visit();
		pet.addVisit(visit);
		return visit;
	}

	// Spring MVC calls method loadPetWithVisit(...) before initNewVisitForm is
	// called
	@GetMapping("/owners/{ownerId}/pets/{petId}/visits/new")
	public String initNewVisitForm() {
		return "pets/createOrUpdateVisitForm";
	}

	// Spring MVC calls method loadPetWithVisit(...) before processNewVisitForm is
	// called
	@PostMapping("/owners/{ownerId}/pets/{petId}/visits/new")
	public String processNewVisitForm(@ModelAttribute Owner owner, @PathVariable("petId") int petId, Visit visit) {
		owner.addVisit(petId, visit);
        visitService.addNewVisit(owner, petId, visit);
		return "redirect:/owners/{ownerId}";
	}

}
