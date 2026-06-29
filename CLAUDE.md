# Agent Guide

This project is a Flutter learning project for an FPT Schools-style mobile app.
The user wants to learn Flutter deeply while still building a real app prototype.

`AGENTS.md` and `CLAUDE.md` intentionally mirror the same project rules so any
agent entering this repo receives the same product, learning, Flutter, Penpot,
verification, and safety context.

## Current Product Direction

- Mobile app: Flutter frontend.
- Backend later: Spring Boot, Java 21, PostgreSQL.
- Admin UI later: React.
- Main domain: school-parent app similar to EnetViet/FPT Schools.
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
- Current architecture is simple MVC:
  - `model/` for immutable state/data models.
  - `controller/` for `ChangeNotifier`, form controllers, validation, and screen logic.
  - `view/` and `view/widgets/` for UI composition.
- Keep controllers free of `BuildContext` where practical.
- Use `AppColors` and existing assets before inventing new styling constants.
- User-facing UI text should be Vietnamese with correct diacritics.
- Route/screen/internal names should be English, for example:
  - `Mobile - Semester Grades`
  - `Mobile - Schedule`
  - `Mobile - Events`
  - `Mobile - Applications`
  - `Mobile - Clubs`
- `ListDiemHK` means "List Điểm Học Kỳ"; use `Semester Grades` for English screen/route names and `Điểm học kỳ` as the Vietnamese UI label.

## Current Learning Curriculum

The current Flutter app is the FPT Schools login flow, built with simple MVC.

- Problem:
  - One login entry point for school users.
  - Phone-number login is required.
  - No public register screen unless requirements change.
- Model:
  - `UserRole` enum.
  - `LoginModel` as immutable state with `copyWith`.
- Controller:
  - `LoginController` extends `ChangeNotifier`.
  - Owns form state, text controllers, validation, and submit result.
  - Avoids `BuildContext` for testability.
- View:
  - `LoginPage` creates/disposes the controller.
  - Widgets under `view/widgets/` compose the UI.
  - Use targeted rebuilds instead of rebuilding the whole tree when practical.
- Flutter details to teach carefully:
  - `StatefulWidget`, `initState`, `dispose`.
  - `ListenableBuilder`.
  - `Form`, `TextFormField`, and validators.
  - `SingleChildScrollView`, `ConstrainedBox`, `SafeArea`.
  - Responsive constraints with `LayoutBuilder`, `MediaQuery`, and max widths.

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
