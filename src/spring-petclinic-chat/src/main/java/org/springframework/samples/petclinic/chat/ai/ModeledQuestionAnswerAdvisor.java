package org.springframework.samples.petclinic.chat.ai;

import org.springframework.ai.chat.client.AdvisedRequest;
import org.springframework.ai.chat.client.advisor.QuestionAnswerAdvisor;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;

import java.util.Map;

public class ModeledQuestionAnswerAdvisor extends QuestionAnswerAdvisor {
	private static final String TRANSLATE = "Generate 1 different versions of a provided user query. " +
		"but they should all retain the original meaning. " +
		"It will be used to retrieve relevant documents and it should be in English \n" +
		"Without enumerations, hyphens, or any additional formatting!";

	private ChatModel chatModel;

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, ChatModel chatModel, String modeledText) {
		super(vectorStore);
		this.chatModel = chatModel;
	}

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, SearchRequest searchRequest, ChatModel chatModel) {
		super(vectorStore, searchRequest);
		this.chatModel = chatModel;
	}

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, SearchRequest searchRequest, String userTextAdvise, ChatModel chatModel) {
		super(vectorStore, searchRequest, userTextAdvise);
		this.chatModel = chatModel;
	}

	@Override
	public AdvisedRequest adviseRequest(AdvisedRequest request, Map<String, Object> context) {
		String originalUserText = request.userText();
		String processedMessage = chatModel.call(TRANSLATE + "\n" + request.userText());
		AdvisedRequest processedRequest = AdvisedRequest.from(request).withUserText(processedMessage).build();
		request = super.adviseRequest(processedRequest, context);
		return AdvisedRequest.from(request).withUserText(originalUserText).build();
	}
}
