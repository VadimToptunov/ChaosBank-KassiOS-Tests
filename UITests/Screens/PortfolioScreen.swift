import XCTest

/// Portfolio tab: total value, P&L, allocation and holdings list.
/// Reference defects: `pnlSign`, `pnlPercentVsValue`, `mainThreadStall`.
final class PortfolioScreen: CBScreen {
    lazy var root = anyEl("portfolio.root")
    lazy var totalValue = anyEl("portfolio.totalValue")
    lazy var pnl = anyEl("portfolio.pnl")
    lazy var allocationBar = anyEl("portfolio.allocationBar")
    lazy var list = anyEl("portfolio.list")

    override var onLoad: [KassElement] { [totalValue] }
}
