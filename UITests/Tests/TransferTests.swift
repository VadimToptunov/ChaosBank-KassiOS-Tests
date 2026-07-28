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
            // The toast is real, transient state (~1.4s), not just a side effect
            // of the sheet closing — `successToastMissing` skips rendering it
            // entirely while the transfer still silently succeeds and the screen
            // still dismisses, so a presence-only check on the sheet would miss
            // it. Check it first, before it has a chance to expire.
            transfer.successToast.assertAppears(within: 2)
            // The success toast itself races its own dismissal against a plain
            // wait-for-idle, so assert the persistent outcome too: the confirm
            // sheet closes only on success, i.e. the Confirm button disappears.
            transfer.confirmButton.within(timeout: 20).waitUntilGone()
        }
    }

    /// A zero amount must not enable Continue. `zeroAmountAccepted` relaxes the
    /// validation to `amount >= 0`, so this only fails once that guard is gone.
    func test_transfer_zeroAmount_disablesContinue() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("0")
            transfer.continueButton.assertDisabled()
        }
    }
}
