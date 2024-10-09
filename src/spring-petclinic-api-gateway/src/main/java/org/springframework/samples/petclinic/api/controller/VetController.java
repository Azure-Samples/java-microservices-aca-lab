package org.springframework.samples.petclinic.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.samples.petclinic.api.model.Vet;
import org.springframework.samples.petclinic.api.service.VetService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class VetController {

	private final VetService vetService;

	public VetController(VetService vetService) {
		this.vetService = vetService;
	}

	@GetMapping("/vets.html")
	public String showVetList(@RequestParam(defaultValue = "1") int page, Model model) {
		Page<Vet> paginated = vetService.findAllVets(page);
		return addPaginationModel(page, paginated, model);
	}

	private String addPaginationModel(int page, Page<Vet> paginated, Model model) {
        List<Vet> listVets = paginated.getContent();
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", paginated.getTotalPages());
        model.addAttribute("vetPage", listVets);
		return "vets/vetList";
	}

	@GetMapping("/vets")
	public @ResponseBody List<Vet> showResourcesVetList() {
		return vetService.findAllVets();
	}

}
