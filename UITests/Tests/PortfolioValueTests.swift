import XCTest

/// Value checks for the Portfolio tab, next to the presence-only
/// `PortfolioTests.test_portfolio_showsTotalAndPnl`, which stays green under
/// `pnlSign`.
final class PortfolioValueTests: CBTestCase {

    /// TSLA is held at a loss (8 @ $280, trading lower), so its P&L must read as
    /// a loss. ChaosBank formats the sign as U+2212 MINUS SIGN, not ASCII "-".
    /// Catches `pnlSign`.
    func test_portfolio_tslaLoss_isRenderedAsLoss() {
        launchUnlocked(tab: "portfolio")
        onScreen(PortfolioScreen.self) { p in
            p.holdingPnl("TSLA").assertLabelContains("−")
        }
    }

    /// The total is the sum of the holdings' values, all read from one snapshot
    /// so they belong to the same price tick. Catches `totalValueOmitsHolding`
    /// (drops ETH).
    func test_portfolio_total_equalsSumOfHoldings() throws {
        launchUnlocked(tab: "portfolio")
        let ids = ["AAPL", "TSLA", "ETH"].map { "portfolio.holding.\($0).value" }
        var labels: [String: String] = [:]
        onScreen(PortfolioScreen.self) { p in labels = p.readTexts(ids + ["portfolio.totalValue"]) }
        let sum = try ids.map { try XCTUnwrap(numbers(in: try XCTUnwrap(labels[$0])).first) }.reduce(0, +)
        let total = try XCTUnwrap(numbers(in: try XCTUnwrap(labels["portfolio.totalValue"])).first)
        XCTAssertEqual(total, sum, accuracy: 0.02, "total should be the sum of the holdings")
    }

    /// A holding is valued at the market price: AAPL's value ÷ 12 shares is the
    /// AAPL price on Markets. Catches `holdingValueUsesCost` (values at $150).
    func test_portfolio_holdingValue_usesTheMarketPrice() {
        launchUnlocked(tab: "portfolio")
        var perShare = Double.nan
        onScreen(PortfolioScreen.self) { p in perShare = p.holdingValue("AAPL").number() / 12 }
        onScreen(TabBar.self) { $0.markets.tap() }
        onScreen(MarketsScreen.self) { markets in
            let price = markets.price("AAPL").number()
            XCTAssertEqual(perShare, price, accuracy: price * 0.03)
        }
    }

    /// The all-time P&L % is measured against the cost basis and carries the
    /// P&L's sign. The cost basis doesn't tick: the seeded holdings cost
    /// 12 × $150 + 8 × $280 + 3.5 × $2,400 = $12,440. The P&L and the % come from
    /// the same label, so they belong to the same tick.
    /// Catches `pnlPercentVsValue`.
    func test_portfolio_pnlPercent_isAgainstTheCostBasis() {
        launchUnlocked(tab: "portfolio")
        onScreen(PortfolioScreen.self) { p in
            p.pnl.assertExists()
            let values = numbers(in: p.pnl.readLabel())   // one read: one tick
            guard values.count >= 2 else { return XCTFail("no P&L and % in '\(p.pnl.readLabel())'") }
            let pnl = values[0], percent = values[1]
            XCTAssertEqual(percent, pnl / 12_440 * 100, accuracy: 0.01)
            XCTAssertEqual(percent.sign, pnl.sign, "the % should carry the P&L's sign")
        }
    }
}
