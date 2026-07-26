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
}
