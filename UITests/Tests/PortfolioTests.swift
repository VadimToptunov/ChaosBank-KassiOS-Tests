import XCTest

final class PortfolioTests: CBTestCase {

    /// The portfolio tab renders total value and P&L — the surface `pnlSign` and
    /// `pnlPercentVsValue` corrupt, and `mainThreadStall` delays.
    func test_portfolio_showsTotalAndPnl() {
        launchUnlocked(tab: "portfolio")
        onScreen(PortfolioScreen.self) { p in
            p.totalValue.assertVisible()
            p.pnl.assertPresent()
            p.list.assertExists()
        }
    }
}
