package org.springframework.samples.petclinic.chat;

import org.springframework.ai.autoconfigure.azure.openai.AzureOpenAIClientBuilderCustomizer;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.azure.core.http.HttpClient;
import com.azure.core.util.HttpClientOptions;

import java.time.Duration;

@Configuration
public class AzureOpenAiConfig {

	@Bean
	public AzureOpenAIClientBuilderCustomizer responseTimeoutCustomizer() {
		return openAiClientBuilder -> {
			HttpClientOptions clientOptions = new HttpClientOptions()
					.setResponseTimeout(Duration.ofMinutes(5));
			openAiClientBuilder.httpClient(HttpClient.createDefault(clientOptions));
		};
	}

}