import Foundation
import XCTest

/// Value checks for the loan example, next to the presence-only
/// `LoansTests.test_loans_showsAprMonthlyTotal`.
final class LoansValueTests: CBTestCase {

    /// The monthly payment is the standard amortised payment on €5,000 over 24
    /// months at the APR the screen advertises, and the total is 24 payments.
    /// Catches `loanAprUnderstated` (the payment uses a higher rate).
    func test_loans_monthlyPayment_matchesTheAdvertisedApr() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { $0.loanButton.tap() }
        onScreen(LoansScreen.self) { loans in
            let apr = loans.apr.number()
            let rate = apr / 100 / 12
            let expected = 5000 * rate / (1 - pow(1 + rate, -24))
            let monthly = loans.monthly.number()
            XCTAssertEqual(monthly, expected, accuracy: 0.01, "payment should match \(apr)% APR")
            XCTAssertEqual(loans.total.number(), monthly * 24, accuracy: 0.25)
        }
    }
}
