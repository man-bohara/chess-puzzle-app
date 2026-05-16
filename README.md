# Chess Puzzle App

Two-surface chess puzzle product:

- **`mobile/`** — Flutter app where players solve puzzles move-by-move and track progress.
- **`admin/`** — Next.js admin portal where puzzles (FEN, difficulty, solution moves) are authored and published.
- **`firebase/`** — Shared Firebase project config (Firestore rules, indexes, emulator setup) consumed by both clients.

Auth and the puzzle database live in Firebase (Auth + Firestore). The same Firestore project backs both surfaces; the admin portal writes, the mobile app reads.

## Prerequisites

- Flutter 3.41+ (`flutter --version`)
- Node 20+ (`node --version`)
- Firebase CLI: `npm i -g firebase-tools`
- FlutterFire CLI (for `mobile/`): `dart pub global activate flutterfire_cli`

## First-time setup

1. Create a Firebase project at <https://console.firebase.google.com>.
2. Enable **Authentication** (Email/Password + Google) and **Firestore**.
3. Wire up clients:
   - Mobile: `cd mobile && flutterfire configure` — generates `lib/firebase_options.dart`.
   - Admin: `cp admin/.env.local.example admin/.env.local` and fill in the web app config from the Firebase console.
4. Copy `firebase/.firebaserc.example` → `firebase/.firebaserc` and set your project ID.
5. Deploy Firestore rules: `cd firebase && firebase deploy --only firestore:rules,firestore:indexes`.

## Running locally

```bash
# Admin portal (http://localhost:3000)
cd admin && npm run dev

# Mobile app
cd mobile && flutter run

# Firebase emulators (auth + firestore + UI on :4000)
cd firebase && firebase emulators:start
```

## Firestore data model

```
/puzzles/{puzzleId}
  fen          string   // starting position
  solution     string[] // UCI moves, in order
  difficulty   number   // 1–5 or Glicko-style rating
  themes       string[] // e.g. ["fork", "mateIn2"]
  published    boolean
  createdAt    timestamp
  createdBy    string   // admin uid

/users/{uid}/progress/{puzzleId}
  solved       boolean
  attempts     number
  solvedAt     timestamp
```

Admin writes are gated by a custom claim `admin: true` (see `firebase/firestore.rules`). Grant it via the Firebase Admin SDK or a Cloud Function.
