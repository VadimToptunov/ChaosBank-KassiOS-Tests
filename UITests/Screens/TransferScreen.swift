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

    // Confirm sheet. ChaosBank's sheet applies `transfer.confirmSheet` to the
    // container, and SwiftUI propagates it onto every child — including the
    // Confirm button — so the button is matched by that id + its "Confirm" label.
    lazy var confirmSheet = anyEl("transfer.confirmSheet")
    lazy var confirmButton = custom("transfer confirm button") { [app] in
        app.buttons.matching(identifier: "transfer.confirmSheet")
            .matching(NSPredicate(format: "label == %@", "Confirm")).firstMatch
    }

    // Outcome.
    lazy var successToast = anyEl("transfer.successToast")
    lazy var error = anyEl("transfer.error")

    override var onLoad: [KassElement] { [recipientField] }
}
