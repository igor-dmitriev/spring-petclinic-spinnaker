package org.springframework.samples.petclinic.web;

import org.junit.Before;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.samples.petclinic.model.Pet;
import org.springframework.samples.petclinic.service.ClinicService;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.model;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

/**
 * Test class for {@link VisitController}
 *
 * @author Colin But
 */

@ExtendWith(SpringExtension.class)
@WebMvcTest(VisitController.class)
@MockBean(UserDetailsService.class)
public class VisitControllerTests {

  private static final int TEST_PET_ID = 1;

  @Autowired
  private MockMvc mockMvc;

  @MockBean
  private ClinicService clinicService;

  @BeforeEach
  public void init() {
    given(this.clinicService.findPetById(TEST_PET_ID)).willReturn(new Pet());
  }

  @Test
  public void testInitNewVisitForm() throws Exception {
    mockMvc.perform(get("/owners/*/pets/{petId}/visits/new", TEST_PET_ID))
        .andExpect(status().isOk())
        .andExpect(view().name("pets/createOrUpdateVisitForm"));
  }

  @Test
  public void testProcessNewVisitFormSuccess() throws Exception {
    mockMvc.perform(post("/owners/*/pets/{petId}/visits/new", TEST_PET_ID)
        .param("name", "George")
        .param("description", "Visit Description")
    )
        .andExpect(status().is3xxRedirection())
        .andExpect(view().name("redirect:/owners/{ownerId}"));
  }

  @Test
  public void testProcessNewVisitFormHasErrors() throws Exception {
    mockMvc.perform(post("/owners/*/pets/{petId}/visits/new", TEST_PET_ID)
        .param("name", "George")
    )
        .andExpect(model().attributeHasErrors("visit"))
        .andExpect(status().isOk())
        .andExpect(view().name("pets/createOrUpdateVisitForm"));
  }

  @Test
  public void testShowVisits() throws Exception {
    mockMvc.perform(get("/owners/*/pets/{petId}/visits", TEST_PET_ID))
        .andExpect(status().isOk())
        .andExpect(model().attributeExists("visits"))
        .andExpect(view().name("visitList"));
  }


}
