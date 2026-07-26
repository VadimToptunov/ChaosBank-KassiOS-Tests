import XCTest

final class LoansTests: CBTestCase {

    /// The loan screen (Card → "Explore a loan") shows APR, monthly payment and
    /// total — the surface `loanAprUnderstated` corrupts (payment computed at a
    /// higher rate than the advertised APR). Value-level assertions are a follow-up.
    func test_loans_showsAprMonthlyTotal() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { $0.loanButton.tap() }
        onScreen(LoansScreen.self) { loans in
            loans.apr.assertPresent()
            loans.monthly.assertPresent()
            loans.total.assertPresent()
        }
    }
}
