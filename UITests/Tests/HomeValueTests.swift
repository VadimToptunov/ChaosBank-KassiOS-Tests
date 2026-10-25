import XCTest

/// Value checks for Home, next to the presence-only
/// `HomeTests.test_home_showsBalanceAndQuickActions`.
final class HomeValueTests: CBTestCase {

    /// The total equals the three accounts converted to EUR at ChaosBank's
    /// mid rates (1 EUR = 1.08 USD = 0.85 GBP), to the cent.
    /// Catches `homeTotalOmitsAccount` and `balanceFloorRounded`.
    func test_home_total_equalsSumOfAccounts() {
        launchUnlocked()
        onScreen(HomeScreen.self) { home in
            let eur = home.account("EUR").lastNumber()
            let usd = home.account("USD").lastNumber()
            let gbp = home.account("GBP").lastNumber()
            let expected = ((eur + usd / 1.08 + gbp / 0.85) * 100).rounded() / 100
            XCTAssertEqual(home.totalBalance.number(), expected, accuracy: 0.005,
                           "total should be EUR + USD + GBP in EUR")
        }
    }

    /// The seeded day is up 0.40%: today's change reads as a gain of 0.40% of
    /// the total. Catches `todayChangeSignFlipped`.
    func test_home_todayChange_isAGainOfTheTotal() {
        launchUnlocked()
        onScreen(HomeScreen.self) { home in
            let total = home.totalBalance.number()
            let amount = home.todayChange.number(0)
            let percent = home.todayChange.number(1)
            XCTAssertGreaterThan(amount, 0, "today's change should be a gain: \(home.todayChange.readLabel())")
            XCTAssertEqual(percent, 0.40, accuracy: 0.001)
            XCTAssertEqual(amount, total * percent / 100, accuracy: 0.01)
        }
    }
}
