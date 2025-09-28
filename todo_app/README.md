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

Environment

No secret keys or .env needed. All endpoints point to:
https://jsonplaceholder.typicode.com
```

## 2) Architecture & Design Decisions

State management: Cubit (flutter_bloc)
Lightweight and explicit. Each user action maps to a Cubit method (load, addTask, toggleTask, deleteTask, setSearch, sync).

Dependency Injection: GetIt
Central place to wire dependencies (API client, repository, Hive box, cubits).
Decision: open Hive boxes before registering them in GetIt so consumers get ready-to-use instances.

Data cache: Hive
Fast key-value store for persisting tasks and pending operations for offline use.

Repository pattern
The UI talks to a repository that hides Dio calls and JSON mapping.

API target: JSONPlaceholder
Chosen as a public mock API. Writes are accepted but not persisted long-term; local cache is the source of truth for UX.

Web-first execution
Because mobile traffic is blocked by Cloudflare in this context, we validate API flows on web. Mobile still runs with offline cache.
