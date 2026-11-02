# Repository Guidelines

## Project Structure & Module Organization

This repository is a Flutter application. Application startup and root widget are in `lib/main.dart`; dependency registration is in `lib/di.dart`. Feature code belongs under `lib/authentication/`, organized into `controller/`, `model/`, and `view/` (with `cubit/` and `pages/`). Widget and unit tests go in `test/`; name test files with the `_test.dart` suffix. Platform-specific projects are in `android/`, `ios/`, `macos/`, and `windows/` where present. Keep generated Dart files alongside their source files and regenerate them instead of editing generated output by hand.

## Build, Test, and Development Commands

- `flutter pub get` resolves packages after dependency changes.
- `flutter run` launches the app on a connected device or selected emulator.
- `flutter analyze` runs the configured Dart and Flutter lints.
- `flutter test` runs the test suite in `test/`.
- `dart run build_runner build` regenerates code for annotated models and generated state helpers. Review generated changes with their source changes.

## Coding Style & Naming Conventions

Use `dart format .` before submitting Dart changes. Follow `analysis_options.yaml` and the included `flutter_lints` rules. Use four-space indentation, `UpperCamelCase` for types, `lowerCamelCase` for members and variables, and `snake_case.dart` filenames (rename existing files when touching them if practical). Keep widgets focused and place feature logic in the corresponding controller or Cubit. Prefer constructor injection for dependencies where practical.

## Testing Guidelines

Tests use `flutter_test`. Name files and test groups after the behavior under test, such as `user_controller_test.dart`. Add or update tests when changing login, response parsing, or state behavior. Run `flutter test` and `flutter analyze` before submitting; there is no stated coverage threshold.

## Commit & Pull Request Guidelines

This workspace has no accessible Git history, so no repository-specific commit convention could be confirmed. Use short imperative commit subjects, for example `Handle login response envelope`. Pull requests should describe behavior changes, list validation commands and results, link related issues when available, and include screenshots for visible UI changes.

## Security & Configuration

Do not commit credentials, tokens, or local machine configuration. Keep authentication secrets out of logs and avoid storing password hashes in client-side user models. Configure environment-specific endpoints outside source code when adding deployment variants.
