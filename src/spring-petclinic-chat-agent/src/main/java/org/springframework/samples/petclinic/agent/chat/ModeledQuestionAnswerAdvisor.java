package org.springframework.samples.petclinic.agent.chat;

import org.springframework.ai.chat.client.AdvisedRequest;
import org.springframework.ai.chat.client.advisor.QuestionAnswerAdvisor;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;

import java.util.Map;

/**
 * This class adds a layer of AI processing to user input, before the input is used to retrieve documents from a
 * VectorStore. It achieves this by using a ChatModel to modify the user's text while retaining the original meaning,
 * which helps optimize the results.
 */
public class ModeledQuestionAnswerAdvisor extends QuestionAnswerAdvisor {

	private static final String TRANSLATE = "Generate 1 different versions of a provided user query. "
			+ "but they should all retain the original meaning. "
			+ "It will be used to retrieve relevant documents and it should be in English \n"
			+ "Without enumerations, hyphens, or any additional formatting!";

	private ChatModel chatModel;

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, ChatModel chatModel, String modeledText) {
		super(vectorStore);
		this.chatModel = chatModel;
	}

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, SearchRequest searchRequest, ChatModel chatModel) {
		super(vectorStore, searchRequest);
		this.chatModel = chatModel;
	}

	public ModeledQuestionAnswerAdvisor(VectorStore vectorStore, SearchRequest searchRequest, String userTextAdvise,
			ChatModel chatModel) {
		super(vectorStore, searchRequest, userTextAdvise);
		this.chatModel = chatModel;
	}

	@Override
	public AdvisedRequest adviseRequest(AdvisedRequest request, Map<String, Object> context) {
		// capture the original user input
		String originalUserText = request.userText();
		// call Chat Model with the TRANSLATE prompt and original input.
		String processedMessage = chatModel.call(TRANSLATE + "\n" + request.userText());
		// create new AdvisedRequest with the processed message, which is used to query for retrieval
		AdvisedRequest processedRequest = AdvisedRequest.from(request).withUserText(processedMessage).build();
		request = super.adviseRequest(processedRequest, context);
		// user still see the original query, but benefir from the behind modification.
		return AdvisedRequest.from(request).withUserText(originalUserText).build();
	}

}
