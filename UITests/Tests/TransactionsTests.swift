import XCTest

final class TransactionsTests: CBTestCase {

    /// Open the full history from Home's "See all activity" and assert the list
    /// and its controls render. The surface `paginationDup`, `filterLeaksCategory`
    /// and `transactionsHeavyList` act on (deeper assertions are a follow-up).
    func test_transactions_openFromHome_showsList() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            tx.list.assertExists()
            tx.count.assertPresent()
            tx.searchField.assertExists()
        }
    }

    /// Each transaction must appear once, even after paging in the rest of the
    /// history. `paginationDup` re-inserts a boundary row on every "Load more"
    /// past the first page, so the same row renders twice.
    ///
    /// The seed history is 16 transactions at a page size of 6 — two "Load
    /// more" taps load all of it (6 → 12 → 16), so this loads the full list
    /// rather than relying on a specific page boundary.
    func test_transactions_loadMore_noDuplicateRows() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            tx.loadMore.softScrollTo(in: tx.root).tap()
            tx.loadMore.softScrollTo(in: tx.root).tap()
            tx.amounts.assertNotEmpty()
            tx.amounts.assertNoDuplicates()
        }
    }

    /// The "Money in" filter must show only money-in rows. `filterLeaksCategory`
    /// lets every transaction through regardless of direction once that filter
    /// is selected, so a money-out ("−") row leaks in among the "+" ones.
    func test_transactions_moneyInFilter_showsOnlyMoneyIn() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.seeAllActivity.tap() }
        onScreen(TransactionsScreen.self) { tx in
            tx.filterIn.tap()
            tx.amounts.assertNotEmpty()
            tx.amounts.assertEach("every row is money-in") { row in
                let label = row.readLabel()
                guard label.hasPrefix("+") else {
                    throw KassError("expected a money-in ('+') row but found '\(label)'")
                }
            }
        }
    }
}
