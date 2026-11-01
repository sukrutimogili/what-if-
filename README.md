# What If? ✨

A little Flutter app for curious minds. Ask "what if?" and see where your mind wanders.

1,000 prompts across 5 categories, a daily challenge, and a private journal for your answers.

## What you can do

- **Discover:** a featured prompt, today's daily challenge, and category shortcuts
- **Explore:** browse each category 10 prompts at a time, or search all prompts
- **Surprise me:** a random prompt from the whole collection, any time
- **Saved:** bookmark the prompts you love
- **My Journey:** write responses and keep them in a local journal

Works on phones, tablets and desktop. The layout adapts to the screen size.

## Run it

```bash
flutter pub get
flutter run -d linux
```

First time on Linux? Install the build tools once:

```bash
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsqlite3-dev
```

Before sharing changes:

```bash
flutter analyze
flutter test test/prompt_batcher_test.dart
```


## Under the hood

| Folder | What's inside |
| --- | --- |
| `lib/screens/` | Discover, Explore, Surprise, Saved, Journey and detail screens |
| `lib/widgets/` | Reusable pieces such as prompt tiles, pill buttons and icons |
| `lib/state/` | App state: bookmarks, journal entries, current tab |
| `lib/services/` | Prompt loading, bookmarks (shared_preferences), journal (SQLite) |
| `assets/data/` | `what_if_prompts.json`, the prompt collection |

Your saved prompts and responses stay on your device.
