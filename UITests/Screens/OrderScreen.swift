import XCTest

/// Order ticket (pushed from an asset's Buy/Sell): quantity stepper, market/limit
/// type, review → confirm sheet → place → status toast.
/// Reference defects: `limitValidation`, `orderStuckPending`, `missingA11yLabel`,
/// `qtyIncrementByTwo`, `orderQtyDefaultsZero`.
final class OrderScreen: CBScreen {
    lazy var root = anyEl("order.root")
    lazy var refPrice = anyEl("order.refPrice")
    lazy var qtyValue = anyEl("order.qtyStepper.value")
    lazy var qtyIncrement = button("order.qtyStepper.increment")
    lazy var qtyDecrement = button("order.qtyStepper.decrement")
    lazy var reviewButton = button("order.reviewButton")
    lazy var warning = anyEl("order.warning")
    lazy var statusToast = anyEl("order.statusToast")

    /// The Place button in the confirm sheet.
    lazy var placeButton = button("order.placeButton")

    override var onLoad: [KassElement] { [qtyValue] }
}
