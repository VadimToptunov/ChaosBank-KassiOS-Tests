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
}
