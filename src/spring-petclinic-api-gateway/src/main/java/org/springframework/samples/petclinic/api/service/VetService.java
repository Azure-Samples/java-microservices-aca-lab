package org.springframework.samples.petclinic.api.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.samples.petclinic.api.model.Vet;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class VetService {

    private final String hostname = "http://vets-service/";

    private final RestTemplate restTemplate;

    public VetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<Vet> findAllVets() {
        var vets = restTemplate.getForObject(hostname + "vets", Vet[].class);
        if (vets != null) {
            return List.of(vets);
        } else {
            return new ArrayList<>();
        }
    }

    public Page<Vet> findAllVets(int page) {
        var vets = findAllVets();
        if (vets != null) {
            int pageSize = 10;
            Pageable pageable = PageRequest.of(page - 1, pageSize);

            int start = (int) pageable.getOffset();
            int end = Math.min((start + pageable.getPageSize()), vets.size());
            List<Vet> paginatedList = vets.subList(start, end);

            return new PageImpl<>(paginatedList, pageable, vets.size());
        } else {
            return Page.empty();
        }
    }
}
