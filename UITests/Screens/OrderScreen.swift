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

    /// The Place button lives in the confirm sheet, which may propagate its
    /// `order.confirmSheet` id onto children (as the transfer sheet does), so we
    /// accept either id and pin it by its "Place order" label.
    lazy var placeButton = custom("order place button") { [app] in
        app.buttons.matching(
            NSPredicate(format: "(identifier == %@ OR identifier == %@) AND label == %@",
                        "order.placeButton", "order.confirmSheet", "Place order")
        ).firstMatch
    }

    override var onLoad: [KassElement] { [qtyValue] }
}
