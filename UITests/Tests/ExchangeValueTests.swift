import XCTest

/// Value checks for Exchange balances, next to `ExchangeTests`, which compares
/// the credited history row with "you get".
final class ExchangeValueTests: CBTestCase {

    /// Selling €25 for USD takes €25 from EUR and adds "you get" to USD.
    /// Catches `exchangeCreditsWrongAccount` (credits EUR, the sell account).
    func test_exchange_movesMoneyBetweenTheRightAccounts() {
        launchUnlocked()
        var eurBefore = Double.nan, usdBefore = Double.nan, youGet = Double.nan
        onScreen(HomeScreen.self) { home in
            eurBefore = home.account("EUR").lastNumber()
            usdBefore = home.account("USD").lastNumber()
            home.exchangeAction.tap()
        }
        onScreen(ExchangeScreen.self) { ex in
            ex.amountField.typeText("25")
            youGet = ex.youGet.number()
            ex.executeButton.tap()
            ex.executeButton.within(timeout: 20).waitUntilGone()
        }
        onScreen(HomeScreen.self) { home in
            XCTAssertEqual(home.account("EUR").lastNumber(), eurBefore - 25, accuracy: 0.005)
            XCTAssertEqual(home.account("USD").lastNumber(), usdBefore + youGet, accuracy: 0.005)
        }
    }
}
