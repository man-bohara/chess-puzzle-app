# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

Single Flutter app under `mobile/`. No backend, no admin portal — puzzles ship as a bundled asset.

## Common commands

```bash
cd mobile
flutter pub get                  # install deps
flutter run                      # launch on default device
flutter test                     # run all tests
flutter test test/foo_test.dart  # single test file
flutter analyze                  # static analysis (matches CI)
dart format .                    # format
```

## Architecture

Feature-first layout under `mobile/lib/`. Each feature has `data/` → `application/` → `presentation/`, with `domain/` for plain models.

- `main.dart` wraps the app in `ProviderScope` (Riverpod) and runs it. No async init.
- `app.dart` builds `MaterialApp.router` from `appRouterProvider`.
- `core/router/app_router.dart` — go_router. Routes: `/` (puzzle list, tabbed Easy/Medium/Hard), `/puzzles/:id` (solver). No auth.
- `features/puzzles/domain/puzzle.dart` — `Puzzle` model with `Puzzle.fromJson`.
- `features/puzzles/data/puzzle_repository.dart` — `puzzlesProvider` (FutureProvider) reads `assets/puzzles.json` via `rootBundle` once at startup. `puzzleByIdProvider(id)` looks up from that list.
- `features/puzzles/application/puzzle_controller.dart` — `StateNotifier` per puzzle attempt. Owns a `bishop.Game`. `tryMove(uci)` matches against `puzzle.solution[moveIndex]`; on success it also auto-plays the canned opponent reply at `solution[moveIndex+1]`. Wrong move → `PuzzleStatus.failed`. `reset()` rebuilds from FEN.
- `features/puzzles/presentation/puzzle_list_screen.dart` — `DefaultTabController` with 3 tabs (Easy ≤2, Medium 3–4, Hard ≥5). Each tab numbers puzzles "Puzzle 1, 2, …" within its bucket.
- `features/puzzles/presentation/puzzle_solver_screen.dart` — "X to move" banner + `squares` `BoardController` driven by `bishop.Game.squaresState(orientation)` from the `square_bishop` bridge package.

## Puzzles

The puzzle library lives in `mobile/assets/puzzles.json`. Schema per item:

```json
{
  "id": "string-slug",
  "fen": "...",
  "solution": ["e2e4", "e7e5", ...],
  "difficulty": 1,
  "themes": ["fork", "mateIn2"]
}
```

To add or change puzzles: edit `assets/puzzles.json`, then bump the app version and ship a new build. There is no over-the-air update path.

## Conventions

- **UCI everywhere** — solution moves are stored and exchanged as UCI strings (`e2e4`, `a7a8q`). The board widget round-trips through `move.algebraic()`.
- **`solution` includes opponent replies** — the player moves on even indices (0, 2, …); odd indices are auto-played by the controller.
- **Difficulty buckets** — Easy: 1–2, Medium: 3–4, Hard: ≥5. Defined in `puzzle_list_screen.dart`.
