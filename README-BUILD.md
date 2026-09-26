# Dollfind (Flutter) — one codebase, real builds via GitHub

## The honest starting point

This session runs in a sandboxed Linux container with no macOS anywhere (Apple
does not license Xcode to run outside its own hardware, cloud or not) and with
this container's own network policy blocking downloads from Google's Android
SDK servers (`dl.google.com` is explicitly denied by the sandbox's egress
policy). That means **no tool running here can compile a real, installable
`.apk` or `.ipa`** — not this one, not any other AI coding tool working under
the same kind of constraint.

What *is* true: the code in this folder is a complete, working Flutter app —
same language, same structure `flutter create` would produce, nothing
hand-waved. The only missing step is the compile itself, and GitHub will do
that step for free the moment this is pushed there, using its own Linux *and*
macOS runners, which have full, unrestricted internet access. No PC or Mac
required on your end for that part.

## What changed from the native-Android version

The earlier "Claudes innputt" review (see the parent Drive folder) reworked
the *existing* native-Java Android app's marketplace links to be global. This
folder goes further, per your later request: it's a full rewrite as a single
Flutter/Dart codebase that targets **both** Android and iOS from the same
source, and the marketplace search panel is global-first rather than
Norway-first — see `lib/services/marketplace_links.dart`. FINN.no is still
included (as one clearly-labelled regional option, plus a couple of others:
UK, Germany, Japan, Australia), just no longer prioritised by default.

The old native `MarketplaceLinks.java` in the parent folder is superseded by
this Dart version and hasn't been touched further — there's no value in
maintaining the same logic twice once the project has one real codebase.
`backend/value_research.py`'s Gemini-prompt addendum is still relevant (the
identification service itself is unchanged), so keep using that backend if
you activate online identification; its own link-builder function has been
updated to match the same global list for consistency, though the app now
builds links on-device rather than asking the server for them.

## What's implemented

- Bilingual UI (Norwegian Bokmål / English), switchable in Settings.
- Photo capture (camera or gallery), up to three photos per item.
- Full offline archive: create, edit, search, delete; wish-list flag;
  owner-verified flag; JSON export (see "What's deferred" below for import's
  current limit).
- The **global** "Find value & where it's sold" panel: eBay (sold and
  active), Ruby Lane, Etsy, Catawiki, LiveAuctioneers, WorthPoint, Mercari,
  Vinted, Facebook Marketplace, Google web search, Google Images (manual
  reverse-image search), plus regional options (Norway, UK, Germany, Japan,
  Australia) always available further down the list.
- The offline, zero-network Barbie/doll identification cheat-sheet, bundled
  as an asset so it works even with no server ever configured.
- Optional AI identification against your own private backend (unchanged
  `backend/server.py` from the original project) — only fires after an
  explicit confirmation dialog, exactly like the original design, and never
  sends the collection notes field.

## What's deferred (said plainly, not glossed over)

- **Backup import** isn't wired into the Settings screen yet (export is).
  Add a file picker (`file_picker` package) calling
  `ArchiveStore.importJson()`, which is already written and tested logically
  — it's a UI hookup away.
- **Photo-bundled export** (zipping the JSON plus the actual photo files
  into one portable archive, like the original native app did) is not yet
  implemented, to keep the dependency list minimal for this first
  cross-platform pass. The `archive` package (pure Dart, no native
  dependencies) is the natural way to add it.
- **Reverse image search** is still deliberately not automated — same
  reasoning as before: it needs a paid vision/image-search API key and adds
  real cost and privacy surface for a personal project. The Google Images
  manual-search link remains the pragmatic middle ground.
- **A real signed iOS `.ipa`** needs your own Apple Developer Program
  membership (there is no way around this — Apple requires it for every iOS
  app, from every developer, including Apple's own AI tools). See below for
  exactly what to add once you have one.

## Getting real builds: push this to GitHub

If you are importing the project from an iPhone, create
`.github/workflows/import.yml` from the separately supplied
`Dollfind_import_mobile.yml`, then upload `Dollfind_repo_ready.zip` to the root
of the repository. The import workflow unpacks the source and performs both
builds. It omits the bundled `build.yml` from the resulting commit because the
GitHub Actions token cannot add another workflow file; `import.yml` remains the
build workflow. Later builds can be started with **Run workflow** in Actions.

The instructions below describe a conventional push from a Git checkout.

1. Create a new (private is fine) GitHub repository.
2. Push this folder's contents to it (`git init && git add . && git commit -m
   "Dollfind Flutter" && git remote add origin <your repo URL> && git push -u
   origin main`).
3. Open the repo's **Actions** tab. The `Build Dollfind (Android + iOS)`
   workflow runs automatically on every push, or click "Run workflow" to
   trigger it by hand.
4. When it finishes (a few minutes), open the run and download the
   artifacts at the bottom of the page:
   - `dollfind-android-apk` — a real, installable `.apk`. Copy it to an
     Android phone and open it (Android will ask permission to install from
     that source once); it's debug-signed, same trust model the original
     native preview APK used.
   - `dollfind-ios-unsigned-app` — a `Runner.app` built and verified by
     Apple's own compiler on a macOS runner. It **will not install on a
     physical iPhone** without your own signing identity (see next
     section), but this artifact proves the app builds cleanly end to end
     on Apple's toolchain.

No Mac, no PC, no Xcode install needed for either of those — GitHub's
runners did the compiling.

## Getting a real, installable iPhone build

This is the one part that genuinely cannot be done without you personally
holding an Apple Developer account — not because of any tool's limitation,
but because Apple's code-signing requirement is enforced by iOS itself. Once
you have (or regain access to) an Apple ID enrolled in the free or paid
Apple Developer Program:

1. In Xcode (on any Mac, even briefly borrowed) open `ios/Runner.xcworkspace`
   after a local `flutter build ios` once, sign in with your Apple ID under
   Signing & Capabilities, and let Xcode generate a certificate + provisioning
   profile automatically — this only needs doing once.
2. Export that certificate as a `.p12` file and note the provisioning
   profile's UUID.
3. Add them as encrypted GitHub Actions secrets on the repo (Settings →
   Secrets and variables → Actions): typically
   `IOS_CERTIFICATE_P12`, `IOS_CERTIFICATE_PASSWORD`, and
   `IOS_PROVISIONING_PROFILE`.
4. Extend the `ios` job in `.github/workflows/build.yml` to import them
   (`apple-actions/import-codesign-certs`) and run
   `flutter build ipa` instead of `--no-codesign` once they're present.

This is standard, well-documented GitHub Actions practice for Flutter/iOS —
not something specific to this project — and it's the only step in this
whole pipeline that has to involve a Mac at all, and only once.

## Project layout

```
lib/
  main.dart                 – app entry point, theme
  l10n/strings.dart          – NO/EN strings (plain Dart, no code-gen needed)
  models/item.dart           – the catalogued-item data model
  models/marketplace_link.dart
  services/archive_store.dart        – local JSON archive, atomic writes
  services/marketplace_links.dart    – the global link builder (see above)
  services/identification_service.dart – calls your optional private backend
  services/settings_store.dart       – SharedPreferences wrapper
  screens/home_screen.dart
  screens/item_edit_screen.dart
  screens/item_detail_screen.dart
  screens/settings_screen.dart
  widgets/marketplace_panel.dart
  widgets/identification_tips_sheet.dart
assets/identification_tips_dolls.md
.github/workflows/build.yml
```

`android/` and `ios/` are deliberately **not** committed here — the CI
workflow generates them fresh from the current stable Flutter release on
every run (`flutter create`), then patches in the two things a fresh
template doesn't have yet: the camera/internet permissions on Android, and
the camera/photo-library privacy strings iOS requires. That keeps this repo
small and always compatible with whatever Flutter version GitHub's runner
has, rather than pinning a snapshot that could rot.

If you'd rather have `android/` and `ios/` committed as ordinary files (for
example, to open the project directly in Android Studio or Xcode without
touching CI first), run `flutter create --platforms=android,ios --org
no.mortil --project-name dollfind .` once inside this folder on any machine
with Flutter installed, then apply the same two small patches described in
`build.yml`, and commit the result.
