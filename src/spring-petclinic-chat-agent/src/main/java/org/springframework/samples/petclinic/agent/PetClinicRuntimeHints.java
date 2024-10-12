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
package org.springframework.samples.petclinic.agent;

import org.springframework.aot.hint.RuntimeHints;
import org.springframework.aot.hint.RuntimeHintsRegistrar;
import org.springframework.samples.petclinic.agent.model.*;

/*
 * This class is to provide hints to the runtime environment about specific resources and classes, particularly for
 * environments where reflection, resource access, and serialization are restricted, such as in AOT compilation scenarios.
 */
public class PetClinicRuntimeHints implements RuntimeHintsRegistrar {

	@Override
	public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
		// https://github.com/spring-projects/spring-boot/issues/32654
		hints.resources().registerPattern("messages/*");
		hints.resources().registerPattern("META-INF/resources/webjars/*");
		hints.resources().registerPattern("mysql-default-conf");
        hints.serialization().registerType(ChatMessage.class);
		hints.serialization().registerType(Owner.class);
		hints.serialization().registerType(Pet.class);
        hints.serialization().registerType(PetType.class);
		hints.serialization().registerType(Vet.class);
        hints.serialization().registerType(Specialty.class);
	}

}
