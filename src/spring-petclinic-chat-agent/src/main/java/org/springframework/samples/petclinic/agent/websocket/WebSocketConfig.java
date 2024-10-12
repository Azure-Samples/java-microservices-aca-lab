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

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * Configuration class for WebSocket messaging in the application.
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

	/**
	 * Registers the Stomp endpoints for WebSocket communication. param registry the
	 * StompEndpointRegistry to register the endpoints
	 */
	@Override
	public void registerStompEndpoints(StompEndpointRegistry registry) {
		// client connects to the WebSocket server via the /websocket endpoint.
		registry.addEndpoint("/websocket").withSockJS();
	}

	/**
	 * Configures the message broker for WebSocket communication. param registry the
	 * MessageBrokerRegistry to configure the message broker
	 */
	@Override
	public void configureMessageBroker(MessageBrokerRegistry registry) {
		// server processes the message and send updates to all clients subscribed to /topic.
		registry.enableSimpleBroker("/topic");
		// clients send messages prefixed with /app to the server
		registry.setApplicationDestinationPrefixes("/app");
	}

}
