# Todo App (Flutter • Cubit • GetIt • Hive)

A simple task list app that talks to the JSONPlaceholder API.  
It uses **Cubit** for state management, **GetIt** for dependency injection, and **Hive** for local caching and offline support.

---

## 1) Setup

### Prerequisites
- Flutter SDK installed (stable channel)
- Dart included with Flutter
- A device/emulator or a web browser

> **Note:** JSONPlaceholder calls from Android/iOS are blocked by Cloudflare in this environment.  
> Please run on **web** for API testing.

### Install & Run
```bash
# 1) Get packages
flutter pub get

# 2) Generate/ensure Hive adapters if codegen is used
# dart run build_runner build --delete-conflicting-outputs

# 3) Run on web (recommended due to Cloudflare 403 on devices)
flutter run -d chrome

# (Optional) Run on device/emulator; network calls will be blocked by Cloudflare here
flutter run -d android
flutter run -d ios
```
### Environment

No secret keys or .env needed. All endpoints point to:
https://jsonplaceholder.typicode.com


## 2) Architecture & Design Decisions

### State management: Cubit (flutter_bloc)
Lightweight and explicit. Each user action maps to a Cubit method (load, addTask, toggleTask, deleteTask, setSearch, sync).

### Dependency Injection: GetIt
Central place to wire dependencies (API client, repository, Hive box, cubits).
Decision: open Hive boxes before registering them in GetIt so consumers get ready-to-use instances.

### Data cache: Hive
Fast key-value store for persisting tasks and pending operations for offline use.

### Repository pattern
The UI talks to a repository that hides Dio calls and JSON mapping.

### API target: JSONPlaceholder
Chosen as a public mock API. Writes are accepted but not persisted long-term; local cache is the source of truth for UX.

### Web-first execution
Because mobile traffic is blocked by Cloudflare in this context, we validate API flows on web. Mobile still runs with offline cache.

## 3) BLoC/Cubit Implementation (Brief)

State (TaskState)

status: initial | loading | success | failure

todos: current list (cached + live)

pending: queued local changes (add/toggle/delete) for later sync

isOnline: connectivity flag

searchQuery: current filter text

message: one-off UI message/snackbar

Cubit (TaskCubit) – main methods

load({forceRefresh}): fetch from API when online; otherwise load from Hive.

addTask(title): optimistic insert → save to Hive → enqueue add.

toggleTask(key): optimistic toggle → save → enqueue toggle.

deleteTask(key): optimistic delete → save → enqueue delete.

setSearch(query): update filter text; UI rebuilds with filtered list.

onConnectivityChanged(isOnline): update flag; if back online → sync().

sync(): drains the pending queue against the API; updates Hive and state.

### UI

BlocBuilder/BlocListener rebuilds views and shows snackbars.

Pull-to-refresh triggers load(forceRefresh: true).

Add via FAB dialog; toggle via checkbox; delete via dismiss.

## 4) Offline Strategy

Cache first
On startup and while offline, read tasks from Hive immediately.

Optimistic updates
Add/Toggle/Delete update the UI and Hive right away. The change is also queued in pending.

Sync when online
When connectivity returns or on explicit refresh, sync() sends queued operations to the API in order.
If an operation fails, it stays in the queue for a later retry.

## 5) Assumptions

JSONPlaceholder may not persist mutations. The app treats Hive as the primary data source for a stable UX.

Network calls from Android/iOS are blocked by Cloudflare in this environment, so web is the reference target for API flows.

A single user context is assumed (no multi-user isolation).

Search is client-side and case-insensitive on the task title.

## 6) Challenges & How They Were Solved

### 403 (Cloudflare) on device

What happened: API calls from Android/iOS were blocked.

What we did: Ran and verified API flows on web (flutter run -d chrome).

If needed later: Use a small proxy/relay or a different test API; or keep an offline-first mode for device testing.

### Filter → Edit → List resets

What happened: After editing a task while a filter was active, the list reverted to the full set.

Fix: Keep searchQuery in TaskState, never reset it on edit; always derive the visible list from todos filtered by the current searchQuery.
