import XCTest

/// Auth affordance. The full login → OTP → passcode ladder runs through a
/// deliberately-hostile WKWebView and only appears on re-lock (background/idle),
/// not on a fresh launch — driving it is a focused follow-up. Here we cover the
/// unlock affordance that every other test relies on.
final class AuthTests: CBTestCase {

    /// `-ChaosBankStartUnlocked 1` boots straight to the unlocked home.
    func test_startUnlocked_reachesHome() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.totalBalance.assertVisible() }
    }
}
