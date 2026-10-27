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
    /// The display-currency option for the total ("EUR", "USD", "GBP").
    func currency(_ code: String) -> KassElement { button("home.currencySegment.\(code)") }

    // Recent-activity list and its "See all" entry into the Transactions screen.
    lazy var recentActivity = anyEl("home.recentActivity")
    lazy var seeAllActivity = anyEl("home.seeAllActivity")

    /// Long-press (or triple-tap) opens the hidden dev menu mid-session — an
    /// alternative to relaunching with `-ChaosBankShowDev 1` when a test needs
    /// to read state (e.g. a baseline count) before flipping a dev-menu knob.
    lazy var buildBadge = anyEl("build.badge")

    override var onLoad: [KassElement] { [totalBalance] }
}

/// The bottom tab bar (visible only once unlocked).
/// The system tab bar. On iOS 27, after a sheet is dismissed, SwiftUI's `TabView`
/// drops the identifiers of its `tabItem`s, so each tab falls back to its fixed
/// title in the tab bar.
final class TabBar: CBScreen {
    lazy var home = tab("tabBar.home", title: "Home")
    lazy var markets = tab("tabBar.markets", title: "Markets")
    lazy var portfolio = tab("tabBar.portfolio", title: "Portfolio")
    lazy var card = tab("tabBar.card", title: "Card")

    private func tab(_ id: String, title: String) -> KassElement {
        custom("tab '\(title)'") { [app] in
            let byId = app.buttons[id]
            if byId.exists { return byId }
            let inTabBar = app.tabBars.buttons[title]
            return inTabBar.exists ? inTabBar : app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
        }
    }
}
