import XCTest

final class HomeTests: CBTestCase {

    func test_home_showsBalanceAndQuickActions() {
        launchUnlocked()
        onScreen(HomeScreen.self) { home in
            home.totalBalance.assertVisible()
            home.transferAction.assertVisible()
            home.exchangeAction.assertVisible()
            home.addMoneyAction.assertVisible()
        }
    }

    func test_home_showsPerCurrencyAccounts() {
        launchUnlocked()
        onScreen(HomeScreen.self) { home in
            home.account("EUR").assertExists()
            home.account("USD").assertExists()
            home.account("GBP").assertExists()
        }
    }
}
