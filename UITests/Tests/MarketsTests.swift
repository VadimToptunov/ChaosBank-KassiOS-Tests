import XCTest

final class MarketsTests: CBTestCase {

    /// The default segment is the watchlist (AAPL, NVDA, BTC). Prove each row is
    /// present via its price cell (the element that keeps a per-symbol id).
    func test_markets_listsWatchlistAssets() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { markets in
            markets.price("AAPL").assertVisible()
            markets.price("NVDA").assertVisible()
            markets.price("BTC").assertVisible()
        }
    }

    func test_openAsset_pushesDetail() {
        launchUnlocked(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetRow("AAPL").tap() }
        onScreen(AssetScreen.self) { asset in
            asset.price.assertVisible()
            asset.buyButton.assertExists()
        }
    }
}
