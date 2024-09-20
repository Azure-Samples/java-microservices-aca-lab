package org.springframework.samples.petclinic.agent.chat;

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
