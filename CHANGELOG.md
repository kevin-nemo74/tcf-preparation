# Changelog

All notable changes to this project are documented in this file.

## [1.1.0] - 2026-03-23

### Added
- Theme selection controls in settings (system/light/dark).
- Review queue missing-source recovery actions (keep/remove).
- Firebase Analytics event hooks for onboarding, test start/submit, review completion, and study-plan task toggles.
- Crash reporting hooks with Firebase Crashlytics.
- Localization scaffolding (`l10n.yaml`, English/French ARB files, app delegate wiring).
- Firebase operational config files in repository (`firestore.rules`, `firestore.indexes.json`, `storage.rules`).
- CI Android release compile check.
- New tests for settings theme controls and review-queue missing-source behavior.

### Changed
- App version updated to `1.1.0+2`.

## Release Policy

- Bump `pubspec.yaml` version on every user-visible release.
- Keep changelog entries grouped by Added/Changed/Fixed.
- Do not merge release PRs unless CI analyze, tests, and release compile checks pass.
