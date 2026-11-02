# 🐍 Brick Snake: 1100 Edition

[![Play Online](https://img.shields.io/badge/Play%20Online-GitHub%20Pages-brightgreen?style=for-the-badge&logo=github)](https://smh1s1n.github.io/brick-snake/)
[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-blue?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A faithful, 100% feature-complete recreation of the iconic **Snake II** game from the legendary **Nokia 1100** feature phone. Built from scratch with **Flutter**, **Riverpod**, and **Domain-Driven Design (DDD)**.

---

### 🌐 Play Live in Browser (No Installation Required)

👉 **[https://smh1s1n.github.io/brick-snake/](https://smh1s1n.github.io/brick-snake/)**

Plays seamlessly on iPhone, Android, iPad, Mac, Windows, and Linux.

---

## 🕹️ Features

### Authentic Nokia 1100 Hardware & Aesthetics
- **Physical Chassis**: Contoured silicone body, rubber keypad with 3D tactile press animations, top earpiece slit, bottom microphone pinholes.
- **Clickable LED Torch**: The Nokia 1100's iconic top white flashlight actually toggles on and off!
- **96×65 Dot-Matrix LCD Display**:
  - Pixel mesh shader with authentic ghost-pixel contrast.
  - Classic Nokia status bar: 4-bar signal meter, 4-bar battery gauge, and sound profile icon.
  - **Themes**: Classic Nokia Green Backlight, Retro 3310 Amber/Orange, and Monochromatic Grey.
  - Live backlight toggle (on/off).

### 100% Feature-Ready Snake II Gameplay
- **5 Authentic Nokia Mazes**:
  1. *Maze 1 (Open)*: Continuous edge-to-edge wrap-around boundary.
  2. *Maze 2 (Solid Box)*: Outer perimeter barrier wall.
  3. *Maze 3 (Tunnel)*: Horizontal dividing lanes with pass-through end exits.
  4. *Maze 4 (Mill)*: Central obstacle cross and corner boundary pillars.
  5. *Maze 5 (Rails)*: Dual vertical railway obstacle lines.
- **9 Tuned Speed Levels**: Calibrated from Level 1 (160ms) to Level 9 (30ms).
- **Food & Bonus Insects**:
  - Regular food dots (`Level × 10` points) with snake growth.
  - Bonus bugs (insects, spiders, flies) spawn every 5 items with a shrinking countdown timer bar.
- **Input Buffering**: Up to 2 moves queued to completely prevent accidental 180° self-collision when typing quickly.
- **Procedural 8-Bit Audio**: Monophonic square-wave WAV synthesizer reproducing the authentic Nokia piezo buzzer (zero external audio asset latency).
- **Haptic Feedback**: Tactile click on buttons, food eat pulse, and crash vibration.
- **Persistent High Scores**: Local leaderboard saved per maze type.

---

## ⌨️ Controls

| Action | On-Screen Nokia Keypad | Desktop / Laptop Keyboard | Touch Gesture |
| :--- | :--- | :--- | :--- |
| **Move Up** | `2` or Rocker ▲ | `Arrow Up` / `W` / Numpad `2` | Swipe Up |
| **Move Down** | `8` or Rocker ▼ | `Arrow Down` / `S` / Numpad `8` | Swipe Down |
| **Move Left** | `4` | `Arrow Left` / `A` / Numpad `4` | Swipe Left |
| **Move Right** | `6` | `Arrow Right` / `D` / Numpad `6` | Swipe Right |
| **Select / Pause** | `MENU` / `5` | `Enter` / `Space` / Numpad `5` | Tap Button |
| **Back / Exit** | `C` (Clear) | `Escape` / `Backspace` / `C` | Tap `C` |
| **Toggle Backlight** | Menu Option | `L` | Menu Option |
| **Toggle Torch** | Tap top flashlight | `T` | Tap top flashlight |

---

## 🏛️ Architecture (Domain-Driven Design)

The codebase strictly separates concerns into clean DDD layers:

```
lib/
├── core/
│   ├── audio/              # Procedural 8-bit WAV square-wave synthesizer & audio engine
│   ├── constants/          # Nokia colors, LCD palettes, board constants, speeds
│   └── utils/              # Haptic feedback utilities
├── domain/
│   ├── models/             # Pure Entities & Value Objects: Snake, Position, Maze, Food, BonusFood
│   └── repositories/       # Abstract interfaces: IHighScoreRepository, IGameSettingsRepository
├── infrastructure/
│   ├── datasources/        # Local storage & platform plugins
│   └── repositories/       # SharedPreferences persistence implementations
├── application/
│   ├── game/               # Riverpod Notifier: game loop, tick engine, input buffer, state transitions
│   ├── settings/           # Riverpod Notifier: sound, vibration, themes, backlight
│   └── providers.dart      # Dependency injection & providers
└── presentation/
    ├── phone/              # Nokia 1100 casing, silicone keypad & buttons
    ├── screen/             # 96x65 LCD display, custom painter, status bar, bitmap LCD font
    └── views/              # Menu, maze picker, level gauge, instructions, high scores
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.47 or later)
- Dart SDK (v3.13 or later)

### Run Locally

1. **Clone the repository**:
   ```bash
   git clone https://github.com/smh1s1n/brick-snake.git
   cd brick-snake
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on macOS Desktop**:
   ```bash
   flutter run -d macos
   ```

4. **Run in Chrome Browser**:
   ```bash
   flutter run -d chrome
   ```

5. **Run Tests**:
   ```bash
   flutter test
   ```

---

## 🚢 Continuous Deployment

The repository includes a GitHub Actions workflow (`.github/workflows/deploy.yml`). Whenever changes are pushed to `main`, GitHub Actions automatically tests, builds, and publishes the latest web release to GitHub Pages.

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

### Disclaimer
*This project is an independent open-source tribute created for educational and nostalgic purposes. "Nokia" and Nokia phone models are registered trademarks of Nokia Corporation and HMD Global Oy. This project is not affiliated with, endorsed by, or sponsored by Nokia.*
