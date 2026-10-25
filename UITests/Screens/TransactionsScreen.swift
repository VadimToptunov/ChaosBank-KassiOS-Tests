import XCTest

/// Transaction history, opened from Home's "See all activity".
/// Reference defects: `paginationDup`, `paginationNeverEnds`,
/// `filterLeaksCategory`, `transactionsHeavyList`.
final class TransactionsScreen: CBScreen {
    lazy var root = anyEl("transactions.root")
    lazy var list = anyEl("transactions.list")
    lazy var count = anyEl("transactions.count")
    lazy var searchField = textField("transactions.searchField")
    lazy var loadMore = anyEl("transactions.loadMore")
    lazy var filterAll = anyEl("transactions.filter.all")
    lazy var filterIn = anyEl("transactions.filter.in")
    lazy var filterOut = anyEl("transactions.filter.out")

    /// Every rendered transaction's signed amount text — one per visible row.
    ///
    /// Each row's texts (title, time, amount) carry the row's own
    /// `transactions.row.<id>` identifier; the amount is the one that starts with
    /// a sign ("+€39.99", "−€64.30").
    lazy var amounts = customCollection("transaction amounts") { [app] in
        app.staticTexts.matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND (label BEGINSWITH %@ OR label BEGINSWITH %@)",
            "transactions.row.", "+", "\u{2212}"
        ))
    }

    override var onLoad: [KassElement] { [list] }
}
