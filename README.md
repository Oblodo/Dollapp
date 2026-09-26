# Dollfind

A private collection app for toys and dolls, built with Flutter for Android and iOS. The archive, identification tips, and marketplace research links work without an account or a backend.

## Build

See [README-BUILD.md](README-BUILD.md) for the build workflow, Android APK, and iOS signing requirements. GitHub Actions generates the Android and iOS platform shells during each build. An iPhone-only import uses `Dollfind_import_mobile.yml` as the permanent build workflow; it replaces the bundled `.github/workflows/build.yml` during import.

The Flutter SDK is not installed in the environment where this archive was prepared, so compilation has not yet been verified. Check the Actions run after pushing.

## Optional identification service

In Settings, the owner can supply an HTTPS server URL and access token for a private identification service. The app sends a `POST` multipart request to `/identify` with up to three selected photos, item clues, and an `Authorization: Bearer` header, only after confirmation. Item notes are not sent. The backend mentioned in the build guide is **not included in this repository snapshot**, so identification needs a separately configured compatible server.

The token is kept in app preferences (`SharedPreferences`), which is not hardware-backed secret storage. Use a revocable token and rotate it if the device is lost. Do not place service credentials in this repository or in build artifacts.

## Project structure

- `lib/`: UI, local archive, marketplace links, and optional identification client.
- `assets/`: offline identification tips.
- `.github/workflows/build.yml`: Android and iOS compilation.
