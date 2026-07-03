import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:myfschoolse1913/vn/edu/fpt/app/app_config.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/applications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/clubs_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/dashboard_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/events_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/grades_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/schedule_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/user_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/applications_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/auth_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/clubs_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/dashboard_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/events_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/grades_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/schedule_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/token_storage.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/user_api_service.dart';

class AppServices {
  AppServices._({
    required this.httpClient,
    required this.apiClient,
    required this.authApiService,
    required this.authenticatedApiClient,
    required this.applicationsApiService,
    required this.clubsApiService,
    required this.dashboardApiService,
    required this.eventsApiService,
    required this.gradesApiService,
    required this.scheduleApiService,
    required this.userApiService,
    required this.tokenStorage,
    required this.applicationsRepository,
    required this.authRepository,
    required this.clubsRepository,
    required this.dashboardRepository,
    required this.eventsRepository,
    required this.gradesRepository,
    required this.scheduleRepository,
    required this.userRepository,
    required this.sessionController,
  });

  factory AppServices.production(AppConfig config) {
    final httpClient = http.Client();
    final apiClient = ApiClient(baseUri: config.apiBaseUri, client: httpClient);
    final authApiService = AuthApiService(apiClient);
    final tokenStorage = SecureTokenStorage();
    final authenticatedApiClient = AuthenticatedApiClient(
      apiClient: apiClient,
      authApiService: authApiService,
      tokenStorage: tokenStorage,
    );
    final applicationsApiService = ApplicationsApiService(
      authenticatedApiClient,
    );
    final clubsApiService = ClubsApiService(authenticatedApiClient);
    final dashboardApiService = DashboardApiService(authenticatedApiClient);
    final eventsApiService = EventsApiService(authenticatedApiClient);
    final gradesApiService = GradesApiService(authenticatedApiClient);
    final scheduleApiService = ScheduleApiService(authenticatedApiClient);
    final userApiService = UserApiService(authenticatedApiClient);
    final authRepository = AuthRepository(
      authApiService: authApiService,
      tokenStorage: tokenStorage,
    );
    final applicationsRepository = ApplicationsRepository(
      applicationsApiService: applicationsApiService,
    );
    final clubsRepository = ClubsRepository(clubsApiService: clubsApiService);
    final dashboardRepository = DashboardRepository(
      dashboardApiService: dashboardApiService,
    );
    final eventsRepository = EventsRepository(
      eventsApiService: eventsApiService,
    );
    final gradesRepository = GradesRepository(
      gradesApiService: gradesApiService,
    );
    final scheduleRepository = ScheduleRepository(
      scheduleApiService: scheduleApiService,
    );
    final userRepository = UserRepository(userApiService: userApiService);
    final sessionController = AppSessionController(
      authRepository: authRepository,
    );

    return AppServices._(
      httpClient: httpClient,
      apiClient: apiClient,
      authApiService: authApiService,
      authenticatedApiClient: authenticatedApiClient,
      applicationsApiService: applicationsApiService,
      clubsApiService: clubsApiService,
      dashboardApiService: dashboardApiService,
      eventsApiService: eventsApiService,
      gradesApiService: gradesApiService,
      scheduleApiService: scheduleApiService,
      userApiService: userApiService,
      tokenStorage: tokenStorage,
      applicationsRepository: applicationsRepository,
      authRepository: authRepository,
      clubsRepository: clubsRepository,
      dashboardRepository: dashboardRepository,
      eventsRepository: eventsRepository,
      gradesRepository: gradesRepository,
      scheduleRepository: scheduleRepository,
      userRepository: userRepository,
      sessionController: sessionController,
    );
  }

  final http.Client httpClient;
  final ApiClient apiClient;
  final AuthApiService authApiService;
  final AuthenticatedApiClient authenticatedApiClient;
  final ApplicationsApiService applicationsApiService;
  final ClubsApiService clubsApiService;
  final DashboardApiService dashboardApiService;
  final EventsApiService eventsApiService;
  final GradesApiService gradesApiService;
  final ScheduleApiService scheduleApiService;
  final UserApiService userApiService;
  final TokenStorage tokenStorage;
  final ApplicationsRepository applicationsRepository;
  final AuthRepository authRepository;
  final ClubsRepository clubsRepository;
  final DashboardRepository dashboardRepository;
  final EventsRepository eventsRepository;
  final GradesRepository gradesRepository;
  final ScheduleRepository scheduleRepository;
  final UserRepository userRepository;
  final AppSessionController sessionController;

  void dispose() {
    sessionController.dispose();
    httpClient.close();
  }
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(scope != null, 'AppDependencies was not found in the widget tree.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) {
    return services != oldWidget.services;
  }
}
