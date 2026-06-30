# LEARNING.md — Project walkthrough (file by file)

> Mode: walk the real code, explain Dart/Flutter syntax in context, compare to Java/React.
> Tick a file once its classes/functions + the syntax in them are understood.
> `[ ]` not yet · `[~]` in progress · `[x]` done

## Walkthrough order (entry → leaves)
- [x] `lib/main.dart` — entry point and `runApp`
- [ ] `lib/vn/edu/fpt/app/my_fschool_app.dart` — app root, service lifetime, `MaterialApp.router`
- [ ] `lib/vn/edu/fpt/app/app_router.dart` — `go_router`, route constants, screen wiring
- [ ] `lib/vn/edu/fpt/app/app_dependencies.dart` — simple dependency injection with `InheritedWidget`
- [ ] `lib/vn/edu/fpt/core/theme/app_theme.dart` — global theme, input and button styling
- [x] `lib/vn/edu/fpt/core/theme/app_colors.dart` — `abstract final class`, `const Color`, ARGB hex
- [ ] `lib/vn/edu/fpt/core/result/result.dart` — sealed classes, success/failure pattern
- [ ] `lib/vn/edu/fpt/domain/models/user_role.dart` — `enum` + `extension` + switch-expression
- [ ] `lib/vn/edu/fpt/domain/models/app_user.dart` — immutable domain model
- [ ] `lib/vn/edu/fpt/domain/models/auth_session.dart` — auth session domain model
- [ ] `lib/vn/edu/fpt/data/models/*.dart` — DTO parsing and DTO-to-domain mapping
- [ ] `lib/vn/edu/fpt/data/services/auth_api_service.dart` — HTTP service boundary
- [ ] `lib/vn/edu/fpt/data/services/token_storage.dart` — secure token storage wrapper
- [ ] `lib/vn/edu/fpt/data/repositories/auth_repository.dart` — repository as single source of truth
- [ ] `lib/vn/edu/fpt/ui/features/auth/view_models/login_view_model.dart` — `ChangeNotifier`, state, submit command
- [~] `lib/vn/edu/fpt/ui/features/auth/views/login_page.dart` — `StatefulWidget`, `initState`, `dispose`, `ListenableBuilder`
- [ ] `lib/vn/edu/fpt/ui/features/auth/widgets/login_form.dart` — `Form`, `TextFormField`, validators
- [ ] `lib/vn/edu/fpt/ui/features/auth/views/forgot_password_page.dart` — route navigation and form validation
- [ ] `lib/vn/edu/fpt/ui/features/home/views/home_page.dart` — first authenticated screen shell

## Syntax mastered (running list)
- [x] `const` constructor, named params `{}`, `required`, `this.x`, `super.key`
- [x] `final` / `const` / `var`
- [x] arrow `=>`, getters, switch-expression, `enum` + `extension`
- [~] null safety: `?`, `?.`, `??`, `!`, `late`
- [ ] records: `(icon, label)` and `$1` / `$2`
- [ ] sealed classes and pattern matching: `Success()` / `Failure()`
- [ ] async/await with repository calls
- [ ] `InheritedWidget` dependency lookup

---
_Current position: lib/vn/edu/fpt/app/my_fschool_app.dart_
