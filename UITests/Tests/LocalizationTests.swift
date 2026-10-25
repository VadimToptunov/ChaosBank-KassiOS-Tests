import XCTest

/// Number, currency and text formatting. Before these, the `localization`
/// profile turned no test red.
final class LocalizationTests: CBTestCase {

    /// "1,000.50" under en-US is a thousand euros and fifty cents.
    /// Catches `localeParse` (parses it as 1.0005).
    func test_transfer_amount_parsesThousandsSeparators() {
        launchUnlocked()
        var eur = Double.nan
        onScreen(HomeScreen.self) { home in
            eur = home.account("EUR").lastNumber()
            home.transferAction.tap()
        }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("1,000.50")
            XCTAssertEqual(transfer.balanceAfter.number(), eur - 1000.50, accuracy: 0.005)
        }
    }

    /// Switching the total to USD shows it in dollars.
    /// Catches `balanceWrongCurrencySymbol` (always "€").
    func test_home_total_usesTheSelectedCurrencySymbol() {
        launchUnlocked()
        onScreen(HomeScreen.self) { home in
            home.currency("USD").tap()
            home.totalBalance.assertLabelContains("$")
        }
    }

    /// Market prices keep their cents. Catches `priceMissingDecimals`.
    func test_markets_prices_keepTheirCents() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { markets in
            markets.price("AAPL").assertExists()
            let label = markets.price("AAPL").readLabel()
            XCTAssertNotNil(label.range(of: #"\.\d{2}$"#, options: .regularExpression),
                            "price should end in cents: '\(label)'")
        }
    }

    /// Search ignores the spaces around the query.
    /// Catches `searchTrimsNothing`.
    func test_transactions_search_ignoresSurroundingSpaces() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            tx.searchField.typeText("  Salary  ")
            tx.rowText(containing: "Salary").assertExists()
        }
    }

    /// Under de-DE, numbers group with dots and use a decimal comma.
    /// Catches `numberGroupingIgnoresLocale`.
    func test_devMenu_germanLocale_groupsNumbersTheGermanWay() {
        launchUnlocked(extra: ["-ChaosBankShowDev", "1"])
        onScreen(DevMenuScreen.self) { dev in
            dev.locale("deDE").tap()
            dev.localeSample.assertLabelContains("1.234.567,89")
        }
    }

    /// Under de-DE, the currency symbol follows the amount ("1.234,56 €").
    /// Catches `currencySymbolPlacementIgnoresLocale`.
    func test_devMenu_germanLocale_putsTheCurrencySymbolLast() {
        launchUnlocked(extra: ["-ChaosBankShowDev", "1"])
        onScreen(DevMenuScreen.self) { dev in
            dev.locale("deDE").tap()
            dev.localeCurrencySample.assertExists()
            let label = dev.localeCurrencySample.readLabel()
            XCTAssertTrue(label.trimmingCharacters(in: .whitespaces).hasSuffix("€"),
                          "symbol should come last: '\(label)'")
        }
    }
}
