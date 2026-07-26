import XCTest

/// Card tab: the card visual (masked PAN, no CVV on clean, FROZEN badge when
/// frozen), freeze / online-payments toggles, limits, PIN and virtual card.
/// Reference defects: `cardToggleInvert`, `cardCvvVisible`, `virtualCardShowsRealPan`.
///
/// The card visual applies `card.visual` to its container and SwiftUI propagates
/// that identifier onto every child `Text`, so the PAN / CVV / FROZEN badge are
/// all `card.visual` static texts that differ only by their label — matched here
/// by a label predicate rather than their (shadowed) inner ids.
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

    /// The FROZEN badge under its own identifier. The UIKit "views" build sets
    /// `card.frozenBadge` on a dedicated label; the SwiftUI build shadows it under
    /// `card.visual` (use `frozenBadge` above for that build).
    lazy var frozenBadgeUIKit = anyEl("card.frozenBadge")

    private func visualText(labelContains substring: String) -> KassElement {
        custom("card.visual text ~ '\(substring)'") { [app] in
            app.staticTexts.matching(identifier: "card.visual")
                .matching(NSPredicate(format: "label CONTAINS[c] %@", substring))
                .firstMatch
        }
    }

    /// The masked PAN on the card face (proof the visual has rendered).
    var pan: KassElement { visualText(labelContains: "••") }
    /// The FROZEN badge — present only while the card is frozen.
    var frozenBadge: KassElement { visualText(labelContains: "FROZEN") }
    /// The CVV — must never appear on the card face on the clean profile.
    var cvv: KassElement { visualText(labelContains: "CVV") }

    override var onLoad: [KassElement] { [anyEl("card.freezeToggle")] }
}
