import XCTest

final class TransferTests: CBTestCase {

    /// The transfer happy path: form → confirm → success. Passes on the `clean`
    /// profile; flip a defect (e.g. `-ChaosBankProfile validation`) and the same
    /// flow surfaces the bug — that's the dogfooding contract.
    func test_transfer_happyPath_showsSuccess() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("100")
            transfer.continueButton.tap()
            transfer.confirmButton.tap()
            transfer.successToast.within(timeout: 20).assertVisible()
        }
    }
}
