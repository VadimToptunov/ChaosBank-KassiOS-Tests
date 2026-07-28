import XCTest

final class ExchangeTests: CBTestCase {

    /// The exchange happy path: open the sheet, enter an amount, execute →
    /// success toast. Green on `clean`; flips red under a defect that breaks the
    /// execution outcome (e.g. `exchangeDoubleSubmit`, `timeoutAsSuccess`).
    func test_exchange_happyPath_showsSuccess() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.exchangeAction.tap() }
        onScreen(ExchangeScreen.self) { ex in
            ex.amountField.typeText("100")
            ex.executeButton.tap()
            // The toast is transient (~1.4s); the sheet auto-dismisses on success.
            // Assert that persistent outcome rather than racing the toast.
            ex.executeButton.within(timeout: 20).waitUntilGone()
        }
    }

    /// The quote breakdown (rate, fee, "you get") renders — the surface the
    /// money-math defects (`roundingDrift`, `exchangeFeeNotApplied`) act on.
    func test_exchange_showsQuoteBreakdown() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.exchangeAction.tap() }
        onScreen(ExchangeScreen.self) { ex in
            ex.rate.assertPresent()
            ex.fee.assertPresent()
            ex.youGet.assertPresent()
        }
    }

    /// The amount actually credited to history must equal the displayed "you
    /// get" — not merely close in spirit. `roundingDrift` routes the credited
    /// value through `Double`, drifting it away from the (correct, `Decimal`)
    /// displayed quote; `exchangeFeeNotApplied` credits the pre-fee gross
    /// instead. Both surface here as the stored amount diverging from the quote.
    ///
    /// `25` is deliberately not round-trip-safe: at EUR→USD's fixed 1.08 rate
    /// and 0.5% fee, the exact result lands on a rounding tie (26.865), where
    /// `roundingDrift`'s `Double` routing tips the last cent — a generic amount
    /// like `100` lands away from any tie and the sub-cent drift disappears
    /// once both paths round to display precision, so the defect goes unseen.
    func test_exchange_creditedAmount_matchesDisplayedYouGet() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.exchangeAction.tap() }
        var youGet: Double = 0
        onScreen(ExchangeScreen.self) { ex in
            ex.amountField.typeText("25")
            youGet = ex.youGet.readNumber() ?? -1
            ex.executeButton.tap()
            ex.executeButton.within(timeout: 20).waitUntilGone()
        }
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            // The just-executed exchange is inserted at the head of history, so
            // its signed amount is the first row rendered. Half a cent is well
            // below the smallest real (1-cent) discrepancy this can surface.
            tx.amounts.first.assertValue(closeTo: youGet, tolerance: 0.005)
        }
    }

    /// Execute must be idempotent: a rapid double-tap should still exchange
    /// exactly once. `exchangeDoubleSubmit` drops the re-entrancy guard, so a
    /// double-tap posts two exchanges — caught here as two new history rows
    /// instead of one, not just "the sheet eventually closed".
    ///
    /// Two independent taps only race the in-flight guard if the second lands
    /// before the first request completes — the mock backend's default
    /// ~120ms latency is narrower than a UI test's own tap-to-tap gap (each
    /// synthesized tap alone costs tens of ms), so the two taps would land
    /// sequentially rather than overlapping, and this couldn't tell "double
    /// submit" from "two deliberate, back-to-back, individually-valid
    /// exchanges" (also 2 rows, but not a bug). The dev menu's "Slow" network
    /// condition (see `NetworkCondition`, not a defect) widens that window to
    /// 3s, comfortably past any UI-test tap gap, making the race reliable in
    /// both directions: guarded → one row; unguarded → two.
    /// `XCUIElement.doubleTap()` (a single system gesture) can't stand in for
    /// this either — the button's tap-gesture recognizer fires its action
    /// once per double-tap, so it can't race itself.
    func test_exchange_rapidDoubleTapExecute_exchangesOnlyOnce() {
        launchUnlocked()
        // Read the baseline count before touching the network condition —
        // once "Slow" is on, a fresh Transactions load would otherwise still
        // be showing its interim "0 transactions" when read.
        var countBefore: Double = 0
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            countBefore = tx.count.readNumber() ?? 0
        }
        onScreen(TabBar.self) { $0.home.tap() }
        onScreen(HomeScreen.self) { $0.buildBadge.longPress(forDuration: 0.6) }
        onScreen(DevMenuScreen.self) { dev in
            dev.networkCondition("Slow").tap()
            dev.closeButton.tap()
        }
        onScreen(HomeScreen.self) { $0.exchangeAction.tap() }
        onScreen(ExchangeScreen.self) { ex in
            ex.amountField.typeText("100")
            let button = ex.executeButton.resolve()
            button.tap()
            button.tap()
            ex.executeButton.within(timeout: 20).waitUntilGone()
        }
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            tx.count.assertValue(closeTo: countBefore + 1, tolerance: 0.001)
        }
    }
}
