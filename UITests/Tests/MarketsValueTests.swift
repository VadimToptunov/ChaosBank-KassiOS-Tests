import XCTest

/// Value checks across Markets and Asset detail. Both read the same live quote,
/// but the simulated feed ticks every 700 ms and moves fast, so numbers read one
/// after another can come from different ticks. Instead, each screen's price and
/// % change are read from a single accessibility snapshot (one moment), and the
/// screens are compared on the quote's day open, which doesn't tick:
/// open = price ÷ (1 + change%).
final class MarketsValueTests: CBTestCase {

    private func impliedOpen(_ screen: KassScreen, price priceId: String, change changeId: String) throws -> Double {
        let labels = screen.readTexts([priceId, changeId])
        let price = try XCTUnwrap(numbers(in: try XCTUnwrap(labels[priceId])).first)
        let change = try XCTUnwrap(numbers(in: try XCTUnwrap(labels[changeId])).first)
        return price / (1 + change / 100)
    }

    /// The asset detail and the market row imply the same day open.
    /// Catches `changePctSignFlipped` (row sign) and `detailPriceOffset`
    /// (detail price +$5).
    func test_assetDetail_agreesWithTheMarketRow() throws {
        launchUnlocked(tab: "markets")
        var rowOpen = Double.nan
        onScreen(MarketsScreen.self) { markets in
            markets.change("AAPL").assertExists()
            rowOpen = (try? impliedOpen(markets, price: "markets.asset.AAPL.price", change: "markets.asset.AAPL.change")) ?? .nan
            markets.assetRow("AAPL").tap()
        }
        onScreen(AssetScreen.self) { asset in
            asset.change.assertExists()
            let detailOpen = (try? impliedOpen(asset, price: "asset.price", change: "asset.change")) ?? .nan
            // Display rounding (cents, hundredths of a percent) moves the
            // implied open by well under 0.03%.
            XCTAssertEqual(detailOpen, rowOpen, accuracy: rowOpen * 0.0003,
                           "detail and row should agree on the day open")
        }
    }
}
