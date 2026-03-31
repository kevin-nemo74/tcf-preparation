$ErrorActionPreference = "Stop"

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> flutter gen-l10n"
flutter gen-l10n

Write-Host "==> flutter analyze"
flutter analyze

Write-Host "==> flutter test"
flutter test

Write-Host "==> flutter build apk --release"
flutter build apk --release

Write-Host "==> flutter build web --release"
flutter build web --release

Write-Host "Release checks completed."
