package org.springframework.samples.petclinic.api.application;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Component
@RequiredArgsConstructor
public class ChatServiceClient {

    private final WebClient.Builder webClientBuilder;

    public Mono<String> chat(String sender, String message) {
        return webClientBuilder.build().get()
            .uri("http://chat-agent/chat/{sender}/{message}", sender, message)
            .retrieve()
            .bodyToMono(String.class);
    }
}
