# GEMINI.md - Project Context for Gemini CLI

## Project Overview

This project is a Flutter-based mobile application designed to help "mom-and-pop" small businesses and solo bookkeepers manage receipts. The core problem it solves is the inefficiency and inaccuracy of existing receipt management tools. The app focuses on providing a fast, reliable, and offline-first experience for capturing receipt images, extracting key information using on-device OCR, and exporting the data into a clean, bookkeeping-ready CSV format.

The project explicitly prioritizes a user-friendly correction workflow over chasing perfect OCR automation. It aims to deliver a trustworthy "assistant" that makes manual verification and editing as painless as possible.

**Key Technologies:**

*   **Frontend:** Flutter
*   **State Management:** Riverpod
*   **Image Processing & OCR:** `camera`, `image`, `google_ml_kit`
*   **Local Storage:** `sqflite`
*   **CSV Processing:** `csv`
*   **Linting:** `flutter_lints`

## Building and Running

While no explicit build scripts like a `Makefile` were found, the project appears to follow standard Flutter conventions.

**To run the app (development):**

```bash
flutter run
```

**To build the app (release):**

```bash
flutter build <platform>
```

*(Replace `<platform>` with `apk`, `appbundle`, `ios`, etc.)*

**To run tests:**

```bash
flutter test
```

## Development Conventions

*   **Evidence-Based Requirements:** The project has a strong emphasis on using data and research to define requirements, as evidenced by the `EVIDENCE_BACKED_REQUIREMENTS.md` file. This document should be consulted before implementing new features.
*   **Offline-First:** The application is designed to be fully functional without a network connection. All data is stored locally by default.
*   **Focus on User Experience:** The project prioritizes a smooth and efficient user experience, especially when it comes to correcting OCR errors.
*   **Code Style:** The project uses `flutter_lints` to enforce a consistent code style. Refer to the `analysis_options.yaml` file for specific rules.
*   **State Management:** The project uses Riverpod for state management. New features should follow the existing Riverpod patterns.
*   **Testing:** The project includes a testing setup with `flutter_test`, `mockito`, and `build_runner`. New features should be accompanied by corresponding tests.
