import XCTest

/// Card → Verify identity: the mock KYC flow (document → selfie → submit → result).
/// What the scanner and the face check return is set at launch with
/// `-ChaosBankKycDocument` and `-ChaosBankKycSelfie`.
/// Reference defects: `kycAcceptsExpiredDocument`, `kycNameMismatchAccepted`,
/// `kycSelfieMismatchAccepted`, `kycStuckPending`.
final class KycScreen: CBScreen {
    lazy var passport = button("kyc.doc.passport")
    lazy var idCard = button("kyc.doc.idCard")
    lazy var scanButton = button("kyc.scanButton")
    lazy var scanError = anyEl("kyc.scanError")
    lazy var docName = anyEl("kyc.docName")
    lazy var docNumber = anyEl("kyc.docNumber")
    lazy var docExpiry = anyEl("kyc.docExpiry")
    lazy var selfieButton = button("kyc.selfieButton")
    lazy var selfieResult = anyEl("kyc.selfieResult")
    lazy var submitButton = button("kyc.submitButton")
    lazy var resultTitle = anyEl("kyc.resultTitle")
    lazy var resultReason = anyEl("kyc.resultReason")
    lazy var doneButton = button("kyc.doneButton")

    override var onLoad: [KassElement] { [scanButton] }
}
