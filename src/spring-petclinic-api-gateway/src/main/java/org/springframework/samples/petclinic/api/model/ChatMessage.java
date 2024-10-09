package org.springframework.samples.petclinic.api.model;

import lombok.*;

/**
 * Represents a chat message in the chat application.
 */
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatMessage {

	private String content;

	private String sender;

	private MessageType type;

	/**
	 * Enum representing the type of the chat message.
	 */
	public enum MessageType {
		CHAT,
        LEAVE,
        JOIN
	}

}
