package vn.edu.fpt.myfschoolse1913.assistant;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/assistant/settings")
public class AdminAssistantSettingsController {

	private final AssistantSettingsService settingsService;

	public AdminAssistantSettingsController(AssistantSettingsService settingsService) {
		this.settingsService = settingsService;
	}

	@GetMapping
	public AssistantSettingsService.Snapshot settings() {
		return settingsService.current();
	}

	@PutMapping
	public AssistantSettingsService.Snapshot update(@Valid @RequestBody UpdateRequest request) {
		return settingsService.update(new AssistantSettingsService.Snapshot(
				request.chatModel(),
				request.temperature(),
				request.topP(),
				request.maxTokens(),
				request.frequencyPenalty(),
				request.presencePenalty(),
				request.topK(),
				request.similarityThreshold(),
				request.memoryWindowMessages(),
				request.extraInstructions(),
				null
		));
	}

	record UpdateRequest(
			@NotBlank(message = "Vui lòng nhập tên model")
			@Size(max = 80, message = "Tên model tối đa 80 ký tự")
			String chatModel,
			@DecimalMin(value = "0", message = "temperature từ 0 đến 2")
			@DecimalMax(value = "2", message = "temperature từ 0 đến 2")
			Double temperature,
			@DecimalMin(value = "0", message = "topP từ 0 đến 1")
			@DecimalMax(value = "1", message = "topP từ 0 đến 1")
			Double topP,
			@Min(value = 1, message = "maxTokens từ 1 đến 32768")
			@Max(value = 32_768, message = "maxTokens từ 1 đến 32768")
			Integer maxTokens,
			@DecimalMin(value = "-2", message = "frequencyPenalty từ -2 đến 2")
			@DecimalMax(value = "2", message = "frequencyPenalty từ -2 đến 2")
			Double frequencyPenalty,
			@DecimalMin(value = "-2", message = "presencePenalty từ -2 đến 2")
			@DecimalMax(value = "2", message = "presencePenalty từ -2 đến 2")
			Double presencePenalty,
			@Min(value = 1, message = "topK tối thiểu là 1")
			@Max(value = 20, message = "topK tối đa là 20")
			int topK,
			@DecimalMin(value = "0", message = "Ngưỡng tương đồng từ 0 đến 1")
			@DecimalMax(value = "1", message = "Ngưỡng tương đồng từ 0 đến 1")
			Double similarityThreshold,
			@Min(value = 2, message = "Cửa sổ hội thoại từ 2 đến 100 tin nhắn")
			@Max(value = 100, message = "Cửa sổ hội thoại từ 2 đến 100 tin nhắn")
			int memoryWindowMessages,
			@Size(max = 2000, message = "Hướng dẫn thêm tối đa 2000 ký tự")
			String extraInstructions
	) {
	}
}
