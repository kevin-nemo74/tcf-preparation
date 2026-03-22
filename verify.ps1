$ErrorActionPreference = "Stop"

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> flutter analyze"
flutter analyze

Write-Host "==> flutter test"
flutter test

Write-Host ""
Write-Host "Verification completed. Run 'flutter run' on your target device next."
