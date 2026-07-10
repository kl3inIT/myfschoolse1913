package vn.edu.fpt.myfschoolse1913.assistant;

import java.time.Clock;
import java.time.Instant;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Single-row runtime settings for the assistant. Reads fall back to defaults
 * (the configured chat model, topK 5, a 30-message window, provider-default
 * sampling) until an admin saves the row, so the assistant works out of the
 * box. Nullable model options mean "use the provider's default".
 */
@Service
public class AssistantSettingsService {

	static final int DEFAULT_TOP_K = 5;
	static final int DEFAULT_MEMORY_WINDOW_MESSAGES = 30;

	private final AssistantSettingsRepository settingsRepository;
	private final String defaultChatModel;
	private final Clock clock;

	AssistantSettingsService(
			AssistantSettingsRepository settingsRepository,
			@Value("${spring.ai.openai.chat.model}") String defaultChatModel,
			Clock clock
	) {
		this.settingsRepository = settingsRepository;
		this.defaultChatModel = defaultChatModel;
		this.clock = clock;
	}

	@Transactional(readOnly = true)
	public Snapshot current() {
		return settingsRepository.findById(AssistantSettings.SINGLETON_ID)
				.map(AssistantSettings::snapshot)
				.orElseGet(this::defaults);
	}

	@Transactional
	public Snapshot update(Snapshot requested) {
		Instant now = Instant.now(clock);
		Snapshot normalized = requested.normalized(now);

		var settings = settingsRepository.findById(AssistantSettings.SINGLETON_ID)
				.orElse(null);
		if (settings == null) {
			settings = settingsRepository.save(new AssistantSettings(normalized, now));
		} else {
			settings.apply(normalized, now);
		}

		return settings.snapshot();
	}

	private Snapshot defaults() {
		return new Snapshot(
				defaultChatModel,
				null,
				null,
				null,
				null,
				null,
				DEFAULT_TOP_K,
				null,
				DEFAULT_MEMORY_WINDOW_MESSAGES,
				null,
				null
		);
	}

	public record Snapshot(
			String chatModel,
			Double temperature,
			Double topP,
			Integer maxTokens,
			Double frequencyPenalty,
			Double presencePenalty,
			int topK,
			Double similarityThreshold,
			int memoryWindowMessages,
			String extraInstructions,
			Instant updatedAt
	) {

		Snapshot normalized(Instant now) {
			return new Snapshot(
					chatModel.strip(),
					temperature,
					topP,
					maxTokens,
					frequencyPenalty,
					presencePenalty,
					topK,
					similarityThreshold,
					memoryWindowMessages,
					extraInstructions == null || extraInstructions.isBlank()
							? null
							: extraInstructions.strip(),
					now
			);
		}
	}
}
