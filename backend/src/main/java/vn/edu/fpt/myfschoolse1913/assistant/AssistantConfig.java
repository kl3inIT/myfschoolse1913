package vn.edu.fpt.myfschoolse1913.assistant;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Wires the student assistant's ChatClient. Conversation memory is attached
 * per turn (see AssistantController) so the admin-tunable window size takes
 * effect immediately; the JDBC repository behind it (spring_ai_chat_memory,
 * Flyway V13) keeps transcripts across restarts.
 */
@Configuration(proxyBeanMethods = false)
class AssistantConfig {

	@Bean
	ChatClient assistantChatClient(ChatClient.Builder builder) {
		return builder.build();
	}
}
