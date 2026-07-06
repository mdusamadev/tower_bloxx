# Tower Bloxx

A Tower Bloxx-style stacking game built with **Flutter** and **Flame**. Swing a crane load left and right, tap to drop building blocks, and stack as high as you can.

## Gameplay

- Tap anywhere to release the hanging block while it swings.
- Land blocks on the tower or the ground platform — at least 60% of the block must overlap the surface below.
- **Perfect alignment** (within ~1px of center) awards **+5 bonus points** with an on-screen animation.
- Each successful stack increases swing speed and arc width, making later drops harder.
- Miss the stack and the block topples — game over.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>=3.3.0`)

### Run the game

```bash
flutter pub get
flutter run
```

Supported targets include iOS, Android, macOS, and web (audio support varies by platform).

## Project structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # MaterialApp + Flame GameWidget
├── audio/
│   └── game_audio.dart       # Sound effect preload & playback
├── game/
│   ├── tower_bloxx_game.dart # Core game logic & physics
│   ├── mode.dart             # swinging / falling / toppling states
│   ├── models/
│   │   └── swing_ghost.dart  # Motion trail data
│   └── components/           # Flame components (crane, ground, trail)
└── ui/
    ├── game_ui.dart          # Shared colors & typography
    └── overlays/             # Score HUD, perfect bonus, game over
```

## Assets

### Images (`assets/images/`)

| File | Description |
|------|-------------|
| `bg-starry-night.png` | Night city background |
| `crane-claw-with-hook.png` | Crane hook + chain + claw sprite |
| `floor-terracotta-brick.png` | Building floor tile |
| `floor-cream-sandstone.png` | Building floor tile |
| `floor-modern-glass.png` | Building floor tile |

### Audio (`assets/audio/`)

Sound effects from [Kenney](https://kenney.nl) (CC0). Files are stored as **WAV** for macOS/iOS compatibility.

| File | Event |
|------|-------|
| `drop.wav` | Block released |
| `land.wav` | Successful landing |
| `perfect.wav` | Perfect alignment bonus |
| `game_over.wav` | Block topples |
| `ambient.wav` | Looping night background music (Kenney — *Night at the Beach*) |

## Dependencies

- [flame](https://pub.dev/packages/flame) — game engine
- [flame_audio](https://pub.dev/packages/flame_audio) — sound effects
- [google_fonts](https://pub.dev/packages/google_fonts) — Lilita One UI font

## License

Game code is provided as-is for personal and educational use. Kenney audio assets are [CC0](https://creativecommons.org/publicdomain/zero/1.0/). Image assets are project-specific — check their license before redistribution.
