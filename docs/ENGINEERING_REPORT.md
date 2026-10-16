# Wedding invitation platform — engineering report

Audit, hardening and verification of the multi-couple Flutter Web invitation
platform. Companion to [`WEDDING_GUIDE.md`](WEDDING_GUIDE.md) (operator guide).

- Environment: Flutter **3.47.6** (stable) · Dart **3.13.5** · Windows · Chrome
- Verification: `flutter analyze` = **0 issues**, `flutter test` = **122 passed**,
  `flutter build web --release` succeeds.

---

## 1. Summary

The app was upgraded from a single-file demo into a layered, testable
architecture (domain / data / application / presentation) with Bloc state
management, then hardened for correctness, accessibility, weight and
maintainability. No production deploy, hosted data, or Firestore rules were
changed.

Delivered in five stages:

1. Layered architecture + Bloc/Cubit migration.
2. Correctness fixes (image fallbacks, countdown, reveal keys, gate guard, boot
   loader, docs reconciliation).
3. Asset optimization (font subsetting, audio re-encode).
4. Test expansion (widget tests for the wishes flow, header, form, item).
5. Cleanup + accessibility + static-analysis tightening, plus this report.

Firestore rules hardening was **requested, then explicitly skipped** by the
owner; `firestore.rules` is unchanged from `HEAD`.

---

## 2. Architecture (§2)

```
lib/
  core/
    config/     wedding_config.dart (typed+validated), config_loader.dart,
                wedding_scope.dart (InheritedWidget -> context.wedding)
    music/      music_controller.dart (single app-wide AudioPlayer)
    motion/     reveal.dart (FadeSlideIn, RevealOnScroll, prefersReducedMotion)
    theme/      app_colors.dart
  features/wedding/
    domain/         wedding_comment.dart, comment_failure.dart,
                    comments_repository.dart (port), comment_access_code.dart,
                    countdown.dart
    data/           firebase_comments_repository.dart, wedding_comment_mapper.dart
    application/    comments_cubit.dart, music_cubit.dart
    presentation/   wedding_invitation_page.dart, failure_message.dart,
                    sections/ (hero, details, countdown, story, wishes, closing)
  l10n/         app_en.arb / app_ar.arb + generated AppLocalizations
  widgets/      reusable, config-agnostic UI (header, form, item, states, gate)
tool/           validate_config.dart, subset_fonts.py, generate_icons.ps1
```

The domain layer contains **no** Firebase or Flutter types, so business logic is
unit-testable in isolation. The data layer is the only place that knows about
Firestore.

---

## 3. State management (§3)

- `CommentsCubit` owns the guest-wishes lifecycle: initial/live subscription,
  loading/empty/error/loaded, duplicate-submit guard, and a **generation counter**
  so a stale stream from a previous subscribe can never overwrite newer state.
- `MusicCubit` exposes `MusicController` as immutable state and owns the
  controller's lifetime (disposed exactly once on `close`).
- Widgets render state declaratively (`BlocBuilder`); localization stays in the
  presentation layer (`failure_message.dart`) so the application layer is
  locale-free.

---

## 4. Configuration reliability (§5)

- `WeddingConfig.fromJson` validates every required field and collects **all**
  issues (not just the first). `tool/validate_config.dart` runs the same
  validation plus asset-existence checks in CI/manual step.
- Bilingual fields (`title`, `caption`, `groom`, `bride`, `developer`) resolve
  per locale with English fallback; plain strings are accepted for backward
  compatibility.
- `weddingId` is constrained to lowercase alphanumeric + dashes and must match
  the asset folder; the active config is selected at build time via
  `--dart-define=WEDDING_CONFIG=...` (defaults to `config/wedding_config.json`).

---

## 5. Audio lifecycle (§6)

- Exactly one `AudioPlayer` is created (`MusicController`), shared app-wide,
  looped, and disposed once. A `_disposed` flag makes late async callbacks safe.
- The player is warmed up after first frame; the user's "Open Invitation"
  gesture calls `play()`, satisfying browser autoplay policy.
- Play/pause/mute failures are caught and surfaced as state, never crashing.

---

## 6. Error handling (§8)

- Invalid config → dedicated `ConfigErrorApp`; Firebase init failure is caught
  and logged (`debugPrint`), and the app still renders the invitation without
  comments.
- Domain `CommentFailure` values map to localized messages via
  `messageForFailure`; the wishes section renders loading/empty/error(retry)/
  loaded states.
- Hero/story images have `errorBuilder` fallbacks (gradient / solid colour) so a
  missing asset never leaves a broken image.

---

## 7. Firebase & security (§7) — findings

Collection layout: `wedding_comments` (public read, guestbook) + `comment_owners`
(access-code digests), both scoped by `weddingId`.

The access-code scheme was reviewed:

- The owner stores only `sha256(salt + code)`; the plaintext code never leaves
  the client. Editing/deleting requires a digest match, so a comment cannot be
  modified by guessing an id.
- The `salt` constant ships in the client bundle and is **not** a secret (it is
  only used to avoid trivially precomputable hashes). This is documented in
  `comment_access_code.dart`.

Residual risks (accepted, documentation only — rules untouched):

- **No auth by design**: the guestbook is publicly writable, so spam/abuse is
  possible (there is no rate limiting at the rules layer).
- An 8-character code space is strong enough against casual guessing but the
  digest is verifiable offline if an attacker can read `comment_owners`.

---

## 8. Accessibility, localization, responsive (§9)

- Localization is complete for the UI chrome (EN/AR with RTL). Per-couple copy
  lives in config, never in the ARB files.
- Reduced-motion is honoured: `prefersReducedMotion` short-circuits
  `FadeSlideIn`/`RevealOnScroll` and scroll animations.
- Layout is responsive across mobile/tablet/desktop breakpoints
  (`isMobile`, `isTablet`, max-content width, adaptive paddings).

### Accessibility verification (this pass, evidence-based)

Verified against real WCAG math (`test/a11y_test.dart`) and widget inspection;
several **genuine** defects were found and fixed:

1. **Contrast (WCAG 1.4.3).** Computed relative-luminance ratios showed the
   previous palette failed AA for small text:
   - `goldDeep` was `3.20–3.36:1` (fail) → darkened `#A8863F` → **`#8A6C2B`**
     (ivory 4.61, cream 4.85, white-on-gold 4.93).
   - `taupeLight` was `3.09–3.25:1` (fail) → darkened `#9A8B7C` → **`#7C6E60`**
     (ivory 4.62, cream 4.86); it is only used on ivory/cream.
   - `rose` failed 1.4.11 non-text (2.74:1) → `#C98B8B` → **`#BC7A7A`**
     (cream 3.33:1, ≥ 3:1).
   The tests assert the value, the surface it sits on, and the correct threshold
   (4.5:1 small text / 3:1 large text & non-text).
2. **Names/labels (WCAG 4.1.2).** `MusicButton` now exposes an explicit
   `Semantics(button: true, enabled:, label:)`. The mute `IconButton` only had a
   `Tooltip`, which sets a *tooltip*, not a semantic *label*; it is now wrapped
   in `Semantics(button: true, label: ...)`.
3. **Text scaling (WCAG 1.4.4), real overflow bugs fixed.** At 1.5× text scale
   two `RenderFlex` overflows existed and were corrected:
   - `widgets/comment_form.dart`: the generate/copy `Row` (with a `Spacer`)
     overflowed by ~317 px → replaced with `OverflowBar`.
   - `sections/closing_section.dart`: the footer `Row` overflowed by ~193 px →
     the label is now `Flexible`.
4. **Touch targets (WCAG 2.5.8).** Verified play/pause ≥ 44×44 and the mute
   `IconButton` ≥ 48×48.
5. Long single-token names and long bilingual couple names render without
   overflow.

### Responsive verification (follow-up pass, evidence-based)

A focused responsive audit reproduced the reported “blank section” symptom and
the layout overflows, and fixed their root causes:

1. **Tall sections stayed invisible (blank page stuck at `Opacity(0)`).**
   `core/motion/reveal.dart` gated the entrance on
   `info.visibleFraction >= 0.12` of the *child*. A section taller than ~8.3×
   the viewport (e.g. the wishes list with many comments) can never reach that
   fraction, so it never revealed while still occupying space — the page read as
   blank. The trigger now requires that fraction of the *smaller* of the child
   and the viewport, and a post-frame geometry check guarantees that content
   already on screen always reveals.
2. **Hero overflow.** `sections/hero_section.dart` used a fixed-height
   `Stack(fit: expand)`; long names and a 1.5× text scale overflowed it. It is
   now a `ConstrainedBox(minHeight:)` whose content determines the height.
3. **Invitation-gate overflow.** The centred `Column` overflowed on short
   (landscape) and 1.5× viewports; it is now centred *and* scrollable via
   `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight:)`.
4. **Header overflow.** The nav/brand row overflowed at tablet widths and under
   text scaling. The header now drops the nav, then the brand name, then the
   decorative monogram as the *unscaled* width shrinks, with the brand name
   ellipsizing as a final safety net.

Verified overflow-free across 320×568 … 1280×800, EN/AR, at 1.0× and 1.5× text
(`test/responsive_layout_test.dart`); the wishes list is exercised with 60
comments.

---

## 9. Testing (§10)

`flutter test` → **122 tests** (was 93). Coverage added across this engagement:

| File | Focus |
| --- | --- |
| `test/wishes_section_test.dart` | loading / empty / error+retry / loaded states of the wishes section, driven by a fake repository |
| `test/comment_form_test.dart` | required-field validation, length rules, access-code generation, successful submit, disabled-while-submitting state |
| `test/comment_item_test.dart` | name/message/initials rendering, guest fallback, edit/delete popup actions |
| `test/site_header_test.dart` | config-driven nav visibility, localized couple names (EN/AR), presence of the music control |
| `test/a11y_test.dart` | WCAG contrast assertions, semantic labels, touch-target sizes, 1.5× text-scale overflow, long-content rendering |
| `test/responsive_layout_test.dart` | tall-section reveal regression, page/header/gate overflow matrix (320→1280, EN/AR, 1.0×/1.5×), many-comment wishes list |
| `test/audio_sync_test.dart` | Cubit ↔ single `MusicController` sync, mute propagation, lone-cubit close, one-source-two-controls |
| `test/comment_flow_test.dart` | **integration-style** end-to-end flow: form → cubit → repository port → live list, plus invalid-submit blocking |

Existing coverage retained: config parsing/validation, countdown math, both
cubits, access-code rules, model mapping, and localization.

To make this testable, the guest-wishes UI was extracted from
`wedding_invitation_page.dart` into
`lib/features/wedding/presentation/sections/wishes_section.dart` (behaviour
unchanged); the shared `FakeCommentsRepository` now lives in
`test/support/fake_comments_repository.dart`.

### On integration tests

`test/comment_flow_test.dart` is an integration-style test that drives the real
widget tree + cubit + repository port (faked at the boundary) in-process. A
`integration_test/` suite targeting real Chrome was **not** added: it requires a
running `chromedriver`, and the full `WeddingInvitationPage` pulls in
`url_launcher` and the `audioplayers` platform plugin, neither of which is
available headless. The play/warm-up paths therefore remain **runtime-verified
only** (covered by the manual checklist, not by unit tests) — see §12.

---

## 10. Performance baseline (§11)

### Methodology (reproducible)

```
flutter build web --release --no-wasm-dry-run
# payload
Get-ChildItem build\web -Recurse -File | Measure-Object -Property Length -Sum
```

Serve locally for manual timing with `python -m http.server` from `build/web`.

### Results

| Artifact | Baseline | After | Δ |
| --- | --- | --- | --- |
| Source fonts (`assets/fonts`) | 2.80 MB | 1.91 MB | **−0.89 MB** |
| Song (`song.mp3`) | 7.62 MB (320 kbps) | 3.05 MB (128 kbps) | **−4.57 MB** |
| `build/web` total | 55.1 MB | 49.68 MB | **−5.42 MB** |
| `main.dart.js` | 5.43 MB | 5.44 MB | ~0 |

Breakdown of the current 49.68 MB:

- Renderer WASM (`canvaskit` + `skwasm` + `skwasm_heavy` + `wimp`) ≈ **18.8 MB**
  plus their `.js` shims and debug `.symbols` — inherent to Flutter Web, only one
  renderer is fetched at runtime.
- `main.dart.js` ≈ 5.44 MB.
- Wedding assets ≈ 3.56 MB (song 3.05 MB + four images).
- Fonts ≈ 1.87 MB (subset, variable axes preserved).
- `NOTICES` ≈ 1.31 MB.

### Limitations

- These numbers are **payload measurements, not load timing**. Lighthouse was
  attempted against a local `build/web` server (release, `--no-wasm-dry-run`)
  and **cannot score this app**: Flutter's CanvasKit renderer paints into a
  `<canvas>`, so Lighthouse finds no DOM LCP element and its Lantern trace engine
  aborts with `LanternError: NO_LCP` (even when the *performance* category is
  excluded). This is an inherent limitation of canvas-based Flutter Web, not an
  app defect. Field timing would need Chrome DevTools' Performance panel or RUM
  (e.g. `web-vitals`), plus noting gzip/brotli delivery on Firebase Hosting.
- The song is decodable/trimmable but was chosen by the owner to stay stereo at
  128 kbps; converting to mono or shortening the clip would cut it further.
- Removing the unused `flutter_emoji`/`cupertino_icons` dependencies did **not**
  shrink the bundle (they were already tree-shaken out of `main.dart.js`); the
  win is maintenance and supply-chain hygiene.

---

## 11. Static analysis & dependencies (§12, §13)

- `analysis_options.yaml` extends `flutter_lints` and now enables a conservative
  extra set (`always_declare_return_types`, `avoid_empty_else`,
  `unnecessary_overrides`, `use_super_parameters`) — 0 issues, no churn.
- Removed unused direct dependencies: `flutter_emoji` and `cupertino_icons`
  (verified no references in `lib/`/`tool/` and none in the compiled output). The
  build emits a benign "expected CupertinoIcons font" tree-shaker warning because
  the font family is registered globally; `main.dart.js` contains **zero**
  Cupertino references, so nothing renders incorrectly.
- No CI workflow exists in the repo; lint/test/build are currently manual.

---

## 12. Definition of done (§14) & residual risk

| Item | Status |
| --- | --- |
| Layered architecture | done |
| Bloc/Cubit state | done |
| Config validation + tooling | done |
| Audio lifecycle | done |
| Error handling (config/Firebase/comments) | done |
| Accessibility (contrast, semantic controls, text-scale overflow, touch targets) | done + verified |
| Bilingual + RTL + responsive | done (pre-existing, verified) |
| Tests (unit + widget + integration-style) | done (93) |
| Assets optimized | done |
| Static analysis clean | done |
| Firestore rules hardening | **skipped by owner** |

Residual items / recommendations:

1. Add a CI job running `flutter analyze`, `flutter test`, and a release build.
2. Capture load-timing evidence with Chrome DevTools/RUM instead of Lighthouse
   (Lighthouse cannot score canvas-rendered Flutter Web; see §10).
3. Run the Firestore rules against the emulator at runtime (the earlier harness
   is stale; see below).
4. If guestbook abuse becomes a concern, revisit Firestore rules (rate limiting
   or an App Check gate) — deliberately out of scope here.

### Explicitly unverified (honest gaps)

- **No load-timing (Lighthouse attempted).** §10 numbers are payload sizes.
  Lighthouse was run and cannot score the app (`NO_LCP` on the canvas renderer);
  see §10.
- **No runtime Firestore-emulator run.** Rules were only reasoned about by
  inspection; a prior-session emulator harness is stale and its "create" case is
  unreliable, so it was not used as evidence. `firestore.rules` is unchanged.
- **Audio play/pause/mute** were verified via controller/Cubit logic and by the
  build, but the `audioplayers` plugin path is not exercised by unit tests
  (needs a real platform/Chrome).
