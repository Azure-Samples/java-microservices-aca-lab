package org.springframework.samples.petclinic.api.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.samples.petclinic.api.model.Owner;
import org.springframework.samples.petclinic.api.model.Visit;
import org.springframework.samples.petclinic.api.model.Visits;
import org.springframework.samples.petclinic.api.service.OwnerService;
import org.springframework.samples.petclinic.api.service.VisitService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class OwnerController {

    private final Logger logger = LoggerFactory.getLogger(OwnerController.class);

	private static final String VIEWS_OWNER_CREATE_OR_UPDATE_FORM = "owners/createOrUpdateOwnerForm";

	private final OwnerService ownerService;

    private final VisitService visitService;

	public OwnerController(OwnerService ownerService, VisitService visitService) {
		this.ownerService = ownerService;
        this.visitService = visitService;
	}

	@InitBinder
	public void setAllowedFields(WebDataBinder dataBinder) {
		dataBinder.setDisallowedFields("id");
	}

	@ModelAttribute("owner")
	public Owner findOwner(@PathVariable(name = "ownerId", required = false) Integer ownerId) {
		return ownerId == null ? new Owner() : ownerService.findOwnerById(ownerId);
	}

    /* Add new owner */

	@GetMapping("/owners/new")
	public String initCreationForm(Model model) {
		Owner owner = new Owner();
        model.addAttribute(owner);
		return VIEWS_OWNER_CREATE_OR_UPDATE_FORM;
	}

	@PostMapping("/owners/new")
	public String processCreationForm(Owner owner) {
		var newOwner = ownerService.createNewOwner(owner);
		return "redirect:/owners/" + newOwner.getId();
	}

    /* Find owners */

	@GetMapping("/owners/find")
	public String initFindForm() {
		return "owners/findOwners";
	}

	@GetMapping("/owners")
	public String processFindForm(@RequestParam(defaultValue = "1") int page, Owner owner, Model model) {
		// allow parameterless GET request for /owners to return all records
		if (owner.getFirstName() == null) {
			owner.setFirstName(""); // empty string signifies broadest possible search
		}

		// find owners by first name
		Page<Owner> ownersResults = findPaginatedForOwnersFirstName(page, owner.getFirstName());
		return addPaginationModel(page, model, ownersResults);
	}

    private Page<Owner> findPaginatedForOwnersFirstName(int page, String firstname) {
        var owners = ownerService.findOwnersByFirstName(firstname);
        int pageSize = 10;
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), owners.size());
        List<Owner> paginatedList = owners.subList(start, end);

        return new PageImpl<>(paginatedList, pageable, owners.size());
    }

	private String addPaginationModel(int page, Model model, Page<Owner> paginated) {
        model.addAttribute("currentPage", page);
		model.addAttribute("listOwners", paginated);
		return "owners/ownersList";
	}

    /* Edit existing owner */

	@GetMapping("/owners/{ownerId}/edit")
	public String initUpdateOwnerForm(@PathVariable("ownerId") int ownerId, Model model) {
		Owner owner = ownerService.findOwnerById(ownerId);
		model.addAttribute(owner);
		return VIEWS_OWNER_CREATE_OR_UPDATE_FORM;
	}

	@PostMapping("/owners/{ownerId}/edit")
	public String processUpdateOwnerForm(Owner owner, @PathVariable("ownerId") Integer ownerId) {
        ownerService.updateExistingOwner(owner, ownerId);
		return "redirect:/owners/{ownerId}";
	}

    /* Show owner detail */

	@GetMapping("/owners/{ownerId}")
	public String showOwner(@PathVariable("ownerId") int ownerId, Model model) {
		Owner owner = ownerService.findOwnerById(ownerId);

        Visits visits = visitService.getVisitsForPets(owner.getPetIds());
        // add visit for owner
        owner.getPets().forEach(pet -> {
            List<Visit> petVisits =visits.getItems().stream().filter(visit -> visit.getPetId() == pet.getId()).toList();
            pet.addVisits(petVisits);
        });

        model.addAttribute(owner);
		return "owners/ownerDetails";
	}

}
