import XCTest

final class CardTests: CBTestCase {

    /// Freeze the card and assert the FROZEN badge reads back on. A true
    /// clean-pass → buggy-fail case: under `cardToggleInvert` the toggle reads
    /// back inverted, so the badge never appears and this goes red.
    func test_card_freeze_showsFrozenBadge() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { card in
            card.frozenBadge.assertNotExists()          // not frozen on launch
            card.freezeToggle.setSwitch(on: true)
            card.frozenBadge.within(timeout: 10).assertPresent()
        }
    }

    /// The card face must never print the CVV. The PAN proves the visual has
    /// rendered, so the absent CVV is a real absence (not "not yet drawn"); under
    /// `cardCvvVisible` a "CVV …" text appears on the face and this goes red.
    func test_card_cvv_hiddenByDefault() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { card in
            card.pan.assertExists()
            card.cvv.assertNotExists()
        }
    }
}
