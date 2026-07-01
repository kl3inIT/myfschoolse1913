import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

enum AppSessionStatus { checking, authenticated, unauthenticated }

class AppSessionController extends ChangeNotifier {
  AppSessionController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AppSessionStatus _status = AppSessionStatus.checking;
  AuthSession? _session;
  bool _hasInitialized = false;

  AppSessionStatus get status => _status;
  AuthSession? get session => _session;
  bool get isAuthenticated => _status == AppSessionStatus.authenticated;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    _hasInitialized = true;

    final result = await _authRepository.refresh();
    switch (result) {
      case Success(value: final session):
        setAuthenticated(session);
      case Failure():
        await _authRepository.logout();
        _setUnauthenticated();
    }
  }

  void setAuthenticated(AuthSession session) {
    _session = session;
    _status = AppSessionStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AppSessionStatus.checking;
    notifyListeners();

    await _authRepository.logout();
    _setUnauthenticated();
  }

  void _setUnauthenticated() {
    _session = null;
    _status = AppSessionStatus.unauthenticated;
    notifyListeners();
  }
}
