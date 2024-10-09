package org.springframework.samples.petclinic.api.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class ChatService {

    private final String hostname = "http://chat-agent/";

    private final RestTemplate restTemplate;

    public ChatService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String chat(String sender, String message) {
        return restTemplate.getForObject(hostname + "chat/{sender}/{message}", String.class, sender, message);
    }

}
