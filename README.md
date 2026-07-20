# ChaosBank ⨯ KassiOS

Hand-written **[KassiOS](https://github.com/VadimToptunov/KassiOS)** UI tests that
drive **[ChaosBank](https://github.com/VadimToptunov/ChaosBank-iOS)** — the
deliberately-buggy iOS neobank/broker built as a practice range for mobile
QA/SDET automation.

This repo is the dogfooding ground for KassiOS: a real, awkward app (a WKWebView
login, a live market feed, multi-screen money flows) exercised through KassiOS's
screen-object DSL, implicit waits, and flaky-safety.

## How it fits together

Both apps are **git submodules**; a generator wires them into one Xcode project:

```
vendor/ChaosBank/   → ChaosBank-iOS  (the app under test)
vendor/KassiOS/     → KassiOS         (the framework, compiled into the test target)
gen.rb              → ChaosBankKassiOS.xcodeproj (ChaosBank app + a UI-test target)
UITests/            → the KassiOS screen objects and tests
```

`gen.rb` builds ChaosBank from source on the **clean** profile and adds a UI-test
target that compiles the KassiOS sources directly (so there is no `import
KassiOS`, matching KassiOS's own integration setup).

## Run it

```bash
git submodule update --init --recursive
ruby gen.rb                       # needs the `xcodeproj` gem: gem install xcodeproj
xcodebuild test \
  -project ChaosBankKassiOS.xcodeproj \
  -scheme ChaosBankKassiOSUITests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO
```

CI runs exactly this on every push/PR (`.github/workflows/ci.yml`).

## The dogfooding contract

ChaosBank's **locators never move** — a defect changes behaviour or values, never
the accessibility-identifier surface — so these screen objects stay stable across
builds. The suite asserts *correct* behaviour, so:

- On the **`clean`** profile (the default here) it is **green**.
- Flip a defect and the same flow goes **red**, proving the test catches it. ChaosBank
  selects defects at launch, so no rebuild is needed:

  ```bash
  # e.g. run the transfer test against a validation-defect build
  xcodebuild test … -only-testing:ChaosBankKassiOSUITests/TransferTests \
    -destination '…' CHAOSBANK_PROFILE=validation
  ```

  (Per-test launch arguments like `-ChaosBankProfile <id>` / `-ChaosBankDefects
  <id,…>` are documented in ChaosBank's README.)

## Coverage

| Area | Tests |
| --- | --- |
| **Auth** | the boot-unlocked affordance → home |
| **Home** | balance + quick actions; per-currency accounts |
| **Markets** | watchlist asset rows (AAPL/NVDA/BTC); open an asset → detail |
| **Transfer** | form → confirm → success toast |

> Follow-up: the full auth ladder (the deliberately-hostile WKWebView login →
> OTP `424242` → passcode) only appears on re-lock, not a fresh launch, so it
> needs its own focused test rather than blocking this suite.

Screen objects live in `UITests/Screens/`, tests in `UITests/Tests/`, and the
launch helpers (over ChaosBank's `-ChaosBankStartUnlocked` / `-ChaosBankTab` /
`-ChaosBankProfile` surface) in `UITests/Support/`.
