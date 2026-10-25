import XCTest

/// The hidden developer menu (long-press or triple-tap the build badge, or
/// launch with `-ChaosBankShowDev 1`, to present it). Used here only for its
/// network-condition selector — a non-defect, environmental knob (see
/// `NetworkCondition`) — to widen a race window for concurrency tests (e.g.
/// `exchangeDoubleSubmit`) well past what a UI test's own tap-to-tap gap can
/// land inside on its own.
final class DevMenuScreen: CBScreen {
    lazy var closeButton = anyEl("dev.close")

    /// A network-condition segment by its label ("Normal", "Offline", "Slow",
    /// "Flaky"), located by its `dev.networkCondition.<kind>` identifier.
    func networkCondition(_ label: String) -> KassElement {
        button("dev.networkCondition.\(label.lowercased())")
    }

    override var onLoad: [KassElement] { [closeButton] }
}
