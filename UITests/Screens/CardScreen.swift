import XCTest

/// Card tab: the card visual (masked PAN, no CVV on clean, FROZEN badge when
/// frozen), freeze / online-payments toggles, limits, PIN and virtual card.
/// Reference defects: `cardToggleInvert`, `cardCvvVisible`, `virtualCardShowsRealPan`.
final class CardScreen: CBScreen {
    lazy var root = anyEl("card.root")                    // the ScrollView
    lazy var freezeToggle = switchControl("card.freezeToggle")
    lazy var onlinePaymentsToggle = switchControl("card.onlinePaymentsToggle")
    lazy var virtualButton = button("card.virtualButton")
    lazy var loanButton = button("card.loanButton")     // → Loans screen
    lazy var limitField = textField("card.limitField")
    lazy var limitError = anyEl("card.limitError")
    /// The field's built-in clear button (its only child button), locale-independent.
    var limitClearButton: KassElement {
        custom("card.limitField clear button") { [app] in
            app.textFields["card.limitField"].buttons.firstMatch
        }
    }

    /// The masked PAN on the card face (proof the visual has rendered).
    lazy var pan = anyEl("card.number")
    /// The FROZEN badge — present only while the card is frozen.
    lazy var frozenBadge = anyEl("card.frozenBadge")
    /// The same badge in the UIKit "views" build, which uses the same identifier.
    lazy var frozenBadgeUIKit = frozenBadge
    /// The CVV — must never appear on the card face on the clean profile.
    lazy var cvv = anyEl("card.cvv")
    lazy var pinButton = button("card.pinButton")
    lazy var virtualNumber = anyEl("card.virtualNumber")
    lazy var kycButton = button("card.kycButton")
    lazy var kycStatus = anyEl("card.kycStatus")

    override var onLoad: [KassElement] { [anyEl("card.freezeToggle")] }
}
