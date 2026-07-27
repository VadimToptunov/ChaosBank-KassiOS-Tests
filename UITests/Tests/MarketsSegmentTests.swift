import XCTest

final class MarketsSegmentTests: CBTestCase {

    /// Each segment filters `SeedData.assets` to a different set (watchlist:
    /// AAPL/NVDA/BTC, stocks: AAPL/MSFT/NVDA/TSLA, crypto: BTC/ETH). `MSFT` and
    /// `ETH` only appear once you actually switch segments, so parameterizing
    /// over them proves segment switching re-renders the list rather than just
    /// leaving the default watchlist behind three buttons that do nothing.
    ///
    /// `parameterized` keeps `continueAfterFailure` on across cases, so a
    /// regression in one segment doesn't hide a regression in the others — and
    /// `relaunch`ing per case (via `launchUnlocked`) gives each segment a clean
    /// slate rather than relying on in-app segment state surviving the previous
    /// case's assertions.
    func test_eachSegment_rendersItsAssets() {
        let cases: [(name: String, symbol: String)] = [
            ("watchlist", "AAPL"),
            ("stocks", "MSFT"),
            ("crypto", "ETH")
        ]

        parameterized(cases, name: { $0.name }) { segment in
            launchUnlocked(tab: "markets")
            onScreen(MarketsScreen.self) { markets in
                switch segment.name {
                case "stocks": markets.stocksSegment.tap()
                case "crypto": markets.cryptoSegment.tap()
                default: break // watchlist is the segment markets opens on
                }
                markets.price(segment.symbol).assertVisible()
            }
        }
    }
}
