package org.springframework.samples.petclinic.chat.ai;

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
public class ChatAgent {

    private static final String TRANSLATE = "Generate 1 different versions of a provided user query. " +
        "but they should all retain the original meaning. " +
        "It will be used to retrieve relevant documents from a English document. " +
        "Without enumerations, hyphens, or any additional formatting!";

    @Autowired
    private ChatClient chatClient;

    @Value("classpath:/ai/system-message.st")
    private Resource systemResource;

    public String chat(String userMessage, String username) {
        try {
            Consumer<ChatClient.AdvisorSpec> advisorSpecConsumer = advisorSpec -> {
                advisorSpec.param(CHAT_MEMORY_CONVERSATION_ID_KEY, username);
            };
            PromptTemplate systemPromptTemplate = new SystemPromptTemplate(systemResource);
            Map<String, Object> systemParameters = new HashMap<>() {{
                put("username", username);
            }};

            return chatClient
                .prompt()
                .advisors(advisorSpecConsumer)  //userName as memory key
                .system(systemPromptTemplate.render(systemParameters))
                .user(userMessage)
                .functions("queryOwners", "addOwner", "updateOwner", "queryVets")
                .call()
                .content();
        } catch (Exception e) {
            return "Sorry, I am not able to help you with that.";
        }
    }

}
