package org.springframework.samples.petclinic.chat.ai;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = OpenAiModelConfigProperties.PREFIX)
public class OpenAiModelConfigProperties {

    static final String PREFIX = "spring.ai.azure.openai";

    String endpoint;
}
