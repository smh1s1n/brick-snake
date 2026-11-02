# 🎮 Brick Snake: 1100 Edition — Deployment & Sharing Guide

> **Live Public URL**: [https://smh1s1n.github.io/brick-snake/](https://smh1s1n.github.io/brick-snake/)  
> **Source Repository**: [https://github.com/smh1s1n/brick-snake](https://github.com/smh1s1n/brick-snake)

---

## 📱 How Friends & Family Can Play

Anyone can open this link on **any device** (iPhone, Android, Mac, Windows, Linux) without installing anything:

👉 **[https://smh1s1n.github.io/brick-snake/](https://smh1s1n.github.io/brick-snake/)**

- **Mobile (Touch)**: Use the on-screen silicone keypad (`2`, `4`, `6`, `8`, `MENU`, `C`) or swipe directly on the LCD screen.
- **Desktop (Keyboard)**:
  - `Arrow Keys` or `WASD` or `2, 4, 6, 8`: Steer snake
  - `Enter` / `Space` / `5`: Select / Pause / Resume
  - `Escape` / `Backspace` / `C`: Back / Menu
  - `L`: Toggle green LCD backlight
  - `T`: Toggle top LED flashlight

*Your computer does **not** need to be on — the game is hosted 24/7 on the cloud.*

---

## 🛠️ How This Was Deployed (Step-by-Step)

### Step 1: Optimized Release Web Build
Configured the Flutter web build with the base href matching the GitHub repository name:
```bash
flutter build web --base-href "/brick-snake/" --release
```
This compiled all Dart code, procedural 8-bit sound generator, and Nokia retro UI shaders into a static bundle in `build/web/`.

### Step 2: Created the Public GitHub Repository
Using your authenticated GitHub account (`smh1s1n`):
```bash
git init
git branch -M main
git add .
git commit -m "feat: Brick Snake 1100 Edition (Flutter + Riverpod + DDD)"
gh repo create smh1s1n/brick-snake --public --source=. --remote=origin --push
```

### Step 3: Deployed the Static Web Assets to `gh-pages`
Pushed the compiled `build/web` folder cleanly to the dedicated `gh-pages` branch:
```bash
TREE_ID=$(git write-tree --prefix=build/web)
COMMIT_ID=$(git commit-tree "$TREE_ID" -m "Deploy Brick Snake to GitHub Pages")
git push origin "${COMMIT_ID}:refs/heads/gh-pages" --force
```

### Step 4: Enabled GitHub Pages
GitHub Pages automatically activated on the `gh-pages` branch with HTTPS enforcement.

### Step 5: Configured Automated Continuous Deployment (CI/CD)
Added `.github/workflows/deploy.yml` so that whenever you make future code updates and run `git push origin main`, GitHub Actions will automatically re-compile and publish updates to the live site within 1 minute!
