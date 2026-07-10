package vn.edu.fpt.myfschoolse1913.assistant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "assistant_settings")
public class AssistantSettings {

	static final int SINGLETON_ID = 1;

	@Id
	private Integer id;

	@Column(name = "chat_model", nullable = false, length = 80)
	private String chatModel;

	@Column(name = "temperature")
	private Double temperature;

	@Column(name = "top_p")
	private Double topP;

	@Column(name = "max_tokens")
	private Integer maxTokens;

	@Column(name = "frequency_penalty")
	private Double frequencyPenalty;

	@Column(name = "presence_penalty")
	private Double presencePenalty;

	@Column(name = "top_k", nullable = false)
	private int topK;

	@Column(name = "similarity_threshold")
	private Double similarityThreshold;

	@Column(name = "memory_window_messages", nullable = false)
	private int memoryWindowMessages;

	@Column(name = "extra_instructions", length = 2000)
	private String extraInstructions;

	@Column(name = "updated_at", nullable = false)
	private Instant updatedAt;

	protected AssistantSettings() {
	}

	AssistantSettings(AssistantSettingsService.Snapshot snapshot, Instant now) {
		this.id = SINGLETON_ID;
		apply(snapshot, now);
	}

	void apply(AssistantSettingsService.Snapshot snapshot, Instant now) {
		this.chatModel = snapshot.chatModel();
		this.temperature = snapshot.temperature();
		this.topP = snapshot.topP();
		this.maxTokens = snapshot.maxTokens();
		this.frequencyPenalty = snapshot.frequencyPenalty();
		this.presencePenalty = snapshot.presencePenalty();
		this.topK = snapshot.topK();
		this.similarityThreshold = snapshot.similarityThreshold();
		this.memoryWindowMessages = snapshot.memoryWindowMessages();
		this.extraInstructions = snapshot.extraInstructions();
		this.updatedAt = now;
	}

	AssistantSettingsService.Snapshot snapshot() {
		return new AssistantSettingsService.Snapshot(
				chatModel,
				temperature,
				topP,
				maxTokens,
				frequencyPenalty,
				presencePenalty,
				topK,
				similarityThreshold,
				memoryWindowMessages,
				extraInstructions,
				updatedAt
		);
	}
}
