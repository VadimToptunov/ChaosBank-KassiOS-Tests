import XCTest

/// The auth ladder, shown on a fresh (locked) launch:
/// gate → WKWebView web login → OTP (424242, auto-submits at 6 digits) →
/// passcode setup (6 digits, auto-submits) → unlocked.
///
/// The web login lives in a WKWebView, reached via `app.webViews`.
final class AuthLadderScreen: CBScreen {
    /// The gate's "Log in" button (opens the web sign-in sheet).
    lazy var loginButton = button("auth.webLoginButton")

    lazy var webSheet = anyEl("auth.webSheet")

    /// The code field of the *current* stage. Re-resolved each use, it is the OTP
    /// field, then the passcode field.
    var codeField: KassElement {
        custom("current auth code field") { [app] in
            app.textFields.matching(NSPredicate(
                format: "identifier IN %@", ["auth.otpField", "auth.passcodeField"]
            )).firstMatch
        }
    }

    // The web form (id="web-username" / "web-password" / "web-submit"), inside the
    // WKWebView — exactly one text field, one secure field and one button.
    var webUsername: KassElement {
        custom("web username field") { [app] in app.webViews.textFields.firstMatch }
    }
    var webPassword: KassElement {
        custom("web password field") { [app] in app.webViews.secureTextFields.firstMatch }
    }
    var webSubmit: KassElement {
        custom("web 'Log in' button") { [app] in
            app.webViews.buttons
                .matching(NSPredicate(format: "label == %@ OR identifier == %@", "Log in", "web-submit"))
                .firstMatch
        }
    }

    /// Submits the web form. Right after typing, WKWebView's input accessory bar
    /// ("^ v ✓") can sit on top of the "Log in" button, so a tap lands on the bar
    /// instead; close the bar with its Done button first.
    func submitWebLogin() {
        let done = app.toolbars.buttons["Done"]
        if done.exists && done.isHittable { done.tap() }
        webSubmit.tap()
    }

    lazy var otpError = anyEl("auth.otpError")
    lazy var passcodeStage = anyEl("auth.passcode")

    override var onLoad: [KassElement] { [anyEl("auth.gate")] }
}
