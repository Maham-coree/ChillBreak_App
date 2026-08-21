# ChillBreak — Flutter Code Setup Guide

Ye poora `lib/` folder hai jo tumhare 4 screens (Home, Breathing, Progress,
Profile) bana deta hai — colors, layout, sab tumhare design se match karte
hain.

## Step 1: Naya Flutter project banao (agar pehle nahi banaya)
```
flutter create chillbreak
cd chillbreak
```

## Step 2: Purana `lib` folder delete karo
Apne naye project ke andar jo `lib` folder hai (default `main.dart` ke saath),
usko delete kar do.

## Step 3: Ye poora `lib` folder copy karo
Is zip mein jo `lib` folder hai, usko poora apne `chillbreak` project ke
andar paste kar do (root level pe, `pubspec.yaml` ke saath waali jagah).

Final structure aisa dikhna chahiye:
```
chillbreak/
  lib/
    main.dart
    theme/
      app_colors.dart
    widgets/
      bottom_nav_bar.dart
      gradient_button.dart
      streak_card.dart
      mood_slider_card.dart
      activity_card.dart
    screens/
      home_screen.dart
      breathing_screen.dart
      progress_screen.dart
      profile_screen.dart
  pubspec.yaml
```

## Step 4: `pubspec.yaml` mein dependencies add karo
`pubspec.yaml` file kholo, `dependencies:` section ke neeche ye lines add karo:
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  flutter_tts: ^4.0.2
  shared_preferences: ^2.2.3
```
(`flutter_tts` — Motivational Audio bolne ke liye. `shared_preferences` —
Gratitude entries phone mein save rakhne ke liye.)

## Step 5: Packages install karo
Terminal mein:
```
flutter pub get
```

## Step 6: Run karo
```
flutter run
```
Emulator ya apne phone (USB debugging on) pe select karke run karo.

---

## Kaam kya hua hai isme
- **Home screen**: greeting, streak card (14 days, week dots), mood slider,
  5 activity cards (Breathing, Chill Music, Daily Quote, Mini Game,
  Gratitude)
- **Breathing screen**: animated pulsing circle, phase ticks (4s/7s/8s/1s),
  duration/cycles/phase stat boxes, Start/Pause button
- **Progress screen**: 4 stat cards, weekly bar chart, month calendar with
  session dots
- **Profile screen**: avatar, stats row, 6 achievement badges
  (locked/unlocked), preferences list
- **Bottom nav**: switches between all 4 screens, active tab highlighted in
  purple

## Feature status
- ✅ **Daily Quote** — 60 quotes, "New quote" button
- ✅ **Mini Game (Bubble Pop)** — fully working
- ✅ **Breathing** — real cycle + real hours tracked. **Ab Home screen ka
  "Breathing" card bhi tap karne pe khulta hai** (pehle kuch nahi hota
  tha — fix ho gaya).
- ✅ **Motivational Audio** — paragraphs bolta hai, English/Urdu.
  **Overflow error fix ho gaya** — lambe paragraphs ab card ke andar
  scroll ho jate hain instead of overflow karne ke (pehle "BOTTOM
  OVERFLOWED BY 52 PIXELS" wali yellow-black warning aa rahi thi).
- ✅ **Gratitude** — save + history working
- ✅ **Real name, streak, sessions, breathing hours, month calendar**

## Icons ka masla solve ho gaya
Koi SVG export nahi karni padi — sab icons Flutter ke built-in
`Icons.*` set se aa rahe hain (flame emoji ke alawa, jo text hai). Agar
baad mein apne custom icons daalne hain, `assets/icons/` folder banake
`pubspec.yaml` mein register karna hoga — abhi zaroorat nahi.

## Agla step
- Colors ko apne exact Figma hex codes se match karna ho to sirf
  `lib/theme/app_colors.dart` file edit karo — poori app automatically
  update ho jayegi.
- Mood slider aur streak data abhi static (hardcoded) hai. Real data save
  karne ke liye `shared_preferences` package add karna hoga — jab ready ho,
  bata dena, wo step bhi guide kar dunga.
