import XCTest

/// The transfer flow: form → confirm sheet → success toast.
final class TransferScreen: CBScreen {
    // `transfer.root` is applied to a container that SwiftUI doesn't surface as a
    // queryable element, so `recipientField` is the load proof instead.
    lazy var recipientField = textField("transfer.recipientField")
    lazy var amountField = textField("transfer.amountField")
    lazy var noteField = textField("transfer.noteField")
    lazy var balanceAfter = anyEl("transfer.balanceAfter")
    lazy var continueButton = button("transfer.continueButton")

    // Confirm sheet.
    lazy var confirmSheet = anyEl("transfer.confirmSheet")
    lazy var confirmButton = button("transfer.confirmButton")

    // Outcome.
    lazy var successToast = anyEl("transfer.successToast")
    lazy var error = anyEl("transfer.error")

    override var onLoad: [KassElement] { [recipientField] }
}
