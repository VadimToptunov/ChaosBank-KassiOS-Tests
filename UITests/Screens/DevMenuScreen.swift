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

    /// A locale option by its raw value ("enUS", "deDE", "ar").
    func locale(_ id: String) -> KassElement { button("dev.locale.\(id)") }
    lazy var localeSample = anyEl("dev.localeSample")
    lazy var localeCurrencySample = anyEl("dev.localeCurrencySample")
    lazy var tokenStorage = anyEl("dev.tokenStorage")
    lazy var syncButton = anyEl("dev.sync")

    override var onLoad: [KassElement] { [closeButton] }
}

/// The dev-menu Sync playground: runs a batch of concurrent +1 updates on a
/// shared backend counter. Reference defect: `syncLostUpdate`.
final class SyncScreen: CBScreen {
    lazy var counter = anyEl("sync.counter")
    lazy var expected = anyEl("sync.expected")
    lazy var runButton = button("sync.runButton")
    lazy var resetButton = button("sync.resetButton")

    override var onLoad: [KassElement] { [runButton] }
}
