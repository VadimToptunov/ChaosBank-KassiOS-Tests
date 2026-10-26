import XCTest

/// The mock KYC flow and the large-transfer gate it unlocks. Every test starts
/// unverified (`-ChaosBankKycUnverified 1`) and scripts what the "camera" sees,
/// so no hardware and no dev-menu switching is involved.
final class KycTests: CBTestCase {

    /// Opens Card → Verify identity with the given scanner script.
    private func openKyc(document: String = "valid", selfie: String = "match") {
        launchUnlocked(tab: "card", extra: [
            "-ChaosBankKycUnverified", "1",
            "-ChaosBankKycDocument", document,
            "-ChaosBankKycSelfie", selfie,
        ])
        onScreen(CardScreen.self) { card in
            reveal(card.kycButton)   // below the fold on the Card tab
            card.kycButton.tap()
        }
    }

    /// Scan → selfie → submit, then wait for the result.
    private func runFlow(_ kyc: KycScreen) {
        kyc.scanButton.tap()
        kyc.selfieButton.within(timeout: 10).tap()
        kyc.selfieResult.within(timeout: 10).assertExists()
        kyc.submitButton.tap()
        kyc.resultTitle.within(timeout: 10).assertExists()
    }

    /// The happy path verifies the identity, and the Card tab says so.
    /// Catches `kycStuckPending`.
    func test_kyc_happyPath_verifiesTheIdentity() {
        openKyc()
        onScreen(KycScreen.self) { kyc in
            runFlow(kyc)
            kyc.resultTitle.assertLabel("Identity verified")
            kyc.doneButton.tap()
        }
        onScreen(CardScreen.self) { $0.kycStatus.assertLabel("Identity verified") }
    }

    /// An expired document is rejected. Catches `kycAcceptsExpiredDocument`.
    func test_kyc_expiredDocument_isRejected() {
        openKyc(document: "expired")
        onScreen(KycScreen.self) { kyc in
            runFlow(kyc)
            kyc.resultTitle.assertLabel("Verification failed")
            kyc.resultReason.assertLabel("Document expired")
        }
    }

    /// A document in someone else's name is rejected.
    /// Catches `kycNameMismatchAccepted`.
    func test_kyc_documentInAnotherName_isRejected() {
        openKyc(document: "nameMismatch")
        onScreen(KycScreen.self) { kyc in
            runFlow(kyc)
            kyc.resultTitle.assertLabel("Verification failed")
            kyc.resultReason.assertLabel("Name doesn't match the account holder")
        }
    }

    /// A selfie that doesn't match the document is rejected.
    /// Catches `kycSelfieMismatchAccepted`.
    func test_kyc_mismatchedSelfie_isRejected() {
        openKyc(selfie: "mismatch")
        onScreen(KycScreen.self) { kyc in
            runFlow(kyc)
            kyc.resultTitle.assertLabel("Verification failed")
            kyc.resultReason.assertLabel("Face doesn't match the document")
        }
    }

    /// An unreadable scan can't go further: no selfie step, no submit.
    func test_kyc_unreadableDocument_cantBeSubmitted() {
        openKyc(document: "unreadable")
        onScreen(KycScreen.self) { kyc in
            kyc.scanButton.tap()
            kyc.scanError.within(timeout: 10).assertExists()
            kyc.selfieButton.assertNotExists()
            kyc.submitButton.assertDisabled()
        }
    }

    /// While unverified, a transfer over the €1,000 threshold can't continue.
    /// Catches `kycBypassAllowsTransfer`.
    func test_transfer_overKycThreshold_isBlockedWhileUnverified() {
        launchUnlocked(extra: ["-ChaosBankKycUnverified", "1"])
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("2000")
            transfer.continueButton.assertDisabled()
        }
    }

    /// After verifying, the same €2,000 transfer can continue.
    /// Catches `kycStuckPending` end to end (the gate never opens).
    func test_transfer_overKycThreshold_opensAfterVerifying() {
        openKyc()
        onScreen(KycScreen.self) { kyc in
            runFlow(kyc)
            kyc.doneButton.tap()
        }
        onScreen(TabBar.self) { $0.home.tap() }
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.recipientField.typeText("Alex")
            transfer.amountField.typeText("2000")
            transfer.continueButton.assertEnabled()
        }
    }
}
