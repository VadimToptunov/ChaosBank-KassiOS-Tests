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
            p.anyEl("portfolio.holding.TSLA.pnl").assertLabelContains("−")
        }
    }
}
