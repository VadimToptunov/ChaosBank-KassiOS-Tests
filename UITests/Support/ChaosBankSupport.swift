import XCTest

// KassiOS is compiled directly into this UI-test target, so there is no
// `import KassiOS`.

/// Base for every ChaosBank UI test: gives readable launch helpers over
/// ChaosBank's launch-argument surface (see its README "Launch arguments").
class CBTestCase: KassTestCase {

    /// Boots straight to the unlocked home, skipping the whole auth ladder
    /// (`-ChaosBankStartUnlocked 1`). Optionally deep-links a tab.
    @discardableResult
    func launchUnlocked(tab: String? = nil, profile: String? = nil) -> XCUIApplication {
        var args = ["-ChaosBankStartUnlocked", "1"]
        if let tab = tab { args += ["-ChaosBankTab", tab] }
        if let profile = profile { args += ["-ChaosBankProfile", profile] }
        return launch(arguments: args)
    }
}

/// Base screen object. Adds `anyEl` — resolve by identifier regardless of element
/// type — because SwiftUI exposes the same view as a button, cell, or "other"
/// depending on context, and matching a fixed type is a common source of flake.
class CBScreen: KassScreen {
    func anyEl(_ id: String) -> KassElement {
        custom("any '\(id)'") { [app] in
            app.descendants(matching: .any)[id].firstMatch
        }
    }
}
