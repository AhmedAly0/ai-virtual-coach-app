# AI Virtual Coach – Flutter Frontend PRD & Backend API Contract with Figma Handoff

---

## PART A — FRONTEND-FOCUSED PRD

### 1. Purpose

This document defines the scope, screens, states, and assumptions needed for Lovable.dev to generate a **Flutter frontend** for the AI Virtual Coach MVP.

This is a **research demo / graduation project**, not a consumer fitness app.

---

### 2. Product Scope (Frontend Only)

**In Scope:**

- Camera-based workout recording (single exercise per session)
- Session lifecycle management (record → process → results)
- Text-only AI feedback visualization
- Error and retry handling

**Out of Scope:**

- User accounts / authentication
- Workout history
- Real-time feedback during exercise
- Video storage or playback
- Audio feedback
- Payments or subscriptions

---

### 3. Core User Flow

```
Home → Camera Setup → Recording → Processing → Results → End Session
```

The user performs **one exercise per session**.

---

### 4. Screens & Responsibilities

#### 4.1 Home Screen

- App title and short description
- "Start Workout" CTA
- Optional disclaimer (research demo)
- Style: **Athletic, gym-inspired, coach-style** with bold typography and energetic accents

#### 4.2 Camera Setup Screen

- Camera preview (front or side view)
- Instruction text: "Place phone X meters away"
- View selection toggle (Front / Side)
- "Start Recording" button
- Style: Fitness aesthetic, clear icons, motivating visuals

#### 4.3 Recording Screen

- Live camera preview
- Recording indicator (timer or red dot)
- Minimal UI to avoid distraction
- "Finish Exercise" button
- Style: Coach-style interface, energetic colors, clear recording cues
- No pose overlays, no video saved locally

#### 4.4 Processing Screen

- Loading animation
- Text: "Analyzing your exercise form"
- Disable navigation
- Style: Athletic theme, dynamic loading visuals, motivational text

#### 4.5 Results / Feedback Screen

- Detected exercise name
- Overall form score (aggregated)
- Breakdown of 5 aspect scores (0–10)
- Textual feedback paragraphs
- Buttons: "Retry Exercise" and "End Session"
- Style: Gym/coaching theme, clear metrics display, motivational cues

#### 4.6 Error / Retry Screen

- Displayed when no reps detected, backend error, or invalid input
- Buttons: "Retry Session" and "Return to Home"
- Style: Athletic style, energetic call-to-actions

---

### 5. UI & UX Guidelines

- Portrait orientation only
- Bold, high-contrast typography
- Energetic accent colors (reds, blues, greens)
- Motivational cues where appropriate
- Clear loading and error states
- Maintain consistent spacing, margins, and button sizes for mobile usability

---

### 6. Frontend Technical Assumptions

- Built with **Flutter**
- Camera access available
- Internet connection available
- Backend APIs already exist
- Pose extraction handled locally or abstracted

**Must not** implement pose extraction logic — only manage recording lifecycle and API calls.

---

## PART B — BACKEND API SCHEMA (ASSUMED BY FRONTEND)

### 1. Session Submission

**POST** `/api/session/analyze`

**Request Body:**

```json
{
  "exercise_view": "front" | "side",
  "pose_sequence": [[[x,y,z], ... 33 landmarks], ...],
  "metadata": {
    "fps": 30,
    "device": "mobile"
  }
}
```

### 2. Successful Response

```json
{
  "exercise": "squat",
  "reps_detected": 12,
  "scores": {
    "aspect_1": 7.5,
    "aspect_2": 8.0,
    "aspect_3": 6.5,
    "aspect_4": 7.0,
    "aspect_5": 8.2
  },
  "overall_score": 7.4,
  "feedback": [
    "Your squat depth was consistent across reps.",
    "Maintain a more upright torso to reduce forward lean.",
    "Knee alignment was generally good, with slight inward movement on later reps."
  ]
}
```

### 3. Error Response

```json
{
  "error_code": "NO_REPS_DETECTED",
  "message": "No valid repetitions were detected. Please try again."
}
```

### 4. Frontend Error Handling Rules

- Show retry screen on non-200 responses
- Display backend error message verbatim
- Allow user to restart session

---

## PART C — FIGMA HANDOFF INSTRUCTIONS

- You are Provided with **Figma Make project link** containing the 6 wireframe frames.
https://www.figma.com/make/jQ8Flbax6wOhzlCKeAvaoi/AI-Virtual-Coach-Wireframes?t=HmcaoGy70H1xoXhI-20&fullscreen=1

- Include **mobile-friendly spacing and sizing guidance**: 
  - Buttons ~48–56 px height, ~80% width
  - Standard mobile padding 16–24 px
  - Camera preview occupies ~50–60% of screen height
  - Text hierarchy: Title 24–32 pt, Subtitle 16–18 pt, Body/Feedback 14–16 pt
- Reinforce athletic/gym/coach-style theme: bold typography, energetic accent colors, motivational cues

---


