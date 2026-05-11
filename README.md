# Task Explorer

![Task Explorer Engineering Blueprint](Mobile%20Task%20App%20Engineering%20Blueprint.png)

Task Explorer is a production-quality iOS application demonstrating the implementation of modern architecture, modular design systems, and strategic AI integration. This application is built with a future-proof vision using iOS 26.0+ and rigorous software engineering standards.

## Setup & Requirements

- **Xcode**: Version 26.0+ (required for the latest Swift 6 Concurrency features)
- **Platform**: iOS 26.0+ Simulator or Device
- **Dependencies**: Uses Swift Package Manager (SPM) to manage [DENNetworking](https://github.com/yaffiazmidev/DENNetworking) — a custom URLSession abstraction layer
- **No API Key Required**: Uses the public API from [jsonplaceholder.typicode.com/todos](https://jsonplaceholder.typicode.com/todos)

### Screenshots

| Task List | Task Detail |
|---|---|
| ![Task List](Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%2026.1%20-%202026-05-12%20at%2006.09.33-portrait.png) | ![Task Detail](Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%2026.1%20-%202026-05-12%20at%2006.13.10-portrait.png) |

### Quick Start

1. Clone the repository
2. Open `Task Explorer.xcodeproj` in Xcode 26+
3. Wait for SPM to resolve `DENNetworking` dependency
4. Build & Run

## Development Workflow

This project was developed with an integrated workflow leveraging the AI ecosystem specifically for each development phase, ensuring efficiency without sacrificing manual technical control:

| Phase | Tool | Purpose |
|---|---|---|
| **Design** | Stitch with Google | UI/UX research and Atomic Design-based component hierarchy design |
| **Planning & PRD** | NotebookLM | Dissecting technical requirements from assessment documents and drafting the PRD |
| **Execution** | Claude Code Opus 4.7 | Code implementation, test automation, and code review with subagents |

## Architecture & Engineering Decisions

### MVVM + Clean Architecture & SOLID Principles

The application implements a clear separation of concerns and adheres to SOLID principles:

- **Single Responsibility**: Separate layers for Endpoint, Service, ViewModel, and View
- **Dependency Inversion**: ViewModels depend on abstractions (Protocols), not concrete implementations. Dependency injection is handled via `DIContainer`
- **Open/Closed**: Networking uses the decorator pattern (via DENNetworking) to add features without modifying core code

### Project Structure

```
Task Explorer/
├── App/                          # Entry point, DI, config
│   ├── Config/                   # AppConfiguration
│   └── DI/                       # DIContainer (singleton)
├── Core/
│   ├── Navigation/               # AppRouter, AppRoute, AppDependencies
│   └── Persistence/              # CoreDataStack, TaskLocalStorage
├── Components/                   # Reusable UI (Atomic Design)
│   ├── Atoms/                    # TaskCompletionIndicator, FilterChip, etc.
│   └── Molecules/                # TaskRowCard, SearchBar, EmptyStateView, etc.
├── Features/
│   ├── Home/
│   │   ├── Domain/API/           # HomeEndpoint
│   │   ├── Domain/Service/       # HomeService (protocol + impl)
│   │   ├── Model/                # RemoteHomeItem, HomeItemViewModel
│   │   └── Presentation/         # HomeView, HomeViewModel
│   └── Detail/
│       └── Presentation/View/    # TaskDetailView
└── Task_Explorer.xcdatamodeld    # CoreData model
```

### Layer Responsibilities

| Layer | Responsibility |
|---|---|
| **Endpoint** | Builds `URLRequest` for each API call |
| **Service** | Executes network requests, returns decoded models |
| **ViewModel** | Coordinates Service + LocalStorage, exposes UI state |
| **View** | Renders UI from ViewModel, handles user interaction |
| **LocalStorage** | CoreData CRUD for offline cache + completion persistence |

### Atomic Design System

The UI system is organized modularly to prevent code duplication and improve readability:

| Level | Examples | Purpose |
|---|---|---|
| **Atoms** | `FilterChip`, `TaskStatusBadge`, `TaskCompletionIndicator`, `MetaCard` | Smallest units |
| **Molecules** | `TaskRowCard`, `SearchBar`, `EmptyStateView`, `ErrorStateView` | Composition of atoms |
| **Organisms/Pages** | `HomeView`, `TaskDetailView` | Full functional screens |

### Data Flow

```
API (JSONPlaceholder) → HomeService → HomeViewModel → HomeView
                                ↕
                        TaskLocalStorage (CoreData)
```

- **First load**: Fetch API → merge with local completion overrides → cache to CoreData → display
- **Offline**: API fails → load from CoreData cache → display cached data
- **Toggle completion**: Update in-memory + persist to CoreData immediately
- **Pull-to-refresh**: Re-fetch API → merge local overrides → update cache + display

### Persistence Strategy (CoreData)

The decision to use CoreData (instead of UserDefaults) was made to support:

- **Offline-First**: Data is automatically cached; the app remains functional without internet
- **Structured Data**: Typed entity (`TaskEntity`) with attributes `id`, `userId`, `title`, `completed`
- **Efficient Upsert**: `uniquenessConstraints` on `id` for automatic data merging via merge policy
- **Scalable**: Supports queries and batch operations for 200+ tasks

### Networking: DENNetworking (Custom SPM)

[DENNetworking](https://github.com/yaffiazmidev/DENNetworking) is a custom networking library developed as a reusable Swift Package. It is built on top of URLSession using a decorator pattern — supporting authenticated clients, retry mechanisms, and request logging. It provides an expressive `URLRequest` builder API and a `MockHTTPClient` for testing with a full dependency chain without needing protocol mocking.

## Quality Assurance & Testing

The application includes **29 unit tests** validating all business logic:

```bash
xcodebuild test -scheme "Task Explorer" -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

| Test Suite | Tests | Scope |
|---|---|---|
| `HomeEndpointTests` | 4 | URL path, HTTP method, body, query params |
| `HomeServiceTests` | 4 | Response decoding, empty results, network errors |
| `HomeModelTests` | 4 | JSON decoding, nil handling, ViewModel mapping |
| `HomeViewModelTests` | 17 | Load, cache fallback, toggle, filter, search |

### Testing Approach

- **Full dependency chain**: `MockHTTPClient` → `DENNetworkService` → `HomeService` → `HomeViewModel`
- **MockTaskLocalStorage**: In-memory implementation of `TaskLocalStorageProtocol`
- **No protocol mocking**: Tests use real service implementations with mock HTTP client
- **Persistence**: CoreData integration testing using an in-memory store
- Factory methods: `makeSUT()` / `makeFailingSUT()` for clean test setup

## Trade-offs & Assumptions

- **Read-only API**: Since JSONPlaceholder is read-only, task completion status changes are persisted only locally (CoreData). No PATCH/PUT requests are sent to the server.
- **Priority Merge**: Local task completion status always takes priority over remote API data during refresh. Pull-to-refresh will not overwrite local toggles.
- **No pagination**: JSONPlaceholder returns all 200 todos in a single request. Infinite scroll is not necessary.
- **iOS 26.0 minimum**: Uses `@Observable`, `NavigationStack`, and modern SwiftUI APIs.

## AI Usage Report

In accordance with the AI Collaboration Requirement, here is the report on the use of artificial intelligence tools in this project:

### What AI tools were used?

- **NotebookLM**: Analysis of instruction documents and drafting of PRD.md
- **Stitch with Google**: Visual design exploration and atomic component system mapping
- **Claude Code Opus 4.7** (with subagents): Technical implementation, unit test generation, and code quality audit

### What tasks were assisted by AI?

- Drafting technical documents and test scenarios based on assessment criteria
- Generation of SwiftUI boilerplate and initial CoreData setup
- Code review and identification of potential issues

### What decisions were made manually? (Human-in-the-loop)

- **Architecture & Project Structure**: Folder organization and the choice of MVVM + Clean Architecture patterns were decided entirely manually
- **UI System**: Implementation of the Atomic Design methodology for component modularity
- **Future-Proof Vision**: Setting the target to iOS 26+ and the offline data merging strategy
- **UI/UX Design**: Visual design from HTML mockups was implemented with manual decisions

### Any limitations or corrections applied?

- **CoreData Refinement**: Corrected a crash issue on Xcode 26 by changing the CoreData code generation type from `manual` to `class` (automatic)
- **API Alignment**: Ensured models strictly follow mandatory fields (`id`, `title`, `completed`) even when AI suggested adding non-standard data
