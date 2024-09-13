package org.springframework.samples.petclinic.chat.controller;

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

    public enum MessageType {

        CHAT, LEAVE, JOIN

    }

}
