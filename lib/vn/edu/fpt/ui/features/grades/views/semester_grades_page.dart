import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/grades_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/semester_grades.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/grades/view_models/semester_grades_view_model.dart';

class SemesterGradesPage extends StatefulWidget {
  const SemesterGradesPage({
    super.key,
    required this.gradesRepository,
    required this.sessionController,
  });

  final GradesRepository gradesRepository;
  final AppSessionController sessionController;

  @override
  State<SemesterGradesPage> createState() => _SemesterGradesPageState();
}

class _SemesterGradesPageState extends State<SemesterGradesPage> {
  late final SemesterGradesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SemesterGradesViewModel(
      gradesRepository: widget.gradesRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrades();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadGrades() async {
    final result = await _viewModel.loadGrades();
    if (!mounted || result != SemesterGradesLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _goHome() {
    context.go(AppRoutes.home);
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        _goHome();
        break;
      case 1:
        context.go(AppRoutes.schedule);
        break;
      case 2:
        context.go(AppRoutes.notifications);
        break;
      case 3:
        context.go(AppRoutes.account);
        break;
    }
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
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final state = _viewModel.state;

                  return Column(
                    children: [
                      StudentTopAppBar(title: 'Điểm học kỳ', onBack: _goHome),
                      Expanded(
                        child: _SemesterGradesBody(
                          grades: state.grades,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadGrades,
                        ),
                      ),
                      StudentBottomNavigation(
                        currentIndex: 0,
                        onDestinationSelected: _onDestinationSelected,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SemesterGradesBody extends StatelessWidget {
  const _SemesterGradesBody({
    required this.grades,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final SemesterGrades? grades;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedGrades = grades;

    if (isLoading && loadedGrades == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedGrades == null) {
      return _GradesError(message: errorMessage, onRetry: onRetry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(
          loadedGrades.semester,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: FptColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tổng quan kết quả học tập',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FptColors.textSecondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _GradeSummaryCard(grades: loadedGrades),
        const SizedBox(height: 24),
        Text(
          'Bảng điểm môn học',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: FptColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final subject in loadedGrades.subjects) ...[
          _SubjectGradeTile(subject: subject),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GradeSummaryCard extends StatelessWidget {
  const _GradeSummaryCard({required this.grades});

  final SemesterGrades grades;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm trung bình',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  grades.averageScore.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: FptColors.orangeDeep,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _RankChip(rank: grades.rank),
        ],
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({required this.rank});

  final String rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      constraints: const BoxConstraints(minWidth: 88),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        rank,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SubjectGradeTile extends StatelessWidget {
  const _SubjectGradeTile({required this.subject});

  final SubjectGrade subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FptColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 42,
            child: Text(
              subject.score.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FptColors.blue,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradesError extends StatelessWidget {
  const _GradesError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Không thể tải điểm học kỳ',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: FptColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
