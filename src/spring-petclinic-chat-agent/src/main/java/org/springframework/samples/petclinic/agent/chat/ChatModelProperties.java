package org.springframework.samples.petclinic.agent.chat;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = ChatModelProperties.PREFIX)
public class ChatModelProperties {

	static final String PREFIX = "spring.ai.azure.openai";

	String endpoint;

	String clientId;

}
