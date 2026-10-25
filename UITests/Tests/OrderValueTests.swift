import Foundation
import XCTest

/// Value checks for the order ticket's estimated total.
final class OrderValueTests: CBTestCase {

    private func openBuyTicket() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { $0.buyButton.tap() }
    }

    /// For a market order, the estimated total is quantity × reference price.
    /// Catches `estTotalIgnoresQty`.
    func test_order_estimatedTotal_isQuantityTimesPrice() {
        openBuyTicket()
        onScreen(OrderScreen.self) { order in
            order.qtyIncrement.tap()
            order.qtyIncrement.tap()
            let qty = order.qtyValue.number()
            XCTAssertEqual(qty, 3, "precondition: three shares")
            let ref = order.refPrice.number()
            XCTAssertEqual(order.estTotal.number(), qty * ref, accuracy: qty * ref * 0.005)
        }
    }

    /// For a limit order, the estimated total uses the limit price.
    /// Catches `limitExecutesAtMarket`.
    func test_order_limitEstimatedTotal_usesTheLimitPrice() {
        openBuyTicket()
        onScreen(OrderScreen.self) { order in
            order.typeLimit.tap()
            let limit = (order.refPrice.number() - 10).rounded()
            order.limitPriceField.replaceText(String(format: "%.2f", limit))
            XCTAssertEqual(order.estTotal.number(), limit, accuracy: 0.005,
                           "one share at the limit price")
        }
    }
}
