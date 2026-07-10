import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/assistant_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/assistant/view_models/school_assistant_provider.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key, required this.assistantApiService});

  final AssistantApiService assistantApiService;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  late final SchoolAssistantProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = SchoolAssistantProvider(
      assistantApiService: widget.assistantApiService,
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FptColors.field,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ColoredBox(
              color: Colors.white,
              child: Column(
                children: [
                  const _AssistantHeader(),
                  Expanded(
                    child: LlmChatView(
                      provider: _provider,
                      enableAttachments: false,
                      enableVoiceNotes: false,
                      style: LlmChatViewStyle(
                        chatInputStyle: ChatInputStyle(
                          hintText: 'Hỏi mình bất cứ điều gì...',
                        ),
                      ),
                      welcomeMessage:
                          'Chào bạn! Mình là trợ lý học tập MyFSchool. '
                          'Bạn có thể hỏi mình về lịch học, điểm số, '
                          'thông báo hoặc đơn từ của bạn.',
                      suggestions: const [
                        'Mai mình học những môn gì?',
                        'Điểm trung bình học kỳ này của mình?',
                        'Có thông báo mới nào không?',
                        'Đơn xin nghỉ của mình được duyệt chưa?',
                      ],
                      errorMessage: 'Trợ lý đang gặp sự cố. Vui lòng thử lại.',
                      cancelMessage: 'Đã dừng trả lời.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      color: FptColors.orangeDeep,
      padding: const EdgeInsets.only(left: 8, top: 20, right: 24),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Về trang chủ',
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Trợ lý AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const Icon(Icons.smart_toy_outlined, color: Colors.white),
        ],
      ),
    );
  }
}
