# LEARNING.md — Project walkthrough (file by file)

> Mode: walk the real code, explain Dart/Flutter syntax in context, compare to Java/React.
> Tick a file once its classes/functions + the syntax in them are understood.
> `[ ]` not yet · `[~]` in progress · `[x]` done

## Walkthrough order (entry → leaves)
- [x] `lib/main.dart` — entry point, `runApp`, `MaterialApp`, theme
- [x] `lib/vn/edu/fpt/app_colors.dart` — `abstract final class`, `const Color`, ARGB hex
- [x] `lib/vn/edu/fpt/model/user_role.dart` — `enum` + `extension` + switch-expr
- [x] `lib/vn/edu/fpt/model/login_model.dart` — immutable data, `copyWith`
- [x] `lib/vn/edu/fpt/controller/login_controller.dart` — `ChangeNotifier`, state, methods
- [~] `lib/vn/edu/fpt/view/login_page.dart` — `StatefulWidget`, `initState`, `dispose`, `ListenableBuilder`
- [ ] `lib/vn/edu/fpt/view/widgets/login_header.dart` — `CustomClipper`, `Stack`, gradient
- [ ] `lib/vn/edu/fpt/view/widgets/role_selector.dart` — collection-`for`, `AnimatedContainer`
- [ ] `lib/vn/edu/fpt/view/widgets/login_form.dart` — `Form`, `TextFormField`, validators

## Syntax mastered (running list)
- [x] `const` constructor, named params `{}`, `required`, `this.x`, `super.key`
- [x] `final` / `const` / `var`
- [x] arrow `=>`, getters, switch-expression, `enum` + `extension`
- [~] null safety: `?`, `?.`, `??`, `!`, `late`

---
_Current position: lib/main.dart_
