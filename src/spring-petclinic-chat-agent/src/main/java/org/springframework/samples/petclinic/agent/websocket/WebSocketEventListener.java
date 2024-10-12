/*
 * Copyright 2002-2024 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.springframework.samples.petclinic.agent.websocket;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.samples.petclinic.agent.model.ChatMessage;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

/**
 * Handles the WebSocket disconnect event. Sends a leave message to the "/topic/public"
 * destination when a user disconnects.
 * <p>
 * param event The SessionDisconnectEvent representing the WebSocket disconnect event.
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class WebSocketEventListener {

	// provided by Spring that facilitates sending messages to specific destinations in a WebSocket application
	private final SimpMessageSendingOperations messagingTemplate;

	@EventListener
	public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
		StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
		String username = (String) headerAccessor.getSessionAttributes().get("username");
		if (username != null) {
			log.info("user disconnected: {}", username);
			var chatMessage = ChatMessage.builder().type(ChatMessage.MessageType.LEAVE).sender(username).build();
			messagingTemplate.convertAndSend("/topic/public", chatMessage);
		}
	}

}
