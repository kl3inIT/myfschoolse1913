import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:myfschoolse1913/vn/edu/fpt/app/app_config.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/auth_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/token_storage.dart';

class AppServices {
  AppServices._({
    required this.httpClient,
    required this.apiClient,
    required this.authApiService,
    required this.tokenStorage,
    required this.authRepository,
    required this.sessionController,
  });

  factory AppServices.production(AppConfig config) {
    final httpClient = http.Client();
    final apiClient = ApiClient(baseUri: config.apiBaseUri, client: httpClient);
    final authApiService = AuthApiService(apiClient);
    final tokenStorage = SecureTokenStorage();
    final authRepository = AuthRepository(
      authApiService: authApiService,
      tokenStorage: tokenStorage,
    );
    final sessionController = AppSessionController(
      authRepository: authRepository,
    );

    return AppServices._(
      httpClient: httpClient,
      apiClient: apiClient,
      authApiService: authApiService,
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      sessionController: sessionController,
    );
  }

  final http.Client httpClient;
  final ApiClient apiClient;
  final AuthApiService authApiService;
  final TokenStorage tokenStorage;
  final AuthRepository authRepository;
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
