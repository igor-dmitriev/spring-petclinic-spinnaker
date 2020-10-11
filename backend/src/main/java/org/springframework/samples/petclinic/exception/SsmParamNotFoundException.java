package org.springframework.samples.petclinic.exception;

public class SsmParamNotFoundException extends RuntimeException {
  public SsmParamNotFoundException(String message) {
    super(message);
  }
}
