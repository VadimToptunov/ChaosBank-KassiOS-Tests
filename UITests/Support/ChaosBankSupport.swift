import XCTest

// KassiOS is compiled directly into this UI-test target, so there is no
// `import KassiOS`.

/// Base for every ChaosBank UI test: gives readable launch helpers over
/// ChaosBank's launch-argument surface (see its README "Launch arguments").
class CBTestCase: KassTestCase {

    /// Boots straight to the unlocked home, skipping the whole auth ladder
    /// (`-ChaosBankStartUnlocked 1`). Optionally deep-links a tab.
    @discardableResult
    func launchUnlocked(tab: String? = nil, profile: String? = nil, extra: [String] = []) -> XCUIApplication {
        var args = ["-ChaosBankStartUnlocked", "1"] + extra
        if let tab = tab { args += ["-ChaosBankTab", tab] }
        if let profile = profile { args += ["-ChaosBankProfile", profile] }

        // Buggy-matrix hook: re-run the whole clean suite against a defect build
        // without editing any test, to prove the clean-pass flows go red. Set
        // `TEST_RUNNER_CB_INJECT_DEFECTS=a,b` (or `..._PROFILE=validation`) on the
        // xcodebuild invocation — Xcode forwards it into the runner (prefix stripped).
        args += injected()
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
        args += injected()
        return launch(arguments: args)
    }

    /// Fresh, *locked* launch — no `-ChaosBankStartUnlocked`, so the app opens on
    /// the auth ladder. Still forwards the buggy-matrix injection hook.
    @discardableResult
    func launchFresh(profile: String? = nil, extra: [String] = []) -> XCUIApplication {
        // Force the locked ladder: -ChaosBankStartUnlocked 0 wins over any value
        // lingering in the argument/standard defaults domain.
        var args: [String] = ["-ChaosBankStartUnlocked", "0"] + extra
        if let profile = profile { args += ["-ChaosBankProfile", profile] }
        args += injected()
        return launch(arguments: args)
    }

    /// The buggy-matrix hook, plus `TEST_RUNNER_CB_BACKEND=<url>` to run the same tests
    /// against ChaosBank-Server instead of the embedded mock.
    private func injected() -> [String] {
        let env = ProcessInfo.processInfo.environment
        var args: [String] = []
        if let d = env["CB_INJECT_DEFECTS"], !d.isEmpty { args += ["-ChaosBankDefects", d] }
        if let p = env["CB_INJECT_PROFILE"], !p.isEmpty { args += ["-ChaosBankProfile", p] }
        if let b = env["CB_BACKEND"], !b.isEmpty { args += ["-ChaosBankBackend", b] }
        return args
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

/// Every signed number in a ChaosBank label, in order, as en-US formatted:
/// "+€69.52 · +0.40% today" → [69.52, 0.40]; "−$282.72" → [-282.72].
/// The app formats negatives with U+2212 MINUS SIGN, not an ASCII hyphen.
func numbers(in label: String) -> [Double] {
    let regex = try! NSRegularExpression(pattern: "([+\\-\u{2212}]?)[€$£]?([0-9][0-9,]*(?:\\.[0-9]+)?)")
    let ns = label as NSString
    return regex.matches(in: label, range: NSRange(location: 0, length: ns.length)).compactMap { m in
        let sign = ns.substring(with: m.range(at: 1))
        guard let value = Double(ns.substring(with: m.range(at: 2)).replacingOccurrences(of: ",", with: "")) else { return nil }
        return sign == "-" || sign == "\u{2212}" ? -value : value
    }
}

extension KassElement {
    /// The `index`-th signed number in this element's label (see `numbers(in:)`).
    /// Waits for the element first, like every other KassiOS read.
    func number(_ index: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> Double {
        assertExists(file: file, line: line)
        let found = numbers(in: readLabel())
        guard found.indices.contains(index) else {
            XCTFail("no number #\(index) in '\(readLabel())'", file: file, line: line)
            return .nan
        }
        return found[index]
    }

    /// The last signed number in this element's label.
    func lastNumber(file: StaticString = #filePath, line: UInt = #line) -> Double {
        assertExists(file: file, line: line)
        guard let last = numbers(in: readLabel()).last else {
            XCTFail("no number in '\(readLabel())'", file: file, line: line)
            return .nan
        }
        return last
    }
}
