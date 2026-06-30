# Agent Guide

This project is a Flutter learning project for an FPT Schools-style student
mobile app.
The user wants to learn Flutter deeply while still building a real app prototype.

`AGENTS.md` and `CLAUDE.md` intentionally mirror the same project rules so any
agent entering this repo receives the same product, learning, Flutter, Penpot,
verification, and safety context.

## Current Product Direction

- Mobile app: Flutter frontend.
- Backend: Spring Boot modular monolith, PostgreSQL, JWT auth.
- Admin UI later: React.
- Main domain: student-facing school app similar to FPT Schools and the student
  side of EnetViet.
- Primary mobile role: `STUDENT`.
- Teacher and admin experiences should be treated as web/admin UI scope unless
  the user explicitly asks for mobile teacher/admin flows.
- Parent experience is a separate optional scope. Do not mix parent-specific
  copy or child-management flows into the student mobile screens.
- Login uses phone number. Do not add a public register screen unless the user explicitly changes the requirement.

## Working Style

- Read the existing files before changing code.
- Keep explanations in Vietnamese when talking to the user, unless they ask otherwise.
- When editing UI, preserve the user's learning goal: explain the Flutter/Dart syntax and compare with Java/React when useful.
- If the user says "code mode", "just build it", or "tắt learning", prioritize implementation over teaching.
- Preserve the current project structure unless there is a concrete reason to change it.
- For non-trivial explanations, teach from this project's real files: file -> class -> function.
- The user already knows Java, React, and general architecture. Spend more time on Dart/Flutter syntax, widget lifecycle, state, constraints, and navigation.

## Learning Mode

Default behavior is Learning Mode unless the user explicitly asks for pure implementation.

- Start by checking what the user already understands.
- Teach incrementally; do not dump a full lecture at once.
- Explain both the high-level reason and the low-level mechanics.
- Compare Dart/Flutter syntax to Java/JavaScript/React where useful.
- Prefer evidence from real files, Flutter DevTools, hot reload, logs, or tests.
- Keep `LEARNING.md` honest. Mark items complete only after the user demonstrates understanding.
- Support these depth dials:
  - `eli5`: very simple analogy.
  - `eli14`: gentle explanation with some real terms.
  - `elii`: intern-level engineering explanation with tradeoffs.

## Flutter Conventions

- Main package path: `lib/vn/edu/fpt/`.
- Current architecture follows Flutter's layered MVVM guidance:
  - `app/` for app bootstrap, routing, config, and dependency composition.
  - `core/` for shared theme, network helpers, result/failure types, and common utilities.
  - `domain/` for clean app models used by UI and business logic.
  - `data/` for DTOs, API services, repositories, and token storage.
  - `ui/core/` for shared widgets.
  - `ui/features/<feature>/view_models/` for `ChangeNotifier` view models and immutable UI state.
  - `ui/features/<feature>/views/` and `widgets/` for UI composition.
- Views should stay mostly dumb: render state, forward user actions, and do local UI-only work.
- ViewModels own form controllers, validation, loading/error state, and commands.
- Repositories are the boundary between UI/domain code and external data sources.
- Services are thin wrappers around HTTP or platform plugins.
- Keep ViewModels free of `BuildContext` where practical.
- Use `go_router` for screen navigation and named route constants in `app_router.dart`.
- Use `flutter_secure_storage` through `TokenStorage`; do not read/write tokens directly in widgets.
- Use `AppColors` and existing assets before inventing new styling constants.
- User-facing UI text should be Vietnamese with correct diacritics.
- Route/screen/internal names should be English, for example:
  - `Mobile - Semester Grades`
  - `Mobile - Schedule`
  - `Mobile - Events`
  - `Mobile - Applications`
  - `Mobile - Clubs`
- `ListDiemHK` means "List Điểm Học Kỳ"; use `Semester Grades` for English screen/route names and `Điểm học kỳ` as the Vietnamese UI label.

## Dart and Flutter Style Rules

- Use Effective Dart and `flutter_lints` as the baseline. Keep
  `analysis_options.yaml` on `package:flutter_lints/flutter.yaml`; do not
  disable lints without a concrete project reason.
- Format Dart with `dart format` / `flutter format`. Prefer trailing commas for
  multiline widget trees and argument lists so formatter output stays readable.
- Naming:
  - `UpperCamelCase` for classes, enums, extensions, typedefs, and type
    parameters.
  - `lowerCamelCase` for variables, methods, parameters, fields, getters, and
    named constructors.
  - `lowercase_with_underscores` for Dart files and directories.
  - Avoid unclear abbreviations. Treat long acronyms like normal words, for
    example `ApiClient`, not `APIClient`.
- Regular class member order in this project:
  - unnamed constructor first, then named/factory constructors;
  - fields initialized by the constructors;
  - getters;
  - public methods;
  - private helpers.
- Widget class order in this project:
  - constructor;
  - final fields;
  - `createState()` or `build()`;
  - private widget helpers only when they improve readability.
- `State` class order in this project:
  - owned fields/controllers;
  - lifecycle methods such as `initState`, `didChangeDependencies`,
    `didUpdateWidget`, and `dispose`;
  - `build`;
  - event handlers and private helpers.
- Prefer `const` constructors/widgets when inputs are compile-time constants.
  Prefer `final` for values that are assigned once. Use `late final` only when
  lifecycle initialization is required, such as creating services in
  `initState`.
- Keep `build()` pure and fast: no HTTP calls, no token storage access, no
  controller creation, and no navigation side effects inside `build()`.
- Dispose every resource the object owns, including `TextEditingController`,
  `FocusNode`, `AnimationController`, `ScrollController`, `http.Client`, and
  owned routers.
- After `await`, check `context.mounted` before using `BuildContext` for
  navigation, snackbars, or dialogs. In a `State` object, check `mounted` before
  calling `setState`.
- Extract widgets when a `build()` method becomes hard to scan, but avoid
  over-abstracting one-off layout. Reusable UI belongs under `ui/core/` or the
  feature's `widgets/` folder.
- Reference docs:
  - Dart Effective Dart: https://dart.dev/effective-dart
  - Dart lints: https://dart.dev/tools/linter-rules
  - Flutter performance best practices:
    https://docs.flutter.dev/perf/best-practices
  - Flutter `State` lifecycle:
    https://api.flutter.dev/flutter/widgets/State-class.html

## Current Learning Curriculum

The current Flutter app is the FPT Schools login flow, built with layered MVVM.

- Problem:
  - One login entry point for school users.
  - Phone-number login is required.
  - The current mobile experience is scoped to students.
  - No public register screen unless requirements change.
- App:
  - `main.dart` calls `runApp`.
  - `MyFSchoolApp` owns app services and `GoRouter`.
  - `AppDependencies` exposes services with an `InheritedWidget`.
- Domain:
  - `AppUser`, `AuthSession`, `UserRole` are clean models independent from JSON.
- Data:
  - `AuthApiService` calls backend auth endpoints.
  - `AuthRepository` converts DTOs to domain models and stores tokens.
  - `TokenStorage` wraps secure storage.
- ViewModel:
  - `LoginViewModel` extends `ChangeNotifier`.
  - Owns form state, text controllers, validation, submit command, loading, and errors.
  - Avoids `BuildContext` for testability.
- View:
  - `LoginPage` creates/disposes the view model.
  - Widgets under `ui/features/auth/widgets/` compose the UI.
  - Use targeted rebuilds instead of rebuilding the whole tree when practical.
- Flutter details to teach carefully:
  - `StatefulWidget`, `initState`, `dispose`.
  - `ListenableBuilder`.
  - `Form`, `TextFormField`, and validators.
  - `SingleChildScrollView`, `ConstrainedBox`, `SafeArea`.
  - Responsive constraints with `LayoutBuilder`, `MediaQuery`, and max widths.
  - Dart sealed classes and pattern matching in `Result`.
  - DTO-to-domain mapping.
  - `InheritedWidget` as dependency injection before adding heavier DI packages.

## Penpot Design Rules

- Use Penpot for layout, design system, and prototype flow before implementing complex screens in Flutter.
- Keep component sources on the design-system page, not mixed into app screens.
- If a component is missing, create the component first in the design system, then use instances on app screens.
- Do not duplicate raw shapes for repeated UI such as app bars, bottom navigation, list rows, chips, buttons, or feature cards.
- Board/screen names should be English. Text visible to users should be Vietnamese.
- Use existing icon components or Material icon mappings before creating text-only placeholders.
- Do not draw fake prototype wires manually. Use native Penpot interactions and test them in Present mode.
- For auth flow:
  - `Đăng nhập` goes to Home.
  - `Quên mật khẩu` goes to Forgot Password.
  - Back actions return to Login.
- For student mobile scope:
  - Home greeting should refer to `Học sinh`, not `Phụ huynh`.
  - Keep student self-service features first: semester grades, schedule,
    events, applications, clubs, messages, and account.
  - Avoid parent-only flows such as selecting a child, parent approvals, tuition
    payment, or parent-teacher communication unless parent scope is explicitly
    added.
- For the sketch from class, map these feature boxes as:
  - `ListDiemHK` -> `Mobile - Semester Grades` / UI label `Điểm học kỳ`.
  - `LichHoc` -> `Mobile - Schedule` / UI label `Lịch học`.
  - `SuKien` -> `Mobile - Events` / UI label `Sự kiện`.
  - `DonTu` -> `Mobile - Applications` / UI label `Đơn từ`.
  - `CLB` -> `Mobile - Clubs` / UI label `CLB`.

## Verification

- Prefer targeted checks over broad cleanup.
- Run `flutter analyze` after code changes when practical.
- Run `flutter test` after behavior changes when practical.
- If no emulator/device is connected, Flutter web/Chrome is an acceptable local verification target.
- For Android/Gradle work on this machine, use JDK 21. Do not assume JDK 25 is compatible with the project's Gradle setup.

## Safety Rules

- Do not delete Gradle caches broadly.
- Do not run destructive git commands such as `git reset --hard` or `git checkout --` unless explicitly requested.
- Do not overwrite user changes without checking the diff first.
- Do not add dependencies just because they are popular. Add them only when they solve a real need in this project.

## Session Bootstrapping

- Read this guide first.
- Read `LEARNING.md` to see what has already been learned.
- Resume from the first unchecked learning item when the user is in Learning Mode.
- Start teaching by asking the user to restate their current understanding, then fill gaps.

## Useful Local Context

- `AGENTS.md` and `CLAUDE.md` should stay synchronized.
- `LEARNING.md` tracks what the user has already learned.
- `.codex/config.toml` contains project-local Penpot MCP configuration.
- `assets/images/fpt_schools_logo.png` is the current logo asset.
