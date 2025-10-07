## Higher or Lower? (iOS)

![App Icon](HigherOrLower.png)

### Overview

Higher or Lower? is a fast-paced guessing game for iPhone and iPad. Each round presents a factual prompt (e.g., "Number of active gamers worldwide"). You drag a slider to guess the value. The goal is to score as many points as possible before you run out of lives.

Built with SwiftUI, the app features a simple architecture centered on a single `GameManager` that orchestrates game state, scoring, and question flow.

### How to Play

- **Start**: Tap "New Game" on the home screen.
- **Question**: Read the prompt at the top.
- **Initial guess**: We give you a starting guess and a slider range appropriate to the question.
- **Adjust**: Drag the slider to set your final guess, then tap "Submit Guess".
- **Result**: See the correct answer, your accuracy, and points earned.
- **Next**: Tap "Next Question" to continue until you run out of lives.

#### Lives and Scoring Rules

- **You have 3 lives.** Lose them all and the game ends.
- **Never guess below the correct answer**:
  - If your guess is below the true value, you get **0 points** and **lose 1 life**.

- **Non-year questions** (e.g., counts, quantities):
  - If your guess is above the correct value but more than **20%** too high, you get **0 points** and **lose 1 life**.
  - If within **0–20%** above the correct value, you earn up to **100 points** (closer = more points, using an exponential curve).

- **Year questions** (e.g., "The year the first iPhone was released"):
  - If you guess **before** the correct year, you **lose 1 life** and score **0**.
  - If you guess too far into the future (≥50% of the available range from the event year to present), you also score **0**.
  - Otherwise, you earn up to **100 points** based on how far into the available range you guessed (closer to the event = more points, using an exponential curve).

- **High Score**: Your best score is saved locally and shown on the home screen.

### Data

- Questions are loaded from `Data/holdb.csv` bundled with the app.
- CSV schema: `Fact,Value,Unit`
  - Example: `"Number of active gamers worldwide",3100000000,gamers`
  - For year-based items, `Unit` is `year`.

### Architecture

- `HigherOrLowerApp.swift`: App entry that creates a single `GameManager` and switches between views based on `gameState`.
- `Models/GameManager.swift`:
  - Manages `gameState` (`home` | `playing`), `lives`, `score`, `highScore`, and the `currentQuestion`.
  - Loads questions from `Data/holdb.csv` on init, tracks unused questions, and serves a new random question each round.
  - Implements scoring and life-loss logic for both year and non-year questions.
  - Persists `highScore` to `UserDefaults`.
- `Models/Question.swift`:
  - Encapsulates a prompt, correct answer, units, and generates a suitable slider `range` and `proposedValue` (initial guess) at initialization.
  - Detects `isYearQuestion` automatically when `units == "year"`.
- `Views/HomeView.swift`: Landing screen with "New Game", "How to Play", and shows saved high score.
- `Views/GameView.swift`: Core gameplay UI with vertical slider, formatted number display, results area, and next/submit controls.
- `Views/HowToPlayView.swift`: In-app rules summary.
- `Views/GameOverView.swift`: Game-over actions (also summarized inline in `GameView`).

### Requirements

- Xcode 15 or newer
- iOS 17 SDK (runs on iOS 16+ with SwiftUI NavigationView stack style used here)
- Swift 5.9+

### Getting Started (Run Locally)

1. Clone the repository:
   ```bash
   git clone <your-fork-or-clone-url>
   cd HigherOrLower
   ```
2. Open the project:
   - Double-click `HigherOrLower.xcodeproj` (or open from Xcode File > Open...).
3. Select a target device:
   - Use an iOS Simulator (e.g., iPhone 15) or a connected device.
4. Build & Run:
   - Press Cmd+R in Xcode.

### Troubleshooting

- **CSV not found at runtime**:
  - Ensure `Data/holdb.csv` is included in the app bundle. In Xcode, check the file's Target Membership for the app target.
- **High score not persisting**:
  - iOS Simulator may reset app data between reinstalls; `highScore` is stored in `UserDefaults` and persists per app install.
- **Weird slider steps for large numbers**:
  - The UI intentionally snaps to larger increments (e.g., 0.1 million/billion) for readability.

### Notes

- The question pool randomizes without immediate repeats until all have been used.
- The scoring uses exponential decay to reward closer guesses while penalizing large overshoots.

### License

This project is provided as-is for personal use and learning. Add your preferred license if distributing.


