# AI Virtual Coach 🏋️ 🤖

A Flutter-based mobile application that uses **real-time pose detection** to analyze exercise form and provide instant AI coaching feedback.

**Status:** Research Demo / Graduation Project
**Platform:** Android (primary), iOS, Web, Windows, macOS, Linux
**Language:** Dart / Flutter (SDK ^3.10.4)

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Screens & Components](#screens--components)
- [API Integration](#api-integration)
- [Architecture](#architecture)
- [Development](#development)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)

---

## Features

✅ **Live Pose Detection**
Real-time pose analysis using `flutter_pose_detection` with NPU/GPU acceleration and 33 body landmarks per frame

✅ **Exercise Recording**
Capture workout sessions in front or side camera view with live skeleton overlay

✅ **AI Form Analysis**
Backend ML model evaluates form across multiple aspects (depth, alignment, stability, tempo, etc.)

✅ **Detailed Feedback**
- Overall form score (0–100)
- Aspect-specific scores color-coded by quality
- Personalized coaching tips
- Rep counting

✅ **Athletic UI Design**
- White-background retro aesthetic with thick black borders
- Hard-shadow "3D" buttons (Archivo Black font)
- Custom animated loaders (intersecting circles, gradient progress bar)
- Motivational cues throughout

✅ **Mock Mode**
Full UI development without a running backend (toggle `_useMock` in `api_service.dart`)

✅ **Robust Error Handling**
Graceful fallbacks for network failures, insufficient pose data, and backend errors with user-friendly messages

---

## Quick Start

### Prerequisites

- **Flutter SDK** (v3.10.4+): [Install](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (bundled with Flutter)
- **Android Studio** or **VS Code** with Flutter extension
- **Physical device** or **Android emulator** (camera required for pose detection)

### Clone & Run (2 minutes)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/ai-virtual-coach-app.git
cd ai-virtual-coach-app

# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```

### First Run Flow

1. **Splash Screen** — 800ms fade-in animation, auto-navigates after 1.5s
2. **Home Screen** — Tap **"START WORKOUT"** (retro hard-shadow button)
3. **Camera Setup** — Select Front/Side view, align body in rule-of-thirds grid
4. **Recording** — Live pose skeleton overlay, timer counts up, tap **"FINISH EXERCISE"**
5. **Processing** — Animated progress bar with stage updates (~2s mock, up to 120s real)
6. **Results** — Color-coded scores, aspect breakdowns, coaching feedback, Retry/End

---

## Installation

### Step 1: System Requirements

```bash
# Verify Flutter installation
flutter --version

# Check environment (fix any issues reported)
flutter doctor
```

| Platform | Minimum Requirement |
|----------|---------------------|
| Android  | SDK API Level 21+ (Android 5.0) |
| iOS      | 14.0+ |
| Dart SDK | ^3.10.4 |

### Step 2: Install Dependencies

```bash
flutter pub get
```

**Key Dependencies** (from `pubspec.yaml`):

| Package | Version | Purpose |
|---------|---------|---------|
| `camera` | ^0.11.3 | Camera access & preview |
| `flutter_pose_detection` | ^0.4.1 | Real-time pose detection (MediaPipe, NPU/GPU) |
| `http` | ^1.6.0 | HTTP client for API calls |
| `flutter_riverpod` | ^2.6.1 | State management (ProviderScope) |
| `google_fonts` | ^6.3.3 | Custom typography (Roboto, Archivo Black) |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |

**Dev Dependencies:**

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.10.4 | Code generation runner |
| `json_serializable` | ^6.11.3 | JSON model code generation |
| `flutter_lints` | ^6.0.0 | Recommended lint rules |

### Step 3: Configure Backend URL

Edit `lib/services/api_service.dart` (line 20):

```dart
// For Android Emulator:
const String _baseUrl = 'http://10.0.2.2:8000';

// For Physical Device (replace with your computer's local IP):
// const String _baseUrl = 'http://192.168.1.X:8000';

// For iOS Simulator:
// const String _baseUrl = 'http://localhost:8000';
```

**Finding your local IP:**
- **Windows:** Run `ipconfig` → look for `IPv4 Address` (e.g., `192.168.1.42`)
- **macOS/Linux:** Run `ifconfig` → look for `inet` address

The backend server must be started with:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Step 4: Build & Run

```bash
# Development (hot reload enabled)
flutter run

# Release build (optimized)
flutter run --release

# Run on specific device
flutter devices          # List available devices
flutter run -d <device_id>
```

---

## Project Structure

```
ai-virtual-coach-app/
├── lib/
│   ├── main.dart                           # App entry point, ProviderScope, MaterialApp, route table
│   ├── theme/
│   │   └── app_theme.dart                  # Color palette, text styles (Roboto / Archivo Black), dark theme
│   ├── screens/
│   │   ├── splash_screen.dart              # Fade-in animation (800ms), auto-navigate to /home (1.5s)
│   │   ├── home_screen.dart                # Welcome screen, "START WORKOUT" CTA with hard-shadow button
│   │   ├── camera_setup_screen.dart        # Camera preview, Front/Side view toggle, grid overlay, retry logic
│   │   ├── recording_screen.dart           # Live recording with pose overlay, timer, FPS tracking, data collection
│   │   ├── processing_screen.dart          # API call, animated progress bar, stage-based status text
│   │   ├── results_screen.dart             # Overall score, aspect cards, coach feedback, Retry/End buttons
│   │   └── error_screen.dart               # Error message display, Retry Session / Return Home
│   ├── widgets/
│   │   ├── gradient_progress_bar.dart      # Animated multi-color gradient progress bar (red→green)
│   │   ├── intersecting_circles_loader.dart# Custom rotating arcs animation (red & blue)
│   │   └── pose_overlay_painter.dart       # Renders 33-landmark skeleton on camera preview
│   ├── services/
│   │   ├── api_service.dart                # HTTP client, mock mode, error handling, 120s timeout
│   │   └── pose_landmarker_service.dart    # NPU/GPU pose detection, frame processing, safe shutdown
│   └── models/
│       ├── session_models.dart             # SessionRequest, SessionResponse, ErrorResponse, ApiException
│       └── session_models.g.dart           # Auto-generated JSON serialization (build_runner)
├── android/                                # Android-specific config (Gradle, manifest)
├── ios/                                    # iOS-specific config (Podfile, runners)
├── web/                                    # Web support files
├── windows/                                # Windows desktop support
├── macos/                                  # macOS desktop support
├── linux/                                  # Linux desktop support
├── test/
│   └── widget_test.dart                    # Widget tests
├── pubspec.yaml                            # Dependencies & project config
├── analysis_options.yaml                   # Linting rules
├── backend_api_contract.md                 # Full API specification for backend implementation
└── README.md                               # This file
```

### Key Directories

| Directory | Purpose |
|-----------|---------|
| `lib/screens/` | Full-screen pages — each maps to a named route (`/splash`, `/home`, `/setup`, `/recording`, `/processing`, `/results`, `/error`) |
| `lib/widgets/` | Reusable custom widgets (loaders, progress bars, pose painter) |
| `lib/services/` | Business logic: API client and pose detection service |
| `lib/models/` | Data classes with `@JsonSerializable` for request/response serialization |
| `lib/theme/` | Global design system: colors, typography, button styles |

---

## Usage

### User Flow Diagram

```
┌──────────────────┐
│  Splash Screen   │ ← 800ms fade-in, 1.5s auto-navigate
│  (route: /)      │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  Home Screen     │ ← "START WORKOUT" hard-shadow button
│  (route: /home)  │
└────────┬─────────┘
         ↓
┌───────────────────────────────┐
│  Camera Setup Screen          │ ← Camera preview + rule-of-thirds grid
│  (route: /setup)              │ ← Front/Side view toggle
│                               │ ← Camera flip button
│                               │ ← "START RECORDING" button
└────────┬──────────────────────┘
         ↓
┌───────────────────────────────┐
│  Recording Screen             │ ← Live pose skeleton overlay (~20fps UI)
│  (route: /recording)          │ ← Timer (top-right), FPS tracking
│                               │ ← "FINISH EXERCISE" button
│                               │ ← Collects ALL frames (no data loss)
└────────┬──────────────────────┘
         ↓  (SessionRequest passed as argument)
┌───────────────────────────────┐
│  Processing Screen            │ ← Intersecting circles loader animation
│  (route: /processing)         │ ← Gradient progress bar with 4 stages
│                               │ ← "Analyzing" → "Keypoints" → "Patterns" → "Feedback"
└────────┬──────────────────────┘
         ↓  (Success: SessionResponse)      ↓  (Error: ApiException)
┌───────────────────────────────┐   ┌──────────────────────┐
│  Results Screen               │   │  Error Screen         │
│  (route: /results)            │   │  (route: /error)      │
│  ← Score cards, feedback list │   │  ← Error message      │
│  ← "RETRY EXERCISE" → /setup │   │  ← "RETRY SESSION"    │
│  ← "END SESSION" → /         │   │  ← "RETURN TO HOME"   │
└───────────────────────────────┘   └──────────────────────┘
```

### Mock Mode (No Backend Required)

To develop UI without a running backend server, set the mock flag:

```dart
// lib/services/api_service.dart (line 23)
const bool _useMock = true;  // Returns fake data after 2-second delay
```

The mock response returns a sample squat analysis with 12 reps and 5 aspect scores.

---

## Screens & Components

### Screens

| Screen | File | Key Behavior |
|--------|------|--------------|
| **Splash** | `lib/screens/splash_screen.dart` | White background, black border frame, 800ms fade-in, 1.5s auto-nav to `/home`. Red icon + "AI COACH" title. |
| **Home** | `lib/screens/home_screen.dart` | White bg, black border frame. Red dumbbell icon (160×160). "START WORKOUT" button with animated hard-shadow press effect navigates to `/setup`. |
| **Camera Setup** | `lib/screens/camera_setup_screen.dart` | Initializes camera with retry logic (up to 3 attempts). Shows rule-of-thirds grid overlay, "ALIGN BODY IN GRID" pill, Front/Side view toggle (hard-shadow buttons), camera flip icon. Disposes camera before navigating to `/recording`. |
| **Recording** | `lib/screens/recording_screen.dart` | Receives camera description & view from `/setup`. Initializes `PoseLandmarkerService`, starts image stream. Collects **every** detected frame into `_poseData` (no loss). UI overlay throttled to ~20fps. Timer counts up. "FINISH EXERCISE" stops stream, computes actual FPS, builds `SessionRequest`, navigates to `/processing`. |
| **Processing** | `lib/screens/processing_screen.dart` | Receives `SessionRequest`, calls `ApiService.analyzeSession()`. Shows `IntersectingCirclesLoader` + `GradientProgressBar`. Progress stages: 10% → 25% → 45% → 65% → 85% → 100%. On success navigates to `/results`; on error navigates to `/error`. |
| **Results** | `lib/screens/results_screen.dart` | Displays exercise name (blue card), overall score (color-coded card), aspect score grid (2-column, scores × 10 for 0–100 display), coach feedback list. "RETRY EXERCISE" → `/setup`, "END SESSION" → `/`. |
| **Error** | `lib/screens/error_screen.dart` | Dark background. Shows error icon, "OOPS!" title, error message from `ApiException`. "RETRY SESSION" → `/setup`, "RETURN TO HOME" → `/`. |

### Custom Widgets

| Widget | File | Description |
|--------|------|-------------|
| **GradientProgressBar** | `lib/widgets/gradient_progress_bar.dart` | Animated progress bar with 8-color gradient (red → purple → blue → teal → green). Accepts `progress` (0.0–1.0), `height`, `borderRadius`. Smooth animation between values via `AnimationController`. |
| **IntersectingCirclesLoader** | `lib/widgets/intersecting_circles_loader.dart` | Two rotating arcs (red + blue) offset horizontally on a grey background circle. Continuous 2.5s rotation. Configurable `size` and `strokeWidth`. |
| **PoseOverlayPainter** | `lib/widgets/pose_overlay_painter.dart` | `CustomPainter` that renders 33 MediaPipe landmarks as green dots and 16 skeleton connections as green lines. Filters landmarks with visibility < 0.5. Mirrors X-axis for front camera. |
| **GridPainter** | `lib/screens/camera_setup_screen.dart` | Rule-of-thirds grid overlay (2 vertical + 2 horizontal white lines at 50% opacity). |

### Theme & Design System

Defined in `lib/theme/app_theme.dart`:

**Color Palette:**
| Color | Hex | Usage |
|-------|-----|-------|
| `primaryBlack` | `#000000` | Borders, shadows, text |
| `primaryWhite` | `#FFFFFF` | Backgrounds |
| `accentRed` | `#FF3B30` | Primary action buttons, errors |
| `accentGreen` | `#34C759` | Success, start recording, excellent score |
| `accentBlue` | `#007AFF` | View toggles, info pills, exercise banner |
| `warningOrange` | `#FF9500` | Warning states, "needs improvement" score |
| `darkGrey` | `#1C1C1E` | Surface color |
| `mediumGrey` | `#2C2C2E` | Secondary surface |

**Typography:**
| Style | Font | Size | Weight |
|-------|------|------|--------|
| `titleLarge` | Roboto | 40px | w900 (Black) |
| `titleMedium` | Roboto | 24px | Bold |
| `bodyLarge` | Roboto | 18px | Normal |
| `bodyMedium` | Roboto | 16px | Normal |
| `labelButton` | Archivo Black | 20px | Normal (inherently bold) |

**Score Color Coding:**
| Score Range | Color | Label |
|-------------|-------|-------|
| 85–100 | Green (`#34C759`) | Excellent |
| 70–84 | Teal (`#5AC8FA`) | Good |
| 50–69 | Orange (`#FF9500`) | Needs Improvement |
| 0–49 | Red (`#FF3B30`) | Poor |

---

## API Integration

### Endpoint

```
POST http://<backend-ip>:8000/api/session/analyze
Content-Type: application/json
Client Timeout: 120 seconds
```

### Request Body (`SessionRequest`)

```json
{
  "exercise_view": "front",
  "pose_sequence": [
    [
      [0.5, 0.4, 0.1, 0.99],
      [0.52, 0.38, 0.09, 0.98],
      ...
    ],
    ...
  ],
  "metadata": {
    "fps": 24.57,
    "frame_count": 734,
    "device": "mobile"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `exercise_view` | `string` | `"front"` or `"side"` — selected on Camera Setup screen |
| `pose_sequence` | `float[][][]` | 3D array: `frames × 33 landmarks × 4 values [x, y, z, visibility]` |
| `metadata.fps` | `float` | Actual detection FPS computed from real frame timestamps |
| `metadata.frame_count` | `int` | Total frames where pose detection succeeded |
| `metadata.device` | `string` | Always `"mobile"` for Phase 1 |

### Response — Success (200)

```json
{
  "exercise": "squat",
  "reps_detected": 12,
  "scores": {
    "depth": 8.5,
    "back_angle": 7.0,
    "knees_in": 9.0,
    "tempo": 6.5,
    "stability": 8.0
  },
  "overall_score": 7.8,
  "feedback": [
    "Great depth on most reps!",
    "Watch your back angle, try to keep it more upright."
  ]
}
```

- **Scores** are 0.0–10.0 from the API; the app multiplies by 10 for 0–100 display.
- **Aspect names** use `snake_case`; displayed as uppercase with spaces (e.g., `back_angle` → `BACK ANGLE`).

### Response — Error (non-200)

```json
{
  "error_code": "NO_REPS_DETECTED",
  "message": "No valid repetitions were detected. Please try again with a clearer view."
}
```

| HTTP Status | Error Code | Meaning |
|-------------|------------|---------|
| 400 | `INVALID_REQUEST` | Malformed JSON or missing fields |
| 400 | `NO_POSE_DATA` | Zero frames received |
| 400 | `INSUFFICIENT_FRAMES` | < 30 frames (< ~1 second) |
| 422 | `NO_REPS_DETECTED` | No exercise reps found in pose data |
| 422 | `UNRECOGNIZED_EXERCISE` | Could not identify the exercise type |
| 500 | `ANALYSIS_FAILED` | Backend processing error |

If the response body doesn't match the `{error_code, message}` schema, the app displays: *"Server error ({status_code}). Please try again."*

### Payload Size Estimates

| Duration | Frames (~24fps) | Est. JSON Size |
|----------|-----------------|----------------|
| 15s | ~360 | ~550 KB |
| 30s | ~720 | ~1.1 MB |
| 60s | ~1,440 | ~2.2 MB |
| 120s | ~2,880 | ~4.4 MB |

For the full API specification including Pydantic models and FastAPI endpoint skeleton, see [backend_api_contract.md](backend_api_contract.md).

---

## Architecture

### Layer Diagram

```
┌────────────────────────────────────────┐
│           UI Layer (Screens)           │
│  SplashScreen → HomeScreen →           │
│  CameraSetupScreen → RecordingScreen → │
│  ProcessingScreen → ResultsScreen      │
│               ErrorScreen              │
└──────────────────┬─────────────────────┘
                   │ uses
┌──────────────────▼─────────────────────┐
│       Widget Layer (Custom Widgets)    │
│  PoseOverlayPainter, GridPainter,      │
│  GradientProgressBar,                  │
│  IntersectingCirclesLoader             │
└──────────────────┬─────────────────────┘
                   │ calls
┌──────────────────▼─────────────────────┐
│        Service Layer (Business Logic)  │
│  ApiService (HTTP + mock mode)         │
│  PoseLandmarkerService (NPU/GPU)       │
└──────────────────┬─────────────────────┘
                   │ serializes via
┌──────────────────▼─────────────────────┐
│         Data Layer (Models)            │
│  SessionRequest, SessionResponse,      │
│  ErrorResponse, ApiException           │
│  (@JsonSerializable + generated code)  │
└──────────────────┬─────────────────────┘
                   │ communicates with
┌──────────────────▼─────────────────────┐
│       External (FastAPI Backend)       │
│  POST /api/session/analyze             │
│  (Python + uvicorn, ML inference)      │
└────────────────────────────────────────┘
```

### State Management

| Pattern | Where Used | Details |
|---------|-----------|---------|
| **ProviderScope** (Riverpod) | `main.dart` | Wraps entire app for dependency injection |
| **StatefulWidget** | All screens | Local UI state (camera, timer, pose data, progress) |
| **AnimationController** | Splash, widgets | Fade-in, rotation, progress animations |
| **Image Stream** | `RecordingScreen` | Camera frames → pose detection → data accumulation |

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| ALL frames stored, UI throttled to ~20fps | No data loss for ML; decouples data collection from rendering |
| Camera disposed before navigation | Prevents resource conflicts between `CameraSetupScreen` and `RecordingScreen` |
| Actual FPS computed from timestamps | Accurate metadata for backend analysis (not assumed constant) |
| Visibility threshold (0.5) for overlay | Prevents erratic skeleton lines from undetected landmarks |
| Mock mode toggle | Enables full UI development without backend |
| 120s client timeout | Accommodates long ML processing while eventually failing |
| `pushReplacementNamed` for flow | Prevents back-navigation to intermediate states |

---

## Development

### Hot Reload & Debugging

```bash
# Run with hot reload
flutter run

# In terminal:
# Press 'r' → Hot reload
# Press 'R' → Hot restart
# Press 'q' → Quit

# Verbose logging
flutter run -v
```

### Regenerate JSON Models

After modifying `lib/models/session_models.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

### Customization Points

**Change Theme Colors:**
```dart
// lib/theme/app_theme.dart
static const Color accentRed = Color(0xFFFF3B30);    // Primary action
static const Color accentGreen = Color(0xFF34C759);   // Success
static const Color accentBlue = Color(0xFF007AFF);    // Info/toggle
```

**Change Backend URL:**
```dart
// lib/services/api_service.dart (line 20)
const String _baseUrl = 'http://your-server:8000';
```

**Toggle Mock Mode:**
```dart
// lib/services/api_service.dart (line 23)
const bool _useMock = true;  // true = fake data, false = real API
```

**Adjust Pose Overlay Sensitivity:**
```dart
// lib/widgets/pose_overlay_painter.dart (line 27)
static const double _minVisibility = 0.5;  // 0.0–1.0, higher = stricter filter
```

**UI Update Rate for Overlay:**
```dart
// lib/screens/recording_screen.dart (line 35)
static const Duration _uiUpdateInterval = Duration(milliseconds: 50);  // ~20fps
```

### Building for Release

```bash
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app

# Web
flutter build web --release
# Output: build/web/

# Windows
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

---

## Known Limitations

⚠️ **Research Demo Only** — Not production-ready

| Limitation | Details |
|------------|---------|
| ❌ No user accounts | Each session is anonymous |
| ❌ No workout history | Sessions are not persisted |
| ❌ Single exercise per session | Cannot chain exercises |
| ❌ No video storage | Only pose landmark data is sent to backend |
| ❌ No audio feedback | Text-only coaching tips |
| ❌ No authentication | API has no auth (Phase 1) |
| ❌ Camera required | Pose detection needs live video input |
| ❌ Internet required | Backend API call is mandatory (unless mock mode) |
| ❌ Backend required | App shows error screen if server is unreachable |
| ⚠️ `results_screen.dart` has a hardcoded `displayScore` | The overall score display uses `60.0` instead of `response.overallScore * 10` — needs fix |
| ⚠️ Pose accuracy varies | Depends on lighting, camera angle, body visibility, and device NPU/GPU capabilities |

---

## Contributing

Contributions are welcome! Please:

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/my-feature`)
3. **Commit changes** (`git commit -m "Add my feature"`)
4. **Push branch** (`git push origin feature/my-feature`)
5. **Open a Pull Request** with a clear description

### Code Style

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze
```

- Follow [Flutter best practices](https://docs.flutter.dev/perf/best-practices)
- Add comments for complex logic
- Test on multiple devices before submitting

---

## License

This project is a **research demo** / **graduation project**.

<!-- [Choose a license: MIT, Apache 2.0, GPL, etc.] -->

---

## Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides
- **MediaPipe Pose Landmarks:** https://developers.google.com/ml-kit/vision/pose-detection
- **Backend API Specification:** [backend_api_contract.md](backend_api_contract.md)

---

## Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Flutter Frontend | ✅ Complete | 7 screens, 3 custom widgets, 2 services |
| Pose Detection | ✅ Integrated | `flutter_pose_detection` with NPU/GPU/CPU fallback |
| API Client | ✅ Complete | JSON serialization, error handling, 120s timeout |
| Mock Mode | ✅ Working | Offline UI development with sample data |
| Backend | ⏳ To be implemented | See [backend_api_contract.md](backend_api_contract.md) for full spec |
| User Accounts | ❌ Out of scope | Anonymous sessions only |
| Workout History | ❌ Out of scope | No local or cloud storage |

---

**Happy coaching! 🏋️ 🤖**
