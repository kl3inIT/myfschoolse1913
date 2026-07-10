package vn.edu.fpt.myfschoolse1913.assistant;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.io.IOException;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import tools.jackson.databind.ObjectMapper;
import vn.edu.fpt.myfschoolse1913.student.CurrentStudentService;

/**
 * The in-app student assistant. One POST = one streamed turn: the model
 * grounds answers by calling the read-only StudentAssistantTools, text deltas
 * stream back over SSE as {"text": "..."} events. Memory is keyed by the
 * student's user id, so each student has exactly one private conversation.
 */
@RestController
@RequestMapping("/api/students/me/assistant")
class AssistantController {

	private static final Logger log = LoggerFactory.getLogger(AssistantController.class);

	// A turn can chain several tool calls plus the final reply (each LLM call
	// already allows 60s + 2 retries), so give the whole turn room to finish.
	private static final long TURN_TIMEOUT_MILLIS = 120_000L;

	private static final String SYSTEM_PROMPT = """
			Bạn là trợ lý học tập trong ứng dụng MyFSchool, đang trò chuyện với học sinh %s, \
			lớp %s, năm học %s.

			Hôm nay là %s (%s). Mọi giờ giấc đều theo giờ địa phương của học sinh.

			<behavior>
			- Mọi câu hỏi về lịch học, điểm số, thông báo hoặc đơn từ: gọi tool tương ứng \
			thay vì đoán. Không bịa dữ liệu; nếu tool không có dữ liệu, nói rõ là chưa có.
			- Câu hỏi về nội quy, quy chế, thông tin trường hoặc tài liệu môn học: gọi \
			searchSchoolDocuments trước khi trả lời và nêu tên tài liệu nguồn trong câu \
			trả lời. Nếu không tìm thấy, nói rõ kho tài liệu chưa có nội dung đó.
			- Tự quy đổi ngày tương đối ("mai", "thứ 6 tuần sau") sang ngày cụ thể trước \
			khi gọi tool hoặc trả lời.
			- Trả lời bằng tiếng Việt, thân thiện, xưng hô phù hợp với học sinh cấp 3. \
			Ngắn gọn: vài câu, hoặc danh sách gọn khi liệt kê. Không dùng đề mục.
			- Chỉ hỗ trợ chủ đề học tập và trường lớp; với chủ đề khác, từ chối nhẹ nhàng \
			và gợi ý quay lại việc học.
			</behavior>""";

	private final ChatClient chat;
	private final StudentAssistantTools tools;
	private final CurrentStudentService currentStudentService;
	private final AssistantSettingsService settingsService;
	private final ChatMemoryRepository chatMemoryRepository;
	private final ObjectMapper json;
	private final Clock clock;

	AssistantController(
			ChatClient assistantChatClient,
			StudentAssistantTools tools,
			CurrentStudentService currentStudentService,
			AssistantSettingsService settingsService,
			ChatMemoryRepository chatMemoryRepository,
			ObjectMapper json,
			Clock clock
	) {
		this.chat = assistantChatClient;
		this.tools = tools;
		this.currentStudentService = currentStudentService;
		this.settingsService = settingsService;
		this.chatMemoryRepository = chatMemoryRepository;
		this.json = json;
		this.clock = clock;
	}

	@PostMapping(value = "/chat", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
	public SseEmitter chat(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody ChatRequest request) {
		var userId = UUID.fromString(jwt.getSubject());
		// Fetch-joined (user, class, academic year), safe outside a transaction;
		// also rejects non-student sessions before any LLM spend.
		var student = currentStudentService.requireCurrentStudent(userId);
		var settings = settingsService.current();
		var today = LocalDate.now(clock);

		var systemPrompt = SYSTEM_PROMPT.formatted(
				student.getUser().getFullName(),
				student.getSchoolClass().getName(),
				student.getSchoolClass().getAcademicYear().getName(),
				today,
				dayLabel(today.getDayOfWeek()));
		if (settings.extraInstructions() != null) {
			systemPrompt += "\n\n<school_instructions>\n"
					+ settings.extraInstructions()
					+ "\n</school_instructions>";
		}

		// Memory rides per turn so the admin-tuned window applies immediately.
		var memoryAdvisor = MessageChatMemoryAdvisor.builder(
				MessageWindowChatMemory.builder()
						.chatMemoryRepository(chatMemoryRepository)
						.maxMessages(settings.memoryWindowMessages())
						.build())
				.build();

		var emitter = new SseEmitter(TURN_TIMEOUT_MILLIS);
		chat.prompt()
				.system(systemPrompt)
				.user(request.message().strip())
				.options(chatOptions(settings))
				.tools(tools)
				.toolContext(Map.of(
						StudentAssistantTools.USER_ID, userId,
						StudentAssistantTools.SETTINGS, settings
				))
				.advisors((advisors) -> advisors
						.advisors(memoryAdvisor)
						.param(ChatMemory.CONVERSATION_ID, userId.toString()))
				.stream()
				.content()
				.subscribe(
						(token) -> send(emitter, Map.of("text", token)),
						(error) -> {
							log.warn("Assistant turn failed for user {}", userId, error);
							send(emitter, Map.of("error", "Trợ lý đang gặp sự cố. Vui lòng thử lại sau."));
							emitter.complete();
						},
						emitter::complete
				);
		return emitter;
	}

	private ChatOptions.Builder chatOptions(AssistantSettingsService.Snapshot settings) {
		var options = ChatOptions.builder().model(settings.chatModel());
		if (settings.temperature() != null) {
			options.temperature(settings.temperature());
		}
		if (settings.topP() != null) {
			options.topP(settings.topP());
		}
		if (settings.maxTokens() != null) {
			options.maxTokens(settings.maxTokens());
		}
		if (settings.frequencyPenalty() != null) {
			options.frequencyPenalty(settings.frequencyPenalty());
		}
		if (settings.presencePenalty() != null) {
			options.presencePenalty(settings.presencePenalty());
		}
		return options;
	}

	private void send(SseEmitter emitter, Map<String, String> payload) {
		try {
			emitter.send(SseEmitter.event().data(json.writeValueAsString(payload), MediaType.APPLICATION_JSON));
		} catch (IOException | IllegalStateException exception) {
			// Client went away mid-stream (closed the chat screen) — stop quietly.
			emitter.completeWithError(exception);
		}
	}

	private String dayLabel(DayOfWeek dayOfWeek) {
		return switch (dayOfWeek) {
			case MONDAY -> "Thứ hai";
			case TUESDAY -> "Thứ ba";
			case WEDNESDAY -> "Thứ tư";
			case THURSDAY -> "Thứ năm";
			case FRIDAY -> "Thứ sáu";
			case SATURDAY -> "Thứ bảy";
			case SUNDAY -> "Chủ nhật";
		};
	}

	record ChatRequest(@NotBlank @Size(max = 4_000) String message) {
	}
}
