import XCTest

/// Personal-loan screen (pushed from the Card tab's "Explore a loan"): APR,
/// monthly payment and total repayable. Reference defect: `loanAprUnderstated`
/// (the payment reflects a higher rate than the advertised APR).
final class LoansScreen: CBScreen {
    lazy var root = anyEl("loans.root")
    lazy var apr = anyEl("loans.apr")
    lazy var monthly = anyEl("loans.monthly")
    lazy var total = anyEl("loans.total")

    override var onLoad: [KassElement] { [apr] }
}
