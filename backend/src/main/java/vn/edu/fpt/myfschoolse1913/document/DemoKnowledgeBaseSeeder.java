package vn.edu.fpt.myfschoolse1913.document;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.ClassPathResource;

@Configuration
@ConditionalOnProperty(prefix = "app.bootstrap.demo-user", name = "enabled", havingValue = "true")
public class DemoKnowledgeBaseSeeder {

	@Bean
	@Order(2)
	ApplicationRunner seedDemoKnowledgeBase(
			SchoolDocumentRepository documentRepository,
			SchoolDocumentIngestionService ingestionService,
			Clock clock
	) {
		return (args) -> {
			for (var fixture : fixtures()) {
				if (documentRepository.findByTitle(fixture.title()).isPresent()) {
					continue;
				}
				byte[] content = new ClassPathResource(fixture.resourcePath()).getContentAsByteArray();
				Instant now = Instant.now(clock);
				var document = documentRepository.save(new SchoolDocument(
						fixture.title(),
						fixture.category(),
						fixture.subjectName(),
						fixture.fileName(),
						"text/markdown",
						content,
						now
				));
				try {
					int chunks = ingestionService.ingest(document);
					document.markIndexed(chunks, Instant.now(clock));
					documentRepository.save(document);
				} catch (RuntimeException exception) {
					document.markFailed("Không lập chỉ mục được dữ liệu demo", Instant.now(clock));
					documentRepository.save(document);
					throw exception;
				}
			}
		};
	}

	private List<DocumentFixture> fixtures() {
		return List.of(
				new DocumentFixture(
						"Nội quy học sinh - Bản demo 2026-2027",
						SchoolDocumentCategory.REGULATION,
						null,
						"noi-quy-hoc-sinh-demo.md"
				),
				new DocumentFixture(
						"Hướng dẫn đơn từ và nghỉ học",
						SchoolDocumentCategory.REGULATION,
						null,
						"huong-dan-don-tu.md"
				),
				new DocumentFixture(
						"Quy chế kiểm tra và đánh giá học tập",
						SchoolDocumentCategory.REGULATION,
						null,
						"quy-che-kiem-tra-danh-gia.md"
				),
				new DocumentFixture(
						"Dịch vụ học đường và thông tin liên hệ",
						SchoolDocumentCategory.SCHOOL_INFO,
						null,
						"dich-vu-hoc-duong.md"
				),
				new DocumentFixture(
						"Câu lạc bộ và hoạt động ngoại khóa",
						SchoolDocumentCategory.SCHOOL_INFO,
						null,
						"cau-lac-bo-ngoai-khoa.md"
				),
				new DocumentFixture(
						"Ôn tập Hàm số bậc hai - Toán 10",
						SchoolDocumentCategory.SUBJECT_MATERIAL,
						"Toán học",
						"on-tap-ham-so-bac-hai.md"
				)
		);
	}

	private record DocumentFixture(
			String title,
			SchoolDocumentCategory category,
			String subjectName,
			String fileName
	) {
		String resourcePath() {
			return "demo/knowledge/" + fileName;
		}
	}
}
