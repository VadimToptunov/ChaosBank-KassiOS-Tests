import XCTest

/// The auth ladder, shown on a fresh (locked) launch:
/// gate → WKWebView web login → OTP (424242, auto-submits at 6 digits) →
/// passcode setup (6 digits, auto-submits) → unlocked.
///
/// The gate ("Welcome back" / "Log in") applies `auth.gate` to its container and
/// SwiftUI propagates that id onto every child, so the Log-in button is matched by
/// id + label. The web login lives in a WKWebView, reached via `app.webViews`.
final class AuthLadderScreen: CBScreen {
    /// The gate's "Log in" button (opens the web sign-in sheet).
    var loginButton: KassElement {
        custom("gate 'Log in' button") { [app] in
            app.buttons.matching(identifier: "auth.gate")
                .matching(NSPredicate(format: "label == %@", "Log in")).firstMatch
        }
    }

    lazy var webSheet = anyEl("auth.webSheet")

    /// Every ladder stage (gate / OTP / passcode) wraps its content in `auth.gate`,
    /// and SwiftUI propagates that id onto every child — so the single text field on
    /// the *current* stage is matched by that id (not auth.otpField / passcodeField).
    /// Re-resolved each use, it is the OTP field, then the passcode field.
    var codeField: KassElement {
        custom("current auth text field") { [app] in
            app.textFields.matching(identifier: "auth.gate").firstMatch
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

    override var onLoad: [KassElement] { [anyEl("auth.gate")] }
}
