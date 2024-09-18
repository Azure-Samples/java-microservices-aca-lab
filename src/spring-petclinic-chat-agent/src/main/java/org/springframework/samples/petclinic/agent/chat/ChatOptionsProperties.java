package org.springframework.samples.petclinic.agent.chat;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = ChatOptionsProperties.PREFIX)
class ChatOptionsProperties {

    static final String PREFIX = "spring.ai.azure.openai.chat.options";

    String deploymentName;

    Float temperature;

}
