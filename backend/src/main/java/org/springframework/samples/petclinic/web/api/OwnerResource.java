/*
 * Copyright 2002-2013 the original author or authors.
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
package org.springframework.samples.petclinic.web.api;

import java.util.Collection;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.model.Owner;
import org.springframework.samples.petclinic.service.ClinicService;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Juergen Hoeller
 * @author Ken Krebs
 * @author Arjen Poutsma
 * @author Michael Isvy
 * @author Igor Dmitriev
 */
@RestController
@RequestMapping("/api/owners")
public class OwnerResource {

	private final ClinicService	clinicService;

	@Autowired
	public OwnerResource(ClinicService clinicService) {
		this.clinicService = clinicService;
	}

	private Owner retrieveOwner(int ownerId) {
		Owner owner = this.clinicService.findOwnerById(ownerId);
		if (owner == null) {
			throw new BadRequestException("Owner with Id '" + ownerId + "' is unknown.");
		}
		return owner;
	}

	/**
	 * Create Owner
	 */
	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public Owner createOwner(@RequestBody @Valid Owner owner, BindingResult bindingResult) {
		if (bindingResult.hasErrors()) {
			throw new InvalidRequestException("Invalid Owner", bindingResult);
		}

		this.clinicService.saveOwner(owner);

		return owner;
	}

	/**
	 * Read single Owner
	 */
	@GetMapping("/{ownerId}")
	public Owner findOwner(@PathVariable("ownerId") int ownerId) {
		return retrieveOwner(ownerId);
	}

	/**
	 * Read List of Owners
	 */
	@GetMapping("/list")
	public Collection<Owner> findOwnerCollection(@RequestParam(value = "lastName", required = false) String ownerLastName) {
		if (ownerLastName == null) {
			ownerLastName = "";
		}
		return this.clinicService.findOwnerByLastName(ownerLastName);
	}

	/**
	 * Update Owner
	 */
	@PutMapping("/{ownerId}")
	public Owner updateOwner(@PathVariable("ownerId") int ownerId, @RequestBody Owner ownerRequest,
			final BindingResult bindingResult) {
		if (bindingResult.hasErrors()) {
			throw new InvalidRequestException("Invalid Owner", bindingResult);
		}

		Owner ownerModel = retrieveOwner(ownerId);
		// This is done by hand for simplicity purpose. In a real life use-case we
		// should consider using MapStruct.
		ownerModel.setFirstName(ownerRequest.getFirstName());
		ownerModel.setLastName(ownerRequest.getLastName());
		ownerModel.setCity(ownerRequest.getCity());
		ownerModel.setAddress(ownerRequest.getAddress());
		ownerModel.setTelephone(ownerRequest.getTelephone());
		this.clinicService.saveOwner(ownerModel);
		return ownerModel;
	}

}
