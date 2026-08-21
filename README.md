# CampusX — Windows Desktop

A native Flutter Windows desktop app for the CampusX campus platform, with
**Pegasus** — a built-in, streaming AI assistant — wired in throughout.

## Features

- Campus Feed — posts, galleries, likes, comments, real-time via Supabase
- Anonymous Confessions
- Direct Messaging — 1-on-1, real-time sync
- Pegasus AI Assistant — streaming Gemini-backed campus tutor: homework
  help, study planning, exam prep, coding explanations. Replies stream in
  token-by-token, automatically fails over across multiple API keys if one is
  rate-limited, and remembers each user's conversation in Supabase.
- Clubs & Communities, Events, Marketplace, Polls
- People search, Admin console (users, posts, reports, flags, logs)
- Glassmorphic UI, instant dark/light theme switching

## Project status

This project builds a real, installable Windows desktop app, not a
browser wrapper. It uses Flutter's native Win32 desktop embedder
(`windows/runner/*`), so the output is a proper `CampusX.exe` plus a
one-click `CampusXSetup.exe` installer (via Inno Setup).

---

## 1. One-time setup (on a Windows machine)

You need:

1. **Flutter SDK** (stable channel) — https://docs.flutter.dev/get-started/install/windows
2. **Visual Studio 2022** with the **"Desktop development with C++"** workload
   (Flutter's Windows build uses MSVC/CMake under the hood) —
   https://visualstudio.microsoft.com/downloads/
3. **Git** (to clone/manage the repo)
4. Optional, for the installer: **Inno Setup** (free) —
   https://jrsoftware.org/isinfo.php

Verify everything's wired up:

```powershell
flutter doctor -v
flutter config --enable-windows-desktop
```

## 2. Configure secrets — do this before your first real build

No API key is hardcoded in this project. Every secret (Supabase URL/key,
Gemini API key) is injected at build time via `--dart-define`, so nothing
sensitive ever sits in source control or gets permanently baked into the
`.exe` where it can't be rotated.

Copy the example env file and fill in your real values:

```powershell
copy env.example.json env.json
notepad env.json
```

`env.json` is already in `.gitignore` — it will never be committed.

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your_supabase_publishable_key",
  "GEMINI_API_KEY": "your_gemini_api_key",
  "GEMINI_API_KEYS": "",
  "GEMINI_MODEL": "gemini-2.5-flash"
}
```

- `SUPABASE_ANON_KEY` is Supabase's public/publishable client key — safe to
  ship (it's gated by Row Level Security server-side), but still injected
  rather than hardcoded so you can swap projects without touching code.
- `GEMINI_API_KEY` is **not** safe to leave in a public repo or an
  already-shipped `.exe` long term — treat it like a password and rotate it
  in Google AI Studio if it ever leaks.
- `GEMINI_API_KEYS` is optional: a comma-separated list of extra keys Pegasus
  will automatically fail over to if one gets rate-limited.

## 3. Get dependencies

```powershell
flutter pub get
```

## 4. Run in development

```powershell
flutter run -d windows --dart-define-from-file=env.json
```

## 5. Build for release

```powershell
flutter build windows --release --dart-define-from-file=env.json
```

Output lands at:

```
build\windows\x64\runner\Release\CampusX.exe
```

That folder (`Release\`) is a fully self-contained, redistributable app —
you can zip it and hand it to someone, and it'll run on any Windows 10/11 x64
machine without them installing Flutter.

## 6. Build a proper installer (recommended for release)

This repo includes an Inno Setup script that packages the release build into
a single `CampusXSetup.exe` with Start Menu shortcuts, an uninstaller, and an
optional desktop icon.

1. Install Inno Setup (https://jrsoftware.org/isinfo.php).
2. Make sure you've already run step 5 above (the release build must exist).
3. Open `installer\campusx.iss` in Inno Setup and click **Compile**
   — or from the command line:
   ```powershell
   & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\campusx.iss
   ```
4. The installer is written to `installer\Output\CampusXSetup.exe`.

## 7. Automated builds (GitHub Actions)

`.github/workflows/main.yml` builds `CampusX.exe` and `CampusXSetup.exe` on
every push, using GitHub Actions secrets (never committed) for the API
keys. Set these once under Settings -> Secrets and variables -> Actions:

| Secret | Required |
|---|---|
| `SUPABASE_URL` | yes |
| `SUPABASE_ANON_KEY` | yes |
| `GEMINI_API_KEY` | yes (for Pegasus to work) |
| `GEMINI_API_KEYS` | optional (comma-separated failover keys) |

Every run publishes two downloadable artifacts: the raw build
(`campusx-windows-x64-raw`) and the installer (`CampusXSetup`).

---

## Project layout

```
lib/
  core/            theme, shared widgets, config (env.dart - secrets loader)
  models/          data models (posts, events, polls, ai_message, etc.)
  providers/       app state (auth, feed, chat, notifications, ui)
  screens/         one folder per feature area
    pegasus/       Pegasus AI assistant screen, floating widget, chat view
  services/        Supabase-backed services (posts, events, messages, ...)
    pegasus_service.dart   Gemini streaming client + key rotation + persistence
windows/
  runner/          native Win32 entry point, window chrome, app icon, version info
  flutter/         Flutter engine glue (CMake) - do not edit
installer/
  campusx.iss      Inno Setup script -> CampusXSetup.exe
.github/workflows/
  main.yml         CI: builds CampusX.exe + CampusXSetup.exe on every push
```

## How Pegasus works

`lib/services/pegasus_service.dart` is the assistant's core:

- Calls Gemini's `streamGenerateContent` endpoint over Server-Sent Events, so
  replies render token-by-token in `pegasus_chat_view.dart` instead of
  blocking until the full answer is ready.
- Rotates across every key in `GEMINI_API_KEYS` automatically if one hits a
  rate limit (HTTP 429), retrying the same request on the next key.
- Sends a proper Gemini `system_instruction` (not faked as a first chat
  turn) that defines Pegasus's persona and keeps it in character even if
  asked "are you Gemini?".
- Bounds the conversation window sent per request
  (`AppEnv.geminiMaxHistoryTurns`) so token cost doesn't grow unbounded on
  long-running chats, and caps `maxOutputTokens` so a single reply can't run
  away.
- Persists every user/assistant turn to Supabase (`ai_messages` table) per
  signed-in user, so history survives app restarts.

## Full database reset

`db/reset_and_recreate.sql` drops and recreates the entire Supabase schema
from scratch, matching exactly what `lib/services/*.dart` and `lib/models/*.dart`
actually query — table names, columns, foreign keys, the counters Pegasus and
the feed rely on, and RLS policies for every table. It does **not** touch
`auth.users`; a matching `profiles` row is auto-created via trigger the next
time each account signs in.

**This is destructive and irreversible** — it deletes every row in every
table. Back up first if you have data worth keeping (Supabase Dashboard →
Database → Backups). To run it: Supabase Dashboard → SQL Editor → New query →
paste the file's contents → Run.

## Troubleshooting

- **`flutter build windows` fails immediately** — you're missing the Visual
  Studio "Desktop development with C++" workload; install it and re-run
  `flutter doctor -v` to confirm the Windows toolchain shows a checkmark.
- **Pegasus replies with "key is not configured"** — you built without
  `--dart-define-from-file=env.json` (or `env.json` is missing `GEMINI_API_KEY`).
- **App builds but Supabase calls fail** — double-check `SUPABASE_URL` /
  `SUPABASE_ANON_KEY` in `env.json` match your Supabase project's API
  settings, and that Row Level Security policies allow the operations you're
  using.
