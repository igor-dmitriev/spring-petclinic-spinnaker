package org.springframework.samples.petclinic;

import com.google.common.collect.Lists;

import org.springframework.samples.petclinic.exception.SsmParamNotFoundException;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;

import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ssm.SsmClient;
import software.amazon.awssdk.services.ssm.model.GetParametersRequest;
import software.amazon.awssdk.services.ssm.model.GetParametersResponse;
import software.amazon.awssdk.services.ssm.model.Parameter;

import static java.util.stream.Collectors.toMap;

@Slf4j
@UtilityClass
public class DynamicEnvironmentProperties {
  private final Properties EMPTY_PROPERTIES = new Properties();
  private final int MAX_COUNT_PARAMS_TO_RETRIEVE_FROM_SSM = 10;
  private final String SPRING_PROFILE_ENV = "SPRING_PROFILE";
  private final String SSM_PREFIX_ENV = "SSM_PREFIX";

  public Properties properties() {
    log.info("{}: {}", SPRING_PROFILE_ENV, System.getenv(SPRING_PROFILE_ENV));
    log.info("{}: {}", SSM_PREFIX_ENV, System.getenv(SSM_PREFIX_ENV));
    String springProfile = System.getenv(SPRING_PROFILE_ENV);
    String ssmPrefix = System.getenv(SSM_PREFIX_ENV);
    if (springProfile == null) {
      return EMPTY_PROPERTIES;
    }
    return getProperties(springProfile, ssmPrefix);
  }

  private Properties getProperties(String springProfile, String ssmPrefix) {
    // DB
    String dbUrlSsmParam = String.format("%s/db/url", ssmPrefix);
    String dbPasswordSsmParam = String.format("%s/db/password", ssmPrefix);

    Map<String, String> parameters = getSsmParams(
        dbUrlSsmParam,
        dbPasswordSsmParam
    );

    Properties properties = new Properties();
    properties.setProperty(SPRING_PROFILE_ENV, springProfile);
    properties.setProperty("AWS_DB_HOST", getParameterSafely(parameters, dbUrlSsmParam));
    properties.setProperty("AWS_DB_PASSWORD", getParameterSafely(parameters, dbPasswordSsmParam));

    return properties;
  }

  private Map<String, String> getSsmParams(String... params) {
    SsmClient ssmClient = SsmClient.builder()
        .region(region())
        .build();
    return Lists.partition(Arrays.asList(params), MAX_COUNT_PARAMS_TO_RETRIEVE_FROM_SSM)
        .stream()
        .map(batchParams -> ssmClient.getParameters(GetParametersRequest.builder().names(batchParams).withDecryption(Boolean.TRUE).build()))
        .map(GetParametersResponse::parameters)
        .flatMap(List::stream)
        .collect(toMap(Parameter::name, Parameter::value));
  }

  private Region region() {
    String region = System.getenv("EC2_REGION");
    if (region == null) {
      throw new IllegalStateException("EC2_REGION environment variable must be provided");
    }
    return Region.of(region);
  }

  private String getParameterSafely(Map<String, String> parameters, String searchParam) {
    return Optional.ofNullable(parameters.get(searchParam))
        .orElseThrow(() -> new SsmParamNotFoundException(String.format("%s parameter was not found", searchParam)));
  }
}