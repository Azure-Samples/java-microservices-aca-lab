package org.springframework.samples.petclinic.agent.chat;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller class for handling chat-related functionality.
 */
@Controller
public class ChatController {

    private final Logger logger = LoggerFactory.getLogger(ChatController.class);

	@Autowired
	private Agent agent;

	@Value("${petclinic.agent.name:petclinic}")
	private String agentName;

	public void setAgent(Agent agent) {
		this.agent = agent;
	}

	/**
	 * Registers a user for chat.
	 * <p>
	 * param chatMessage The chat message containing the sender's information. param
	 * headerAccessor The SimpMessageHeaderAccessor object used to access session
	 * attributes. return The registered chat message.
	 */
	@MessageMapping("/chat.register")
	@SendTo("/topic/public")
	public ChatMessage register(@Payload ChatMessage chatMessage, SimpMessageHeaderAccessor headerAccessor) {
		headerAccessor.getSessionAttributes().put("username", chatMessage.getSender());
		return chatMessage;
	}

	/**
	 * Sends a chat message to all connected users.
	 * <p>
	 * param chatMessage The chat message to be sent. return The sent chat message.
	 */
	@MessageMapping("/chat.send")
	@SendTo("/topic/public")
	public ChatMessage sendMessage(@Payload ChatMessage chatMessage) {
		chatMessage.setContent(agent.chat(chatMessage.getContent(), chatMessage.getSender()));
		chatMessage.setSender(agentName);
		return chatMessage;
	}

	@GetMapping("/chat.html")
	public String chatPage() {
		return "chat/chat";
	}


    @GetMapping("/chat/{sender}/{message}")
    @ResponseBody
    public String sendMessage(@PathVariable("sender") String sender, @PathVariable("message") String message) {
        logger.info("received from {}: {}", sender, message);
        String response = agent.chat(message, sender);
        logger.info("response to {}: {}", sender, response);
        return response;
    }
}
