# KartapPay

Offline-first payroll app for small contractors, pakyaw crews, and truck drivers.

## Run

Install Flutter 3.47 or newer, then from this directory run:

```sh
flutter pub get
flutter run
```

Android and iOS project files are included. iOS builds require macOS and Xcode.

## Features

- Manage worker profiles, worker types, truck plates, and assigned drivers.
- Create pakyaw payrolls with cent-accurate equal shares and editable allocations.
- Create driver payrolls from trip count and rate, with optional deductions.
- Browse and filter saved payroll records; preview, print, or export letter-size PDF slips.
- Records are stored on-device with `shared_preferences`; no account or network is required.

## Verify

```sh
flutter analyze
flutter test
```