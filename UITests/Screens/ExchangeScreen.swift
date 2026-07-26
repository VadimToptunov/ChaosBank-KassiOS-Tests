import XCTest

/// FX exchange, presented as a sheet from Home's Exchange quick action.
/// Reference defects on this flow: `roundingDrift`, `exchangeFeeNotApplied`,
/// `exchangeDoubleSubmit` (see the app's exercises.json).
final class ExchangeScreen: CBScreen {
    lazy var amountField = textField("exchange.amountField")
    lazy var sellCurrency = anyEl("exchange.sellCurrency")
    lazy var getCurrency = anyEl("exchange.getCurrency")
    lazy var rate = anyEl("exchange.rate")
    lazy var fee = anyEl("exchange.fee")
    lazy var youGet = anyEl("exchange.youGet")
    lazy var executeButton = button("exchange.executeButton")
    lazy var successToast = anyEl("exchange.successToast")

    // The amount field is the load proof (the sheet's container id isn't queryable).
    override var onLoad: [KassElement] { [amountField] }
}
