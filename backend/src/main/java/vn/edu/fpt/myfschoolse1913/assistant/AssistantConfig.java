package vn.edu.fpt.myfschoolse1913.assistant;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Wires the student assistant: one ChatClient carrying JDBC-backed
 * conversation memory (spring_ai_chat_memory, Flyway V13) so multi-turn
 * context survives backend restarts. The window cap keeps the prompt from
 * growing without bound.
 */
@Configuration(proxyBeanMethods = false)
class AssistantConfig {

	/** Recent messages the model sees per conversation. */
	private static final int MODEL_WINDOW_MESSAGES = 30;

	@Bean
	ChatMemory assistantChatMemory(ChatMemoryRepository repository) {
		return MessageWindowChatMemory.builder()
				.chatMemoryRepository(repository)
				.maxMessages(MODEL_WINDOW_MESSAGES)
				.build();
	}

	@Bean
	ChatClient assistantChatClient(ChatClient.Builder builder, ChatMemory chatMemory) {
		return builder
				.defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build())
				.build();
	}
}
