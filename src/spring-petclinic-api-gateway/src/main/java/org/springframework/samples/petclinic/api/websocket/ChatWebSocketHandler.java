package org.springframework.samples.petclinic.api.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.samples.petclinic.api.application.ChatServiceClient;
import org.springframework.samples.petclinic.api.dto.ChatMessage;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.socket.WebSocketHandler;
import org.springframework.web.reactive.socket.WebSocketMessage;
import org.springframework.web.reactive.socket.WebSocketSession;
import reactor.core.publisher.Mono;

@Component
public class ChatWebSocketHandler implements WebSocketHandler {

    private final Logger logger = LoggerFactory.getLogger(ChatWebSocketHandler.class);

    @Autowired
    private ChatServiceClient chatServiceClient;

    @Value("${petclinic.agent.name:petclinic agent}")
    private String agentName;

    @Override
    public Mono<Void> handle(WebSocketSession session) {
        return session.send(
            session.receive()
                .map(WebSocketMessage::getPayloadAsText)
                .flatMap(
                    payload -> processMessage(session, payload)
                )
        );
    }

    private Mono<WebSocketMessage> processMessage(WebSocketSession session, String payload) {
        logger.info("received payload: {}", payload);

        var objectMapper = new ObjectMapper();
        ChatMessage receivedMessage = null;
        try {
            receivedMessage = objectMapper.readValue(payload, ChatMessage.class);
        } catch (Exception e) {
            logger.error("Exception thrown when deserializing client chat message: {}", payload);
            return Mono.empty();
        }

        if (receivedMessage.getType() == ChatMessage.MessageType.JOIN) {
            return Mono.just(session.textMessage(payload));
        } else if (receivedMessage.getType() == ChatMessage.MessageType.CHAT) {
            return chatServiceClient.chat(receivedMessage.getSender(), receivedMessage.getContent())
                .flatMap(responseContent -> {
                    ChatMessage responseMessage = new ChatMessage();
                    responseMessage.setContent(responseContent);
                    responseMessage.setSender(agentName);

                    String responsePayload = null;
                    try {
                        responsePayload = objectMapper.writeValueAsString(responseMessage);
                    } catch (Exception e) {
                        logger.error("Exception thrown when serializing CHAT message: {}", responseMessage);
                        return Mono.empty();
                    }

                    logger.info("response payload: {}", responsePayload);
                    return Mono.just(session.textMessage(responsePayload));
                });
        }

        return Mono.empty();
    }
}
