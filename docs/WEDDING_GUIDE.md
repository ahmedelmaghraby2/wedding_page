# Wedding Sites — operator guide

One Flutter codebase serves **every couple's** invitation website. Each wedding is
described by one JSON file (`config/wedding_<id>.json`), one asset folder
(`assets/weddings/<id>/`), plus two tiny registration lines (a `pubspec.yaml`
asset entry and a `firebase.json` hosting entry for deployment).

- Demo/current wedding: `config/wedding_config.json` → `assets/weddings/ahmed-aya/`
  (this is the live Ahmed & Aya site).
- `config/wedding_demo.json` is an **exemplar placeholder** ("Omar & Layla"). It is
  never deployed and exists so tests/tooling always have a second schema sample.

---

## Architecture in one picture

```
config/wedding_<id>.json      Single source of truth (names, date, venue, texts, assets)
assets/weddings/<id>/        hero.jpg, song.mp3, story-1.jpg, ...
lib/core/config/
  wedding_config.dart        Typed, validated WeddingConfig model (pure Dart)
  config_loader.dart         Loads the config asset chosen via --dart-define
  wedding_scope.dart         InheritedWidget exposing context.wedding everywhere
web/index.html               og: meta (title/description/image) per site
firebase.json                hosting entry (add a target to isolate per site)
tool/validate_config.dart    CLI: validates config + referenced assets
```

### Select a wedding at build time

The app always bundles **every** config + every wedding's assets, then picks one:

```
flutter build web --release --dart-define=WEDDING_CONFIG=config/wedding_config.json
```

`config_loader.dart` defaults to `config/wedding_config.json` when the define is
omitted, so plain `flutter build web` keeps working unchanged.

---

## How to onboard a brand-new wedding (checklist)

1. **Copy the folder + config**
   ```
   xcopy /s /i assets\weddings\ahmed-aya assets\weddings\<id>
   copy config\wedding_config.json config\wedding_<id>.json
   ```
2. **Replace the media** in `assets/weddings/<id>/`:
   - `hero.jpg` — full-bleed hero background (also the source for the site icon)
   - `song.mp3` — music player (any format audioplayers supports)
   - `story-1.jpg`, `story-2.jpg`, ... — story collage + gallery (any names)
   - Keep files **flat** inside the folder. Flutter does **not** recurse asset
     directories, so each new wedding also needs **one line** in `pubspec.yaml`:
     ```yaml
     flutter:
       assets:
         - config/
         - assets/weddings/ahmed-aya/
         - assets/weddings/<new-id>/   # add this line for the new wedding
     ```
   - Regenerate the favicon + PWA icons from the new hero photo:
     ```
     powershell -ExecutionPolicy Bypass -File tool/generate_icons.ps1 -Hero "assets/weddings/<id>/hero.jpg"
     ```
     This overwrites `web/favicon.png` and the icons under `web/icons/` (192/512,
     maskable, apple-touch). `index.html` and `manifest.json` keep referencing
     the same filenames, so no other icon edits are needed.
   - **Trim the payload** (recommended, keeps the bundle small):
     - Music: re-encode to 128 kbps stereo — plenty for background playback.
       Requires [ffmpeg](https://ffmpeg.org):
       ```
       ffmpeg -i song.mp3 -c:a libmp3lame -b:a 128k -ac 2 -ar 44100 -map_metadata 0 song.optimized.mp3
       ```
       then replace `song.mp3` with `song.optimized.mp3`.
     - Fonts: the bundled fonts are already subset once for the whole project.
       Re-run after installing fontTools (`python -m pip install fonttools brotli`):
       ```
       python tool/subset_fonts.py
       ```
       If a couple's copy needs a script that isn't kept yet (e.g. Cyrillic),
       add its ranges at the top of `tool/subset_fonts.py` first.
3. **Fill `config/wedding_<id>.json`** — every field is required. `weddingId` must
   match `assets/weddings/<id>`, and must be lowercase alphanumeric with dashes.
   `title`, `caption`, `groom`, `bride` and `developer` are bilingual and take a
   `{"en": ..., "ar": ...}` map; the Arabic value is optional and falls back to
   the English one. For backward compatibility `groom`, `bride` and `developer`
   also accept a plain string, which is treated as the English value (see the
   migration note below).
4. **Validate**
   ```
   dart run tool/validate_config.dart config/wedding_<id>.json
   ```
   Fix any reported issue (bad date, missing file, invalid URL, ...).
5. **Build + smoke test locally**
   ```
   flutter analyze
   flutter test
   flutter build web --release --dart-define=WEDDING_CONFIG=config/wedding_<id>.json
   ```
   Also update the og meta in `web/index.html` (title, description, image) for the
   couple so link previews look right.
6. **(Optional) Isolate deployment with a hosting target**
   The current site deploys through the Firebase project's default hosting site.
   To give a new couple an independent URL instead:
   - Create the site once (admin only): `firebase hosting:sites:create wedding-<id>`
   - Register the target:
     ```
     firebase target:apply hosting wedding-<id> wedding-<id>
     ```
   - Convert the `hosting` object in `firebase.json` into an array and add a
     block for the new couple:
     ```json
     {
       "target": "wedding-<id>",
       "site": "wedding-<id>",
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [{ "source": "**", "destination": "/index.html" }]
     }
     ```
7. **Deploy only that couple's site**
   ```
   firebase deploy --only hosting:wedding-<id>
   ```

---

## The current site's special case

`ahmed-aya` keeps its **existing URL** by deploying to the **default** project
`soltan-aya`:

- `.firebaserc` maps `"default": "soltan-aya"` (no hosting target registered).
- `firebase.json` has a single `hosting` object (`public: build/web`, no target).
- Deploy with `firebase deploy --only hosting`.

New couples can keep using the default project or add their own `wedding-<id>`
target via the checklist above.

---

## Comments & the Access Code feature

Comments live in Firestore (`wedding_comments`). Every comment must now carry a
`weddingId` so one Firestore database can safely serve every couple's website.

- The Flutter app scopes all reads/writes to the active `weddingId` through
  `FirebaseCommentsRepository` (see `lib/features/wedding/data/`). No Firestore
  composite index is needed — results are filtered then sorted in memory.
- `firestore.rules` `isValidComment` now requires `weddingId` and treats it as
  immutable on edit. The `comment_owners` collection is unchanged.
- **One-time data migration (already applied in the console for ahmed-aya):** for
  every document in `wedding_comments` (and the `comment_owners` docs with the
  same id), add the field:
  - `weddingId` = `ahmed-aya`
  You can do this in one pass by editing a single doc and selecting
  "apply to all documents `wedding_comments`". If you prefer code instead of the
  console, a one-off `dart run` script under `tool/` with admin credentials can do
  the same. `comment_owners` documents do **not** need a weddingId.

> The previously published build (before this change) still renders fine because
> it reads comments without filtering; new features always filter.

---

## Conventions & gotchas

- **Do not** add wedding-specific text to `lib/core/l10n/app_en.arb`/`app_ar.arb`.
  All per-couple copy lives in the config's `title`, `caption`, `story`,
  `event.display.*`. The ARB files only hold UI chrome ("Wedding Details", "Open
  Invitation", ...).
- **Locale fallback:** any missing Arabic string falls back to English, never to a
  blank space. This now also applies to `groom`, `bride` and `developer`; their
  Arabic name/value displays when the guest views the site in Arabic.
- **Bilingual names & credit (migration):** `groom`, `bride` and `developer` used
  to be plain strings and are now localized objects. Existing configs keep
  working unchanged — a plain string is read as the English value and the Arabic
  locale falls back to it. To show Arabic, convert each field to a map, e.g.
  `"groom": { "en": "Ahmed", "ar": "أحمد" }`. The `monogramLabel` badge and the
  fallback page title always use the English values.
- **Optional sections:** set `showCountdown: false` / `showComments: false` to
  remove those sections entirely (nav links disappear too). Story is shown only
  when `story` has at least one paragraph.
- **pubspec assets:** Flutter bundles only files **directly** inside a declared
  asset directory — it does not recurse subfolders. Each wedding therefore needs
  its own `- assets/weddings/<id>/` entry (see step 2).
- Working directory matters: `dart run tool/validate_config.dart` is relative to
  the project root, and tests read `config/` from the project root.