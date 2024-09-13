package org.springframework.samples.petclinic.chat.ai;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.ChatClientCustomizer;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.InMemoryChatMemory;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.reader.TextReader;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.SimpleVectorStore;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;

import java.util.List;


@Configuration
public class AgentConfig {

    @Bean
    public ChatClient chatClient(ChatClient.Builder chatClientBuilder) {
        return chatClientBuilder.build();
    }

    @Bean
    public ChatClientCustomizer chatClientCustomizer(VectorStore vectorStore, ChatModel model) {
        ChatMemory chatMemory = new InMemoryChatMemory();
        return b -> b.defaultAdvisors(
				new PromptChatMemoryAdvisor(chatMemory),
				new ModeledQuestionAnswerAdvisor(vectorStore, SearchRequest.defaults(), model));
    }

    @Bean
    public VectorStore simpleVectorStore(EmbeddingModel embeddingModel) {
        Resource resource = new DefaultResourceLoader().getResource("classpath:petclinic-terms-of-use.txt");
        TextReader textReader = new TextReader(resource);
        List<Document> documents = new TokenTextSplitter().apply(textReader.get());
        VectorStore store = new SimpleVectorStore(embeddingModel);
        store.add(documents);
        return store;
    }
}
