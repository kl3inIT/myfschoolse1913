import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_config.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_dependencies.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_theme.dart';

class MyFSchoolApp extends StatefulWidget {
  const MyFSchoolApp({super.key, this.restoreSessionOnStart = true});

  final bool restoreSessionOnStart;

  @override
  State<MyFSchoolApp> createState() => _MyFSchoolAppState();
}

class _MyFSchoolAppState extends State<MyFSchoolApp> {
  late final AppServices _services;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final config = AppConfig.fromEnvironment();
    _services = AppServices.production(config);
    _router = createAppRouter(sessionController: _services.sessionController);
    if (widget.restoreSessionOnStart) {
      unawaited(_services.sessionController.initialize());
    }
  }

  @override
  void dispose() {
    _router.dispose();
    _services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      services: _services,
      child: MaterialApp.router(
        title: 'FPT Schools',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
