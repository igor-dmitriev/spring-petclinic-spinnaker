package org.springframework.samples.petclinic;

import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.Environment;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class DynamicEnvironmentPropertiesLoggingListener implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {
  private static final String FORMAT_PATTERN = "{} : {}";

  private static final String SPRING_PROFILES_ACTIVE = "spring.profiles.active";
  private static final String SPRING_DATASOURCE_URL = "spring.datasource.url";

  @Override
  public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
    log.info("--------------------- Application dynamic properties ------------------------------------------------------");
    Environment env = event.getEnvironment();
    log.info(FORMAT_PATTERN, SPRING_PROFILES_ACTIVE, env.getProperty(SPRING_PROFILES_ACTIVE));
    log.info(FORMAT_PATTERN, SPRING_DATASOURCE_URL, env.getProperty(SPRING_DATASOURCE_URL));
  }
}
