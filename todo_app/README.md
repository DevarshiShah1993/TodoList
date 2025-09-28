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


