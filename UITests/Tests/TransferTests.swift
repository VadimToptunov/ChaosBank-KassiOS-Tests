import XCTest

final class TransferTests: CBTestCase {

    /// The transfer happy path: form → confirm → success. Passes on the `clean`
    /// profile; flip a defect (e.g. `-ChaosBankProfile validation`) and the same
    /// flow surfaces the bug — that's the dogfooding contract.
    func test_transfer_happyPath_completes() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("100")
            transfer.continueButton.tap()
            transfer.confirmButton.tap()
            // The success toast lives ~1.4s; asserting it races a wait-for-idle
            // against its own dismissal (the exact flake this app teaches). Assert
            // the persistent outcome instead: the confirm sheet closes only on
            // success, so the Confirm button disappearing proves the transfer went.
            transfer.confirmButton.within(timeout: 20).waitUntilGone()
        }
    }
}
