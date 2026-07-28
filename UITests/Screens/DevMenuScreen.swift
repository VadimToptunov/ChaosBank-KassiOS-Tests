import XCTest

/// The hidden developer menu (long-press or triple-tap the build badge, or
/// launch with `-ChaosBankShowDev 1`, to present it). Used here only for its
/// network-condition selector — a non-defect, environmental knob (see
/// `NetworkCondition`) — to widen a race window for concurrency tests (e.g.
/// `exchangeDoubleSubmit`) well past what a UI test's own tap-to-tap gap can
/// land inside on its own.
final class DevMenuScreen: CBScreen {
    lazy var closeButton = anyEl("dev.close")

    /// A network-condition segment ("Normal", "Offline", "Slow", "Flaky").
    /// `SegmentBar` propagates its own `dev.networkCondition` container id onto
    /// every option, clobbering each option's more specific
    /// `dev.networkCondition.<kind>` id (same SwiftUI quirk as elsewhere in
    /// this app), so — like `TransferScreen.confirmButton` — match by the
    /// shared id plus the option's visible label instead.
    func networkCondition(_ label: String) -> KassElement {
        button(id: "dev.networkCondition", label: label)
    }

    override var onLoad: [KassElement] { [closeButton] }
}
