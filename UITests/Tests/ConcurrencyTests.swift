import XCTest

/// Races and double submits. Before these, the `flaky` profile turned no test
/// red. The double-submit tests use the dev menu's "Slow" network condition
/// (3 s per request, not a defect) so both taps land inside one in-flight
/// request; see `ExchangeTests.test_exchange_rapidDoubleTapExecute_exchangesOnlyOnce`
/// for why that's needed.
final class ConcurrencyTests: CBTestCase {

    private func slowNetwork() {
        onScreen(HomeScreen.self) { $0.buildBadge.longPress(forDuration: 0.6) }
        onScreen(DevMenuScreen.self) { dev in
            dev.networkCondition("Slow").tap()
            dev.closeButton.tap()
        }
    }

    /// A rapid double-tap on Confirm debits the account once.
    /// Catches `doubleCharge`.
    func test_transfer_rapidDoubleTapConfirm_debitsOnce() {
        launchUnlocked()
        var eurBefore = Double.nan
        onScreen(HomeScreen.self) { eurBefore = $0.account("EUR").lastNumber() }
        slowNetwork()
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("100")
            transfer.continueButton.tap()
            transfer.confirmButton.rapidTap(times: 2)
            transfer.confirmButton.within(timeout: 30).waitUntilGone()
        }
        onScreen(HomeScreen.self) { home in
            home.account("EUR").within(timeout: 15)
                .waitUntil("EUR drops below the starting balance") { el in
                    (numbers(in: el.label).last ?? .infinity) < eurBefore
                }
            // Let a second, racing debit land if there is one.
            RunLoop.current.run(until: Date().addingTimeInterval(4))
            XCTAssertEqual(home.account("EUR").lastNumber(), eurBefore - 100, accuracy: 0.005,
                           "one transfer, one debit")
        }
    }

    /// A rapid double-tap on Place order buys one share, not two.
    /// Catches `orderDoubleSubmit`.
    func test_order_rapidDoubleTapPlace_buysOnce() {
        launchUnlocked()
        slowNetwork()
        onScreen(TabBar.self) { $0.markets.tap() }
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { $0.buyButton.tap() }
        onScreen(OrderScreen.self) { order in
            order.reviewButton.tap()
            order.placeButton.rapidTap(times: 2)
            // A filled order pops the ticket.
            order.reviewButton.within(timeout: 30).waitUntilGone()
        }
        // Let a second, racing order land if there is one.
        RunLoop.current.run(until: Date().addingTimeInterval(4))
        onScreen(TabBar.self) { $0.portfolio.tap() }
        onScreen(PortfolioScreen.self) { p in
            let row = p.holding("AAPL")
            row.assertExists()
            let quantity = row.resolve().staticTexts
                .matching(NSPredicate(format: "label CONTAINS %@", " @ ")).firstMatch.label
            XCTAssertEqual(numbers(in: quantity).first ?? .nan, 13, "12 seeded + one bought: '\(quantity)'")
        }
    }

    /// The order ticket keeps the price captured when Buy was tapped; it
    /// doesn't follow the live feed. Catches `livePriceRace`.
    func test_order_referencePrice_staysAtTheCapturedPrice() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { $0.buyButton.tap() }
        onScreen(OrderScreen.self) { order in
            // Several 700 ms ticks: a live price would move within this window.
            order.refPrice.assertUnchanged(for: 3)
        }
    }

    /// The Sync playground's concurrent +1 batch loses no updates.
    /// Catches `syncLostUpdate`.
    func test_syncPlayground_concurrentIncrements_loseNothing() {
        launchUnlocked(extra: ["-ChaosBankShowDev", "1"])
        onScreen(DevMenuScreen.self) { $0.syncButton.tap() }
        onScreen(SyncScreen.self) { sync in
            // "Run 20 parallel +1 → expect 20": read before running, since the
            // expectation is recomputed from the counter afterwards.
            let expected = sync.expected.lastNumber()
            sync.runButton.tap()
            RunLoop.current.run(until: Date().addingTimeInterval(5))
            XCTAssertEqual(sync.counter.lastNumber(), expected, "every +1 should land")
        }
    }
}
