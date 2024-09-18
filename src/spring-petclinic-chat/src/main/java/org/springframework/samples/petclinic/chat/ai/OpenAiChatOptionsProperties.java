package org.springframework.samples.petclinic.chat.ai;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = OpenAiChatOptionsProperties.PREFIX)
public class OpenAiChatOptionsProperties {

    static final String PREFIX = "spring.ai.azure.openai.chat.options";

    String deploymentName;

    Double temperature;

}
