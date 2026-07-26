import XCTest

final class OrderTests: CBTestCase {

    /// The Buy button must announce itself as "Buy". Under `wrongA11yLabel` its
    /// accessibility label reads "Sell" and this goes red. (A11y-only defect —
    /// exactly what a framework like KassiOS should surface.)
    func test_asset_buyButton_labelledBuy() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { $0.buyButton.assertLabel("Buy") }
    }

    /// Zero quantity must block Review. Under `limitValidation` the form reports
    /// valid at qty 0, Review stays enabled, and this goes red.
    func test_order_zeroQuantity_disablesReview() {
        openBuyTicket()
        onScreen(OrderScreen.self) { order in
            order.qtyDecrement.tap()            // default qty 1 → 0
            order.qtyValue.assertHasText("0")
            order.reviewButton.assertDisabled()
        }
    }

    /// A placed market order reports "Order filled". Under `orderStuckPending`
    /// the toast stays "Order pending…" and this goes red.
    func test_order_place_reportsFilled() {
        openBuyTicket()
        onScreen(OrderScreen.self) { order in
            order.reviewButton.tap()
            order.placeButton.tap()
            order.statusToast.within(timeout: 20).assertHasText("filled")
        }
    }

    /// Markets → AAPL → Buy, leaving the order ticket on screen.
    private func openBuyTicket() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { $0.buyButton.scrollTo(in: $0.root).tap() }
    }
}
