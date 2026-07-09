# MyFSchoolSE1913 Conventions

## Communication And Learning

- Talk to the user in Vietnamese unless they ask otherwise.
- Default to Learning Mode. Switch to implementation-first only when the user
  says `code mode`, `just build it`, or `tắt learning`.
- Teach from real files: file -> class -> function -> syntax.
- The user already knows Java, React, and general architecture. Spend more time
  on Dart/Flutter syntax, widget lifecycle, state, constraints, and navigation.

## Flutter

- Main package path: `lib/vn/edu/fpt/`.
- Follow the existing layered MVVM structure:
  - `app/` for app bootstrap, routing, config, dependency composition;
  - `core/` for shared theme, network, result/failure types;
  - `domain/` for clean app models;
  - `data/` for DTOs, API services, repositories, token storage;
  - `ui/core/` for shared widgets;
  - `ui/features/<feature>/view_models/` for `ChangeNotifier` view models and
    immutable UI state;
  - `ui/features/<feature>/views/` and `widgets/` for UI composition.
- Views render state, forward actions, and keep only local UI work.
- ViewModels own form controllers, validation, loading/error state, and
  commands.
- Repositories are the boundary between UI/domain code and external data.
- Services are thin wrappers around HTTP or platform plugins.
- Keep ViewModels free of `BuildContext` where practical.
- Use `go_router` and named route constants in `app_router.dart`.
- Use `flutter_secure_storage` through `TokenStorage`; do not access tokens
  directly in widgets.
- Use existing theme/color/assets before adding new styling constants.
- User-facing UI text is Vietnamese with correct diacritics.
- Route, file, and internal names are English.

## Dart Style

- Use Effective Dart and `flutter_lints`.
- Format with `dart format` / `flutter format`.
- Prefer trailing commas for multiline widget trees and argument lists.
- Use `UpperCamelCase` for classes/enums/extensions/typedefs/type parameters.
- Use `lowerCamelCase` for variables, methods, parameters, fields, getters.
- Use `lowercase_with_underscores` for Dart files and directories.
- Prefer `const` constructors/widgets and `final` values.
- Keep `build()` pure and fast.
- Dispose owned resources such as controllers, focus nodes, animation
  controllers, scroll controllers, HTTP clients, and routers.
- After `await`, check `context.mounted` before using `BuildContext`; in a
  `State`, check `mounted` before calling `setState`.

## Backend

- Backend is a Spring Boot modular monolith.
- Keep root Java packages split by business module/domain first, not by global
  technical layer.
- Do not create root-level `controller/`, `service/`, `repository/`, or
  `entity/` packages.
- Keep small modules flat until file count or responsibilities make navigation
  harder.
- When a module grows, prefer internal `web/`, `application/`, `domain/`, and
  `persistence/` packages.
- In this project, JPA entities can serve as domain entities. Do not introduce
  separate persistence entities/mappers unless the mapping removes real
  complexity.
- Start read queries with Spring Data JPA. Use fetch joins, `@EntityGraph`, or
  DTO projections before reaching for JDBC-style reads.
- Keep JPA mappings and Flyway migrations in lockstep.
- Use Spring Modulith boundaries deliberately; add module metadata only when
  boundaries need enforcement or decoupling.

## Documentation

- Keep `AGENTS.md` and `CLAUDE.md` synchronized and thin.
- Current facts live in `ARCHITECTURE.md` and specs.
- Intent/future scope lives in `docs/vision.md` and `docs/roadmap.md`.
- Rationale lives in `docs/decisions/`.
- Update affected specs/tests when durable behavior changes.

## Safety

- Do not delete Gradle caches broadly.
- Do not run destructive git commands unless explicitly requested.
- Do not overwrite user changes without checking the diff.
- Do not add dependencies just because they are popular.
