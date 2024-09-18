package org.springframework.samples.petclinic.agent.chat;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.ai.chat.prompt.SystemPromptTemplate;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import static org.springframework.ai.chat.client.advisor.AbstractChatMemoryAdvisor.CHAT_MEMORY_CONVERSATION_ID_KEY;

@Component
public class Agent {

	private Logger logger = LoggerFactory.getLogger(Agent.class);

	private static final String TRANSLATE = "Generate 1 different versions of a provided user query. "
			+ "but they should all retain the original meaning. "
			+ "It will be used to retrieve relevant documents from a English document. "
			+ "Without enumerations, hyphens, or any additional formatting!";

	@Autowired
	private ChatClient chatClient;

	@Autowired
	private VectorStore vectorStore;

	@Value("classpath:/prompts/system-message.st")
	private Resource systemResource;

	/**
	 * orchestrates the chat interaction
	 * @param userMessage: the message that the user sends.
	 * @param username: used for keeping track of conversations.
	 */
	public String chat(String userMessage, String username) {
		try {
			// customize chat behavior by associating the conversation with username
			Consumer<ChatClient.AdvisorSpec> advisorSpecConsumer = advisorSpec -> {
				advisorSpec.param(CHAT_MEMORY_CONVERSATION_ID_KEY, username);
			};
			// generate structured prompts based on system messages or templates
			PromptTemplate systemPromptTemplate = new SystemPromptTemplate(systemResource);
			Map<String, Object> systemParameters = new HashMap<>() {
				{
					put("username", username);
				}
			};

			return chatClient.prompt()
				// username as memory key
				.advisors(advisorSpecConsumer)
				.system(systemPromptTemplate.render(systemParameters))
				.user(userMessage)
				.functions("queryOwners", "addOwner", "updateOwner", "queryVets")
				.call()
				.content();
		}
		catch (Exception e) {
			logger.error("Exception thrown: " + e);
			return "Sorry, I am not able to help you with that.";
		}
	}

}
