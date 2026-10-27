import XCTest

/// Card data, the auth ladder and storage. Before these, the `security` profile
/// turned only `CardTests.test_card_cvv_hiddenByDefault` red.
final class SecurityTests: CBTestCase {

    // MARK: Card data

    /// The card number is masked except the last four digits.
    /// Catches `cardNumberFullyVisible`.
    func test_card_number_isMaskedExceptTheLastFour() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { card in
            card.pan.assertExists()
            let label = card.pan.readLabel()
            XCTAssertNotNil(label.range(of: #"^•••• •••• •••• \d{4}$"#, options: .regularExpression),
                            "PAN should be masked: '\(label)'")
        }
    }

    /// "Show PIN" doesn't reveal the PIN in the clear.
    /// Catches `pinShownPlaintext`.
    func test_card_showPin_keepsThePinMasked() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { $0.pinButton.tap() }
        let message = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Your PIN is")).firstMatch
        XCTAssertTrue(message.waitForExistence(timeout: 10), "PIN message should appear")
        XCTAssertEqual(message.label, "Your PIN is ••••")
    }

    /// A virtual card gets its own number, not the real card's.
    /// Catches `virtualCardShowsRealPan`.
    func test_card_virtualCard_doesNotReuseTheRealNumber() {
        launchUnlocked(tab: "card")
        onScreen(CardScreen.self) { card in
            card.pan.assertExists()
            let realLastFour = String(card.pan.readLabel().suffix(4))
            card.virtualButton.tap()
            card.virtualNumber.within(timeout: 10).assertExists()
            let virtual = card.virtualNumber.readLabel()
            XCTAssertFalse(virtual.replacingOccurrences(of: " ", with: "").hasSuffix(realLastFour),
                           "virtual card '\(virtual)' should not end like the real one (\(realLastFour))")
        }
    }

    // MARK: Auth ladder

    /// Gets a fresh launch to the OTP stage.
    private func reachOtp() {
        launchFresh()
        onScreen(AuthLadderScreen.self) { auth in
            auth.loginButton.tap()
            auth.webUsername.within(timeout: 15).typeText("tester")
            auth.webPassword.typeText("hunter2")
            auth.webSubmit.tap()   // KassiOS dismisses the keyboard and its accessory bar first
            auth.codeField.within(timeout: 15).assertExists()
        }
    }

    /// A wrong OTP is rejected. Catches `otpAcceptsAnyCode`.
    func test_otp_wrongCode_isRejected() {
        reachOtp()
        onScreen(AuthLadderScreen.self) { auth in
            auth.codeField.typeText("000000")
            auth.otpError.within(timeout: 10).assertExists()
            auth.passcodeStage.assertNotExists()
        }
    }

    /// After three wrong codes, even the right one is refused until a resend.
    /// Catches `otpNoLockout`.
    func test_otp_threeWrongCodes_lockTheStep() {
        reachOtp()
        onScreen(AuthLadderScreen.self) { auth in
            for _ in 0..<3 {
                auth.codeField.replaceText("000000")
                auth.otpError.within(timeout: 10).assertExists()
            }
            auth.codeField.replaceText("424242")
            auth.otpError.within(timeout: 10).assertLabelContains("locked")
            auth.passcodeStage.assertNotExists()
        }
    }

    /// A deep link opened while locked doesn't skip the auth gate.
    /// Catches `deepLinkSkipsAuth`.
    func test_deepLink_whileLocked_keepsTheAuthGate() {
        launchFresh()
        onScreen(AuthLadderScreen.self) { $0.loginButton.assertExists() }
        app.open(URL(string: "chaosbank://markets")!)
        onScreen(AuthLadderScreen.self) { auth in
            RunLoop.current.run(until: Date().addingTimeInterval(2))
            auth.loginButton.assertVisible()
        }
    }

    // MARK: Storage

    /// After a real login, the session token is in the Keychain, as the dev
    /// menu reports. Catches `tokenInUserDefaults`.
    func test_login_storesTheTokenInTheKeychain() {
        reachOtp()
        onScreen(AuthLadderScreen.self) { auth in
            auth.codeField.typeText("424242")
            auth.codeField.within(timeout: 15).typeText("135790")
        }
        onScreen(HomeScreen.self) { $0.buildBadge.within(timeout: 15).longPress(forDuration: 0.6) }
        onScreen(DevMenuScreen.self) { $0.tokenStorage.assertLabelContains("Keychain") }
    }
}
