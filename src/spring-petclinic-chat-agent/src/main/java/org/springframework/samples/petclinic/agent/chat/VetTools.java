/*
 * Copyright 2002-2024 the original author or authors.
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
package org.springframework.samples.petclinic.agent.chat;

import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.samples.petclinic.agent.model.Vet;
import org.springframework.samples.petclinic.agent.service.VetService;

import java.util.Collection;
import java.util.function.Function;

@Configuration
public class VetTools {

	private final VetService vetService;

	public VetTools(VetService vetService) {
		this.vetService = vetService;
	}

	@Bean
	@Description("return list of Vets, include their specialties")
	public Function<Request, Collection<Vet>> queryVets() {
		return request -> {
			return vetService.findAll();
		};
	}

	@JsonInclude(JsonInclude.Include.NON_NULL)
	@JsonClassDescription("Query vets request")
	public record Request(@JsonProperty(required = false,
			value = "specialty") @JsonPropertyDescription("The specialty") String specialty) {
	}

}
