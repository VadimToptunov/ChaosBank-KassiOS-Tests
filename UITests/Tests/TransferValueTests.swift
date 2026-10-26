import XCTest

/// Value checks for Transfer: what the form previews and what the transfer
/// actually moves, next to the flow checks in `TransferTests`.
final class TransferValueTests: CBTestCase {

    /// "Balance after" previews the EUR balance minus the amount.
    /// Catches `balanceAfterAdds`.
    func test_transfer_balanceAfter_subtractsTheAmount() {
        launchUnlocked()
        var eurBefore = Double.nan
        onScreen(HomeScreen.self) { home in
            eurBefore = home.account("EUR").lastNumber()
            home.transferAction.tap()
        }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("100")
            XCTAssertEqual(transfer.balanceAfter.number(), eurBefore - 100, accuracy: 0.005)
        }
    }

    /// A €100.40 transfer debits exactly €100.40 from EUR and leaves USD alone.
    /// Catches `transferRoundsUp` (debits €101) and `transferDebitsWrongAccount`
    /// (debits USD).
    func test_transfer_debitsExactlyTheAmountFromEUR() {
        launchUnlocked()
        var eurBefore = Double.nan, usdBefore = Double.nan
        onScreen(HomeScreen.self) { home in
            eurBefore = home.account("EUR").lastNumber()
            usdBefore = home.account("USD").lastNumber()
            home.transferAction.tap()
        }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("100.40")
            transfer.continueButton.tap()
            transfer.confirmButton.tap()
            transfer.confirmButton.within(timeout: 20).waitUntilGone()
        }
        onScreen(HomeScreen.self) { home in
            XCTAssertEqual(home.account("EUR").lastNumber(), eurBefore - 100.40, accuracy: 0.005,
                           "EUR should drop by exactly the amount")
            XCTAssertEqual(home.account("USD").lastNumber(), usdBefore, accuracy: 0.005,
                           "USD should be untouched")
        }
    }
}
