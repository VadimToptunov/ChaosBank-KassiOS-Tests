import XCTest

/// The dashboard: total balance, per-currency accounts, and quick actions.
final class HomeScreen: CBScreen {
    lazy var root = anyEl("home.root")
    lazy var totalBalance = anyEl("home.totalBalance")
    lazy var todayChange = anyEl("home.todayChange")

    // Quick actions (open their respective sheets / push the card screen).
    lazy var transferAction = button("home.quickAction.transfer")
    lazy var exchangeAction = button("home.quickAction.exchange")
    lazy var addMoneyAction = button("home.quickAction.addMoney")
    lazy var cardAction = button("home.quickAction.card")

    // Account strip — tapping one selects that currency.
    func account(_ code: String) -> KassElement { anyEl("home.account.\(code)") }

    override var onLoad: [KassElement] { [totalBalance] }
}

/// The bottom tab bar (visible only once unlocked).
final class TabBar: CBScreen {
    lazy var home = button("tabBar.home")
    lazy var markets = button("tabBar.markets")
    lazy var portfolio = button("tabBar.portfolio")
    lazy var card = button("tabBar.card")
}
