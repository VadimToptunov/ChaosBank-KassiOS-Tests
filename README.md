# ChaosBank ⨯ KassiOS

Hand-written **[KassiOS](https://github.com/VadimToptunov/KassiOS)** UI tests that
drive **[ChaosBank](https://github.com/VadimToptunov/ChaosBank-iOS)** — the
deliberately-buggy iOS neobank/broker built as a practice range for mobile
QA/SDET automation.

This repo is the dogfooding ground for KassiOS: a real, awkward app (a WKWebView
login, a live market feed, multi-screen money flows) exercised through KassiOS's
screen-object DSL, implicit waits, and flaky-safety.

> **New to the framework?** Start at
> **[KassiOS](https://github.com/VadimToptunov/KassiOS)** — this repo is its
> real-world example suite.

## What a KassiOS test looks like

A real test from this repo — the transfer happy path. No `waitForExistence`, no
`sleep`, and the deep assertions catch a *transient* success toast (it lives
~1.4s) that a presence-only check would miss:

```swift
func test_transfer_happyPath_completes() {
    launchUnlocked()
    onScreen(HomeScreen.self) { $0.transferAction.tap() }
    onScreen(TransferScreen.self) { transfer in
        transfer.recipientField.typeText("Alex")
        transfer.amountField.typeText("100")
        transfer.continueButton.tap()
        transfer.confirmButton.tap()
        transfer.successToast.assertAppears(within: 2)          // catches successToastMissing
        transfer.confirmButton.within(timeout: 20).waitUntilGone()
    }
}
```

Its screen object is a plain page object
([`UITests/Screens/TransferScreen.swift`](UITests/Screens/TransferScreen.swift)):

```swift
final class TransferScreen: CBScreen {
    lazy var recipientField = textField("transfer.recipientField")
    lazy var amountField    = textField("transfer.amountField")
    lazy var continueButton = button("transfer.continueButton")
    lazy var successToast   = anyEl("transfer.successToast")
    override var onLoad: [KassElement] { [recipientField] }
}
```

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

- **Check every defect at once with `kassios-mutants`.** Each test that pins a
  defect says so in its doc comment (`/// Catches \`successToastMissing\`.`).
  `tools/gen_mutants.py` turns those lines into `mutants.json`, and KassiOS's
  `kassios-mutants` runs each defect's tests with it injected and reports any
  that stay green:

  ```bash
  xcodebuild build-for-testing -project ChaosBankKassiOS.xcodeproj \
    -scheme ChaosBankKassiOSUITests -destination 'platform=iOS Simulator,name=iPhone 17' \
    -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO
  swift build -c release --package-path vendor/KassiOS --product kassios-mutants
  vendor/KassiOS/.build/release/kassios-mutants mutants.json --clean --parallel 3
  ```

  `--parallel 3` runs three defects at once, each on a clone of the simulator.
  `KASS_DEST=<destination> python3 tools/gen_mutants.py > local.json` targets
  another simulator. CI fails if `mutants.json` is out of date with the tests,
  and runs the defects with `--parallel 2`. Last local run (KassiOS 1.9.0,
  iPhone 17, iOS 27): 59 of 59 defects killed in about 28 minutes on 3
  simulators, against about 70 minutes one at a time.

- **Run the same suite against ChaosBank-Server.** `TEST_RUNNER_CB_BACKEND=<url>`
  launches the app with `-ChaosBankBackend <url>`, so the tests hit
  [ChaosBank-Server](https://github.com/VadimToptunov/ChaosBank-Server) over HTTP
  instead of the embedded mock (`docker compose up` there first):

  ```bash
  TEST_RUNNER_CB_BACKEND=http://localhost:8080 \
  xcodebuild test -project ChaosBankKassiOS.xcodeproj -scheme ChaosBankKassiOSUITests \
    -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
  ```

  Needs a ChaosBank build with the server backend. Verified: 64/64 green against a
  local server.

  The same is verified for the deepened Transfer/Exchange/Transactions
  assertions below: `zeroAmountAccepted`, `successToastMissing`,
  `paginationDup`, `filterLeaksCategory`, `roundingDrift`, and
  `exchangeDoubleSubmit` each flip exactly their own test red — these were
  previously presence-only checks that missed all six.

## Coverage

Each value, localization, concurrency and security test was checked the mutation-testing way: green on `clean`, red under exactly its own ChaosBank defect, run one defect at a time. Of the 23 money defects, 21 are killed; the other two (`detailChangeWrongBase`, `pnlPercentAbsOnly`) can't be told apart from the correct code on the simulated feed and the seeded portfolio, which is up overall.


| Area | Tests |
| --- | --- |
| **Auth** | boot-unlocked affordance → home; the full ladder end to end — fresh launch → WKWebView web login → OTP `424242` → 6-digit passcode → home |
| **Home** | balance + quick actions; per-currency accounts |
| **Markets** | watchlist asset rows (AAPL/NVDA/BTC); open an asset → detail |
| **Transfer** | form → confirm → success toast (catches `successToastMissing`); zero amount disables Continue (catches `zeroAmountAccepted`) |
| **Exchange** | sheet → enter amount → execute → success toast; quote breakdown; credited amount matches the displayed "you get" (catches `roundingDrift`); a rapid double-tap on Execute exchanges only once (catches `exchangeDoubleSubmit`) |
| **Portfolio** | total value + P&L + holdings list |
| **Card** | freeze → FROZEN badge (catches `cardToggleInvert`); CVV hidden on the face (catches `cardCvvVisible`) |
| **Transactions** | open from "See all activity" → list, count, search; loading the full history has no duplicate rows (catches `paginationDup`); the "Money in" filter shows only money-in rows (catches `filterLeaksCategory`) |
| **Order** | Buy button labelled "Buy" (catches `wrongA11yLabel`); qty 0 disables Review (catches `limitValidation`); place → "Order filled" (catches `orderStuckPending`) |
| **Loans** | Card → "Explore a loan" → APR / monthly / total |
| **Value checks** | Home total = sum of accounts (FX), today's change; transfer debits exactly the amount from EUR and previews "balance after"; exchange moves money between the right accounts; loan payment matches the advertised APR; asset detail agrees with the market row (day open from one snapshot); order estimated total (market and limit); portfolio total = sum of holdings, holding valued at market price, P&L % vs cost basis, TSLA loss shown as a loss |
| **Localization** | "1,000.50" parses as a thousand; USD total shows "$"; prices keep cents; search ignores surrounding spaces; de-DE grouping and symbol placement |
| **Concurrency** | double-tap Confirm debits once; double-tap Place buys once; order reference price stays at the captured price; Sync playground loses no updates |
| **Security** | PAN masked except the last four; PIN stays masked; virtual card doesn't reuse the real number; wrong OTP rejected; three wrong OTPs lock the step; a deep link doesn't skip the gate; the session token lands in the Keychain |

Screen objects live in `UITests/Screens/`, tests in `UITests/Tests/`, and the
launch helpers (over ChaosBank's `-ChaosBankStartUnlocked` / `-ChaosBankTab` /
`-ChaosBankProfile` surface) in `UITests/Support/`.
