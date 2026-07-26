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

- **Re-run the whole suite against a defect build — no test edits.** `launchUnlocked`
  forwards `CB_INJECT_DEFECTS` / `CB_INJECT_PROFILE` from the runner environment,
  which Xcode populates from `TEST_RUNNER_`-prefixed variables. So the clean-pass
  flows can be flipped red in one command:

  ```bash
  TEST_RUNNER_CB_INJECT_DEFECTS=wrongA11yLabel,cardToggleInvert,cardCvvVisible \
  xcodebuild test -project ChaosBankKassiOS.xcodeproj -scheme ChaosBankKassiOSUITests \
    -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
  ```

  Verified: the Order and Card tests go red under exactly their defects
  (`wrongA11yLabel`, `limitValidation`, `orderStuckPending`, `cardToggleInvert`,
  `cardCvvVisible`) — the dogfooding contract, proven end to end.

## Coverage

| Area | Tests |
| --- | --- |
| **Auth** | boot-unlocked affordance → home; the full ladder end to end — fresh launch → WKWebView web login → OTP `424242` → 6-digit passcode → home |
| **Home** | balance + quick actions; per-currency accounts |
| **Markets** | watchlist asset rows (AAPL/NVDA/BTC); open an asset → detail |
| **Transfer** | form → confirm → success toast |
| **Exchange** | sheet → enter amount → execute → success toast; quote breakdown |
| **Portfolio** | total value + P&L + holdings list |
| **Card** | freeze → FROZEN badge (catches `cardToggleInvert`); CVV hidden on the face (catches `cardCvvVisible`) |
| **Transactions** | open from "See all activity" → list, count, search |
| **Order** | Buy button labelled "Buy" (catches `wrongA11yLabel`); qty 0 disables Review (catches `limitValidation`); place → "Order filled" (catches `orderStuckPending`) |
| **Loans** | Card → "Explore a loan" → APR / monthly / total |

Screen objects live in `UITests/Screens/`, tests in `UITests/Tests/`, and the
launch helpers (over ChaosBank's `-ChaosBankStartUnlocked` / `-ChaosBankTab` /
`-ChaosBankProfile` surface) in `UITests/Support/`.
