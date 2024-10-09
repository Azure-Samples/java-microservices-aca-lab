package org.springframework.samples.petclinic.api.controller;


import org.springframework.samples.petclinic.api.model.Owner;
import org.springframework.samples.petclinic.api.model.Pet;
import org.springframework.samples.petclinic.api.model.PetType;
import org.springframework.samples.petclinic.api.service.PetService;
import org.springframework.samples.petclinic.api.service.OwnerService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/owners/{ownerId}")
class PetController {

	private static final String VIEWS_PETS_CREATE_OR_UPDATE_FORM = "pets/createOrUpdatePetForm";

	private final OwnerService ownerService;

    private final PetService petService;

	public PetController(OwnerService ownerService, PetService petService) {
		this.ownerService = ownerService;
        this.petService = petService;
	}

	@ModelAttribute("types")
	public List<PetType> populatePetTypes() {
		return ownerService.findPetTypes();
	}

	@ModelAttribute("owner")
	public Owner findOwner(@PathVariable("ownerId") int ownerId) {
        return ownerService.findOwnerById(ownerId);
    }

	@ModelAttribute("pet")
	public Pet findPet(@PathVariable("ownerId") int ownerId, @PathVariable(name = "petId", required = false) Integer petId) {
		if (petId == null) {
			return new Pet();
		}
		Owner owner = ownerService.findOwnerById(ownerId);
		return owner.getPet(petId);
	}

	@InitBinder("owner")
	public void initOwnerBinder(WebDataBinder dataBinder) {
		dataBinder.setDisallowedFields("id");
	}

    /* Add new pet */

	@GetMapping("/pets/new")
	public String initCreationForm(Owner owner, ModelMap model) {
		Pet pet = new Pet();
		owner.addPet(pet);
        model.put("pet", pet);
		return VIEWS_PETS_CREATE_OR_UPDATE_FORM;
	}

	@PostMapping("/pets/new")
	public String processCreationForm(Owner owner, Pet pet, Model model) {
        owner.addPet(pet);
        petService.createNewPet(owner, pet);
		return "redirect:/owners/{ownerId}";
	}

    /* Edit existing pet */

	@GetMapping("/pets/{petId}/edit")
	public String initUpdateForm(Owner owner, @PathVariable("petId") int petId, ModelMap model) {
		Pet pet = owner.getPet(petId);
        model.put("pet", pet);
		return VIEWS_PETS_CREATE_OR_UPDATE_FORM;
	}

	@PostMapping("/pets/{petId}/edit")
	public String processUpdateForm(Pet pet, Owner owner) {
		owner.addPet(pet);
        petService.updateExistingPet(owner, pet);
		return "redirect:/owners/{ownerId}";
	}

}
