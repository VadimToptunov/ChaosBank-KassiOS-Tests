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
    /// `TransactionRowView` gives each row its own `transactions.row.<id>`
    /// identifier, but SwiftUI's container-id propagation clobbers it: every
    /// descendant of the list (icon, title, time, amount — see the row view)
    /// surfaces with the ancestor's `transactions.list` identifier instead, so
    /// the per-row id isn't actually queryable. The signed amount text (e.g.
    /// "+€39.99", "−€64.30") is unique per seed transaction, so it stands in
    /// as a stable per-row key for dedup/each-row checks.
    lazy var amounts = customCollection("transaction amounts") { [app] in
        app.staticTexts.matching(NSPredicate(
            format: "identifier == %@ AND (label BEGINSWITH %@ OR label BEGINSWITH %@)",
            "transactions.list", "+", "\u{2212}"
        ))
    }

    override var onLoad: [KassElement] { [list] }
}
