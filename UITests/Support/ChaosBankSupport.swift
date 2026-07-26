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

        // Buggy-matrix hook: re-run the whole clean suite against a defect build
        // without editing any test, to prove the clean-pass flows go red. Set
        // `TEST_RUNNER_CB_INJECT_DEFECTS=a,b` (or `..._PROFILE=validation`) on the
        // xcodebuild invocation — Xcode forwards it into the runner (prefix stripped).
        let env = ProcessInfo.processInfo.environment
        if let d = env["CB_INJECT_DEFECTS"], !d.isEmpty { args += ["-ChaosBankDefects", d] }
        if let p = env["CB_INJECT_PROFILE"], !p.isEmpty { args += ["-ChaosBankProfile", p] }
        return launch(arguments: args)
    }

    /// Boots the alternate **UIKit "views" build** unlocked (`-ChaosBankUIKit 1`).
    /// Same screens/locators as the SwiftUI build — the imperative-UI reference
    /// suite reuses the SwiftUI screen objects and asserts identical clean
    /// behaviour, so the buggy-matrix can drive the UIKit-characteristic defects
    /// (target-action wiring, `bindingAdapterPosition`, initial toggle binding…)
    /// red without editing a single test.
    @discardableResult
    func launchUIKit(tab: String? = nil, profile: String? = nil) -> XCUIApplication {
        var args = ["-ChaosBankStartUnlocked", "1", "-ChaosBankUIKit", "1"]
        if let tab = tab { args += ["-ChaosBankTab", tab] }
        if let profile = profile { args += ["-ChaosBankProfile", profile] }
        let env = ProcessInfo.processInfo.environment
        if let d = env["CB_INJECT_DEFECTS"], !d.isEmpty { args += ["-ChaosBankDefects", d] }
        if let p = env["CB_INJECT_PROFILE"], !p.isEmpty { args += ["-ChaosBankProfile", p] }
        return launch(arguments: args)
    }

    /// Fresh, *locked* launch — no `-ChaosBankStartUnlocked`, so the app opens on
    /// the auth ladder. Still forwards the buggy-matrix injection hook.
    @discardableResult
    func launchFresh(profile: String? = nil) -> XCUIApplication {
        // Force the locked ladder: -ChaosBankStartUnlocked 0 wins over any value
        // lingering in the argument/standard defaults domain.
        var args: [String] = ["-ChaosBankStartUnlocked", "0"]
        if let profile = profile { args += ["-ChaosBankProfile", profile] }
        let env = ProcessInfo.processInfo.environment
        if let d = env["CB_INJECT_DEFECTS"], !d.isEmpty { args += ["-ChaosBankDefects", d] }
        if let p = env["CB_INJECT_PROFILE"], !p.isEmpty { args += ["-ChaosBankProfile", p] }
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
