# truce_app

A new Flutter project.

## Environment variables

MetalPrice API requires an API key passed at build/run time (do not hardcode it in source):

- `flutter run --dart-define=METALPRICE_API_KEY=YOUR_KEY_HERE`

Or create a local `.env` file (ignored by git) based on `.env.example`:

- `cp .env.example .env`
- Make sure `.env` is listed under `flutter/assets` in `pubspec.yaml` (it is in this repo).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
