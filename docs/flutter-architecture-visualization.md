# Flutter Architecture Visualization

This note explains the current Flutter structure in this project with diagrams.
User-facing app text stays Vietnamese, but screen and file names stay English.

## 1. Runtime Flow

```mermaid
flowchart LR
    User[Parent user] --> View[LoginPage / Flutter View]
    View --> VM[LoginViewModel]
    VM --> Repo[AuthRepository]
    Repo --> Service[AuthApiService]
    Service --> Client[ApiClient]
    Client --> Backend[Spring Boot API]
    Backend --> Client
    Client --> Service
    Service --> DTO[AuthSessionDto]
    DTO --> Domain[AuthSession]
    Domain --> Repo
    Repo --> Storage[TokenStorage]
    Repo --> VM
    VM --> View

    classDef ui fill:#e0f2fe,stroke:#0369a1,color:#0f172a;
    classDef logic fill:#dcfce7,stroke:#15803d,color:#0f172a;
    classDef data fill:#fef3c7,stroke:#b45309,color:#0f172a;
    classDef external fill:#fee2e2,stroke:#b91c1c,color:#0f172a;

    class View,VM ui;
    class Repo,Domain logic;
    class Service,Client,DTO,Storage data;
    class Backend external;
```

Read it like this:

- `View` renders widgets and forwards user actions.
- `ViewModel` owns screen state, validation, and commands.
- `Repository` is the app-facing data boundary.
- `Service` talks to one external thing: HTTP, storage, platform API.
- `DTO` is backend-shaped data.
- `Domain` is app-shaped data.

## 2. Project Structure

```mermaid
flowchart TB
    Root[lib/vn/edu/fpt] --> App[app]
    Root --> Core[core]
    Root --> Domain[domain]
    Root --> Data[data]
    Root --> UI[ui]

    App --> Router[app_router.dart]
    App --> Deps[app_dependencies.dart]
    App --> Bootstrap[my_fschool_app.dart]

    Core --> Theme[theme]
    Core --> Network[network]
    Core --> Result[result]

    Domain --> DomainModels[models]

    Data --> DTOs[models / DTO]
    Data --> Services[services]
    Data --> Repositories[repositories]

    UI --> UICore[core widgets]
    UI --> Features[features]
    Features --> Auth[auth]
    Features --> Home[home]

    Auth --> Views[views]
    Auth --> VMs[view_models]
    Auth --> Widgets[widgets]
```

## 3. Java / React / Flutter Mapping

| Concept | Java / Spring thinking | React thinking | Flutter thinking |
|---|---|---|---|
| App entry | `main()` / Spring Boot app | `main.jsx`, `App` | `main.dart`, `runApp()` |
| Dependency setup | Spring beans / configuration | providers, context, hooks | `AppDependencies`, constructor injection |
| Route setup | controller mappings | React Router | `go_router` |
| Screen | controller + template idea, loosely | page component | `View` / `Page` widget |
| Screen state | service state / DTO state | `useState`, Zustand, React Query | `ChangeNotifier` ViewModel |
| API boundary | service/client bean | API client module | `ApiService` + `ApiClient` |
| Data boundary | service/repository | query function / repository module | `Repository` |
| JSON model | request/response DTO | API response type | DTO class |
| Business model | domain/entity model | app type/model | domain model |
| UI rebuild | not a direct Java concept | component rerender | widget rebuild |
| Cleanup | `close()`, lifecycle callbacks | `useEffect` cleanup | `dispose()` |

## 4. Mental Model

```mermaid
mindmap
  root((Flutter to learn))
    Dart language
      null safety
      async await
      sealed class
      pattern matching
      records
    Widget system
      StatelessWidget
      StatefulWidget
      build method
      widget tree
      rebuild
    Layout
      constraints
      Row Column Stack
      Expanded Flexible
      LayoutBuilder
      SafeArea
      ScrollView
    State
      ChangeNotifier
      immutable state
      TextEditingController
      Form validation
      dispose
    Navigation
      go_router
      named routes
      auth redirect
    Data
      DTO
      Repository
      Service
      TokenStorage
      Result Failure
    Production
      testing
      logging
      error handling
      flavors
      secure storage
      CI
```

## 5. Feature Build Sequence

Use this sequence for every new feature such as Schedule, Semester Grades, Events, Applications, or Clubs.

```mermaid
flowchart LR
    A[1. Domain model] --> B[2. DTO]
    B --> C[3. ApiService]
    C --> D[4. Repository]
    D --> E[5. ViewModel state]
    E --> F[6. View widgets]
    F --> G[7. Route]
    G --> H[8. Tests]
```

Example for `Schedule`:

```text
domain/models/schedule_item.dart
data/models/schedule_item_dto.dart
data/services/schedule_api_service.dart
data/repositories/schedule_repository.dart
ui/features/schedule/view_models/schedule_view_model.dart
ui/features/schedule/views/schedule_page.dart
ui/features/schedule/widgets/schedule_list_tile.dart
app/app_router.dart
```

## 6. Why This Is Not Just Folder Decoration

Bad beginner flow:

```mermaid
flowchart LR
    Page[login_page.dart] --> HTTP[HTTP call]
    Page --> Validation[validation]
    Page --> Token[token save]
    Page --> Navigation[navigation]
    Page --> UI[UI rendering]
```

Production-oriented flow:

```mermaid
flowchart LR
    Page[LoginPage] --> VM[LoginViewModel]
    VM --> Repo[AuthRepository]
    Repo --> API[AuthApiService]
    Repo --> Token[TokenStorage]
    API --> Backend[Backend]
```

The second flow is easier to test, easier to replace, and easier to debug.

## 7. What To Learn Next In This Project

Recommended order:

1. `main.dart` and `runApp`.
2. `MyFSchoolApp` and `MaterialApp.router`.
3. `go_router` in `app_router.dart`.
4. `AppDependencies` as simple dependency injection.
5. `LoginPage`: `StatefulWidget`, `initState`, `dispose`.
6. `LoginViewModel`: `ChangeNotifier`, immutable state, validators.
7. `LoginForm`: `Form`, `TextFormField`, controllers.
8. `AuthRepository`: DTO to domain mapping and token storage.
9. `ApiClient`: async HTTP and error handling.
10. Tests for ViewModel and Repository.

