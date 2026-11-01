# What If? – A Creative Prompt Generator

Flutter app (mobile, tablet, laptop/desktop) using the bundled
`assets/data/what_if_prompts.json` (1,000 prompts, 5 categories).

## Ubuntu setup

```bash
# 1. System packages for Linux desktop builds + SQLite
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsqlite3-dev

# 2. Check Flutter / Dart
flutter --version && dart --version
flutter doctor

# 3. From the folder that contains this README: generate the platform folders
#    (linux/, android/, ...). Existing lib/, pubspec.yaml and assets are kept.
flutter create --platforms=linux,android .

# 4. Dependencies, checks, run
flutter pub get
flutter analyze
flutter test
flutter run -d linux
```

If `flutter` is not found, install it first:
https://docs.flutter.dev/get-started/install/linux

## Trying different screen sizes

Run on Linux and drag the window edge:

| Width        | Layout                                             |
|--------------|----------------------------------------------------|
| < 700 px     | Phone: bottom navigation pill, single column       |
| 700–1100 px  | Tablet: icon sidebar, 2-column lists               |
| ≥ 1100 px    | Laptop: labelled sidebar, centred content, 3 cols  |

Phone emulator: `flutter emulators --launch <id>` then `flutter run`.

## Where things are stored

* Bookmarks: SharedPreferences (key `saved_prompt_ids`)
* Responses: SQLite file `what_if_journal.db` in the app support directory
* Prompts: read-only JSON asset, loaded once at start-up
# what-if-
# what-if-
