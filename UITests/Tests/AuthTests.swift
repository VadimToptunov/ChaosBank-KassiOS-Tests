import XCTest

/// The auth ladder. `-ChaosBankStartUnlocked 1` boots straight to home (the
/// affordance every other test relies on); a fresh launch runs the full
/// login → web → OTP → passcode ladder driven here end to end.
final class AuthTests: CBTestCase {

    /// The unlock affordance the rest of the suite depends on.
    func test_startUnlocked_reachesHome() {
        launchUnlocked()
        onScreen(HomeScreen.self) { $0.totalBalance.assertVisible() }
    }

    /// A fresh (locked) launch lands on the login gate with its Log-in entry.
    func test_freshLaunch_showsLoginGate() {
        launchFresh()
        onScreen(AuthLadderScreen.self) { $0.loginButton.assertVisible() }
    }

    /// The whole ladder, end to end: open the WKWebView login, submit credentials
    /// through the web context, pass OTP `424242` (auto-submits at 6 digits) and
    /// set a 6-digit passcode (auto-submits) → the unlocked home.
    func test_fullAuthLadder_reachesHome() {
        launchFresh()
        onScreen(AuthLadderScreen.self) { auth in
            auth.loginButton.tap()
            auth.webSheet.within(timeout: 15).assertExists()
            auth.webUsername.within(timeout: 15).typeText("tester")
            auth.webPassword.typeText("hunter2")
            auth.webSubmit.tap()
            auth.codeField.within(timeout: 15).typeText("424242")      // OTP, auto-submits
            auth.codeField.within(timeout: 15).typeText("135790")      // passcode, auto-submits
        }
        onScreen(HomeScreen.self) { $0.totalBalance.within(timeout: 15).assertVisible() }
    }
}
