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

    override var onLoad: [KassElement] { [list] }
}
