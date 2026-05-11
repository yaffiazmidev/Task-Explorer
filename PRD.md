# PRD: Task Explorer

## Overview

**App Name**: Task Explorer
**Platform**: iOS 26.0+
**Framework**: SwiftUI
**Architecture**: MVVM + Clean Architecture

Task Explorer is a task management app that fetches todos from a remote API, displays them in a browsable list, shows task details, and allows users to toggle completion status with local persistence.

## User Stories

### US-1: View Task List
**As a** user,
**I want to** see a list of all tasks,
**So that** I can browse and manage my todos.

**Acceptance Criteria:**
- Display all tasks fetched from `GET https://jsonplaceholder.typicode.com/todos`
- Each row shows: task title, completion status indicator, task ID
- Completed tasks show strikethrough title with reduced opacity
- Pending tasks show empty circle, completed tasks show green checkmark
- List loads with shimmer skeleton animation during fetch
- Error state shown with retry button if fetch fails
- Pull-to-refresh to reload from API

### US-2: View Task Detail
**As a** user,
**I want to** tap a task to see its details,
**So that** I can view more information about a specific task.

**Acceptance Criteria:**
- Navigate to detail screen on row tap
- Show: status badge (Pending/Completed), task title (large), Task ID, User ID
- Custom back button to return to list
- Centered "Task #N" in navigation bar

### US-3: Toggle Completion Status
**As a** user,
**I want to** mark tasks as completed or pending,
**So that** I can track my progress.

**Acceptance Criteria:**
- Tap radio button in list row to toggle completion instantly
- Detail screen has "Mark as Complete" / "Mark as Pending" button
- Toggle persists to CoreData (survives app restart)
- Toggle reflects immediately in both list and detail views
- Pull-to-refresh preserves local completion overrides

### US-4: Search Tasks
**As a** user,
**I want to** search tasks by title,
**So that** I can quickly find a specific task.

**Acceptance Criteria:**
- Search bar at top of list (sticky, doesn't scroll)
- Real-time filtering as user types
- Case-insensitive matching
- Shows empty state when no results match

### US-5: Filter Tasks
**As a** user,
**I want to** filter tasks by status,
**So that** I can focus on pending or completed tasks.

**Acceptance Criteria:**
- Three filter chips: All, Completed, Pending
- Chips are sticky below search bar
- Active chip has dark background, inactive has light
- Filter combines with search (both applied simultaneously)

### US-6: Offline Support
**As a** user,
**I want to** view my tasks even without internet,
**So that** I can still access my task list offline.

**Acceptance Criteria:**
- Task list cached to CoreData after successful fetch
- If API fails, display cached data from CoreData
- No error shown when cached data is available
- Error state only shown when no cache AND no network

## Screens

### Screen 1: Home (Task List)
```
+----------------------------------+
| Task Explorer          (large)   |
+----------------------------------+
| [Search tasks...]                |
| [All] [Completed] [Pending]     |
+----------------------------------+
| O  Task title here              |
|    [Pending] . ID: #1           |
+----------------------------------+
| V  Another task (strikethrough)  |
|    [Completed] . ID: #2         |
+----------------------------------+
```

**Components used:**
- `SearchBar` (Molecule)
- `FilterChip` (Atom)
- `TaskRowCard` (Molecule) — contains `TaskCompletionIndicator` (Atom) + `TaskStatusBadge` (Atom)
- `TaskRowSkeletonList` (Molecule) — loading state
- `EmptyStateView` (Molecule) — no results
- `ErrorStateView` (Molecule) — network error + retry

### Screen 2: Task Detail
```
+----------------------------------+
| < Back       Task #1             |
+----------------------------------+
| [PENDING]                        |
|                                  |
| Delectus Aut Autem               |
| (large bold title)               |
|                                  |
| +----------+ +----------+       |
| | Task ID  | | User ID  |       |
| | #1       | | #1       |       |
| +----------+ +----------+       |
|                                  |
+----------------------------------+
| [Mark as Complete]               |
+----------------------------------+
```

**Components used:**
- `TaskStatusBadge` (Atom, prominent style)
- `MetaCard` (Atom)

## Data Model

### API Response
```
GET https://jsonplaceholder.typicode.com/todos

[
  {
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
  }
]
```

### Models

| Model | Fields | Purpose |
|---|---|---|
| `RemoteHomeItem` | id, userId, title, completed (all optional) | API response / CoreData interchange |
| `HomeItemViewModel` | id, userId, title, completed (non-optional) | View display model |
| `TaskEntity` (CoreData) | id (Int64), userId (Int64), title (String?), completed (Bool) | Local persistence |

## Architecture

```
App Layer
  Task ExplorerApp → creates HomeViewModel (single instance)
  DIContainer → provides NetworkService + TaskLocalStorage
  AppDependencies → factory for ViewModels

Core Layer
  Navigation: AppRouter + AppRoute (enum-based routing)
  Persistence: CoreDataStack + TaskLocalStorage

Feature Layer
  Home: HomeEndpoint → HomeService → HomeViewModel → HomeView
  Detail: TaskDetailView (uses shared HomeViewModel)

Component Layer (Atomic Design)
  Atoms: TaskCompletionIndicator, TaskStatusBadge, FilterChip, MetaCard, ShimmerModifier
  Molecules: TaskRowCard, SearchBar, EmptyStateView, ErrorStateView, TaskRowSkeleton
```

### Data Flow
```
Remote API ──fetch──> HomeService ──decode──> HomeViewModel ──merge──> allItems
                                                  |                      |
CoreData <──save──── TaskLocalStorage <──────────-+                      |
CoreData ──fetch──-> TaskLocalStorage ──fallback──> allItems (offline)   |
                                                                         v
                                                              items (filtered + searched)
                                                                         |
                                                              HomeView / TaskDetailView
```

## Technical Specifications

| Spec | Choice |
|---|---|
| Language | Swift 5 (Swift 6 concurrency features enabled) |
| UI Framework | SwiftUI with @Observable |
| Min iOS | 26.0 |
| Architecture | MVVM + Clean Architecture |
| Networking | DENNetworking (custom SPM, URLSession wrapper) |
| Persistence | CoreData (.xcdatamodeld, auto-generated codegen) |
| DI | Manual via DIContainer singleton + AppDependencies factory |
| Navigation | NavigationStack + enum-based AppRoute |
| Testing | XCTest, MockHTTPClient, MockTaskLocalStorage |

## Test Plan

| Test Suite | Scope | Cases |
|---|---|---|
| `HomeEndpointTests` | URL building | path, method, body, query |
| `HomeServiceTests` | Network decode | success, empty, server error, no connection |
| `HomeModelTests` | JSON decode + mapping | decode, empty, nil defaults, asViewModels |
| `HomeViewModelTests` | Business logic | load, cache fallback, skip reload, toggle, double-toggle, persist toggle, filter all/completed/pending, search match/empty/no-match, isCompleted |

**Total: 29 tests**

## Non-Functional Requirements

| Requirement | Implementation |
|---|---|
| Loading UX | Shimmer skeleton cards (not spinner) |
| Error UX | Error message + retry button |
| Empty UX | Icon + message + suggestion |
| Offline | CoreData cache, transparent fallback |
| Performance | LazyVStack for list, guard skip on reload |
| Persistence | CoreData with uniqueness constraint + merge policy |
