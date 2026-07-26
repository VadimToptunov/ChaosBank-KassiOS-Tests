import XCTest

/// Markets list: watchlist / stocks / crypto segments and asset rows.
///
/// Note ChaosBank's real tree: every row button carries the *container*
/// identifier `markets.list` and distinguishes itself by its **label** (the
/// symbol); only the price/change sub-cells carry `markets.asset.<SYMBOL>.*`.
final class MarketsScreen: CBScreen {
    lazy var root = anyEl("markets.root")
    lazy var watchlistSegment = button("markets.segment.watchlist")
    lazy var stocksSegment = button("markets.segment.stocks")
    lazy var cryptoSegment = button("markets.segment.crypto")

    /// The tappable row for `symbol` (a `markets.list` button labelled `symbol`).
    func assetRow(_ symbol: String) -> KassElement {
        custom("markets row '\(symbol)'") { [app] in
            app.buttons.matching(identifier: "markets.list")
                .matching(NSPredicate(format: "label == %@", symbol)).firstMatch
        }
    }

    /// The price cell for `symbol` — proof the row is present.
    func price(_ symbol: String) -> KassElement { anyEl("markets.asset.\(symbol).price") }

    /// The whole asset **cell** by its per-symbol id. The UIKit "views" build sets
    /// `markets.asset.<SYMBOL>` on the `UITableViewCell` itself, so this both
    /// proves presence and is tappable there.
    func assetCell(_ symbol: String) -> KassElement { anyEl("markets.asset.\(symbol)") }

    /// The order confirmation dialog raised by tapping a row in the UIKit build
    /// ("Buy AAPL at $…?"), matched by its message substring.
    func orderDialog(contains substring: String) -> KassElement {
        custom("order dialog ~ '\(substring)'") { [app] in
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", substring)).firstMatch
        }
    }

    override var onLoad: [KassElement] { [root] }
}

/// Asset detail: big live price, stats, buy/sell.
final class AssetScreen: CBScreen {
    lazy var root = anyEl("asset.root")
    lazy var symbol = anyEl("asset.symbol")
    lazy var price = anyEl("asset.price")
    lazy var buyButton = button("asset.buyButton")
    lazy var sellButton = button("asset.sellButton")

    override var onLoad: [KassElement] { [price] }
}
