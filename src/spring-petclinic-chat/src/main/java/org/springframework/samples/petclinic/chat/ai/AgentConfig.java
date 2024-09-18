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
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;

import com.azure.ai.openai.OpenAIClient;
import com.azure.ai.openai.OpenAIClientBuilder;
import com.azure.identity.DefaultAzureCredentialBuilder;
import org.springframework.ai.azure.openai.AzureOpenAiChatModel;
import org.springframework.ai.azure.openai.AzureOpenAiChatOptions;
import org.springframework.ai.model.function.FunctionCallbackContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.ApplicationContext;

import java.util.List;


@Configuration
@EnableConfigurationProperties({OpenAiModelConfigProperties.class, OpenAiChatOptionsProperties.class})
public class AgentConfig {


    @Autowired
    private ApplicationContext applicationContext;

    /**
     * Configure a bean of type AzureOpenAiChatModel as ChatModel
     */
    @Bean
    @ConditionalOnProperty(OpenAiChatOptionsProperties.PREFIX + ".deployment-name")
    public AzureOpenAiChatModel chatModel(OpenAIClient openAIClient, OpenAiChatOptionsProperties properties) {
        var openAIChatOptions = AzureOpenAiChatOptions.builder()
            .withDeploymentName(properties.getDeploymentName())
            .withTemperature(properties.getTemperature())
            .build();

        // provide Context to load function callbacks
        var functionCallbackContext = new FunctionCallbackContext();
        functionCallbackContext.setApplicationContext(applicationContext);
        return new AzureOpenAiChatModel(openAIClient, openAIChatOptions, functionCallbackContext);
    }

    /**
     * Configure a bean of type OpenAIClient, which is used to construct ChatModel and EmbeddingModel
     */
    @Bean
    @ConditionalOnProperty(OpenAiModelConfigProperties.PREFIX + ".endpoint")
    public OpenAIClient openAIClient(OpenAiModelConfigProperties properties) {
        return new OpenAIClientBuilder()
            .endpoint(properties.getEndpoint())
            .credential(new DefaultAzureCredentialBuilder()
                .build())
            .buildClient();
    }


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
        Resource resource = new DefaultResourceLoader().getResource("classpath:/ai/petclinic-terms-of-use.txt");
        TextReader textReader = new TextReader(resource);
        List<Document> documents = new TokenTextSplitter().apply(textReader.get());
        VectorStore store = new SimpleVectorStore(embeddingModel);
        store.add(documents);
        return store;
    }
}
