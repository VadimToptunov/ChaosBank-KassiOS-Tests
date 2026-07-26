import XCTest

/// Reference suite for the **UIKit "views" build** (`-ChaosBankUIKit 1`).
///
/// These are the exact same screens as the SwiftUI build, rendered with UIKit and
/// reusing the same ViewModels, so the same screen objects / locators apply. Every
/// test asserts *clean* behaviour; the buggy-matrix step re-runs them with a single
/// UIKit-characteristic defect injected (`TEST_RUNNER_CB_INJECT_DEFECTS=…`), which
/// flips each one red — proving the defect is both live and caught.
///
/// Coverage (one clean-pass per defect):
///   toggleInitialStateNotBound · switchChangeNotHandled · fieldEditNotCommitted
///   controlActionNotWired · listNotClearedOnReload · rowTapOpensWrongItem
///   labelNotFormatted · rowLocatorMissing · submitEnabledWhenInvalid · outputNotRecomputed
///
/// (The two Transactions cell-reuse defects — `listCellReuseBleed`,
/// `listRecycledA11yStale` — need a long-list scroll and are covered separately.)
final class UIKitViewsTests: CBTestCase {

    // MARK: Card

    /// Online payments defaults to on in the model, so the switch must load on.
    /// `toggleInitialStateNotBound` leaves it at the hardcoded off → red.
    func test_uikit_card_onlineToggle_reflectsModelOnLoad() {
        launchUIKit(tab: "card")
        onScreen(CardScreen.self) { card in
            card.onlinePaymentsToggle.assertHasValue("1")
        }
    }

    /// Flipping freeze on must surface the FROZEN badge. `switchChangeNotHandled`
    /// never wires the freeze handler, so the badge never appears → red.
    func test_uikit_card_freeze_showsFrozenBadge() {
        launchUIKit(tab: "card")
        onScreen(CardScreen.self) { card in
            card.frozenBadgeUIKit.assertNotExists()      // not frozen on launch
            card.freezeToggle.setSwitch(on: true)
            card.frozenBadgeUIKit.within(timeout: 10).assertPresent()
        }
    }

    /// Clearing the limit makes it invalid, so the error label — derived from the
    /// *model* — must appear. `fieldEditNotCommitted` drops the edit, so the model
    /// keeps the valid "2000" and no error shows → red.
    func test_uikit_card_limitEdit_commitsToModel() {
        launchUIKit(tab: "card")
        onScreen(CardScreen.self) { card in
            card.limitError.assertNotExists()            // valid "2000" on launch
            card.limitField.tap()
            card.limitClearButton.tap()                  // empty ⇒ invalid
            card.limitError.within(timeout: 5).assertPresent()
        }
    }

    // MARK: Markets

    /// Tapping the Crypto segment switches the list to crypto (ETH is crypto-only,
    /// not on the watchlist). `controlActionNotWired` never binds the segment
    /// action, so the list stays on the watchlist and ETH never appears → red.
    func test_uikit_markets_cryptoSegment_switchesList() {
        launchUIKit(tab: "markets")
        onScreen(MarketsScreen.self) { markets in
            markets.cryptoSegment.tap()
            markets.assetCell("ETH").within(timeout: 5).assertVisible()
        }
    }

    /// Switching segments must replace the list, so after Stocks → Crypto the
    /// stock AAPL is gone. `listNotClearedOnReload` appends instead, so AAPL
    /// lingers from the earlier segment → red.
    func test_uikit_markets_switchingSegment_replacesList() {
        launchUIKit(tab: "markets")
        onScreen(MarketsScreen.self) { markets in
            markets.stocksSegment.tap()
            markets.assetCell("AAPL").within(timeout: 5).assertVisible()
            markets.cryptoSegment.tap()
            markets.assetCell("ETH").within(timeout: 5).assertVisible()
            markets.assetCell("AAPL").assertNotExists()
        }
    }

    /// Tapping a row pushes that row's asset detail (chart + stats), like the
    /// SwiftUI build. `rowTapOpensWrongItem` / `assetRowOpensWrongDetail` open the
    /// next row (off-by-one), so the detail names NVIDIA instead of Apple → red.
    func test_uikit_markets_rowTap_opensTappedAsset() {
        launchUIKit(tab: "markets")
        onScreen(MarketsScreen.self) { $0.assetCell("AAPL").tap() }
        onScreen(AssetScreen.self) { asset in
            asset.price.assertVisible()
            asset.symbol.assertLabelContains("Apple")
        }
    }

    // MARK: Portfolio

    /// The total is rendered through the currency formatter — grouped, with a
    /// symbol. `labelNotFormatted` binds the raw Decimal (no grouping comma) → red.
    func test_uikit_portfolio_total_isCurrencyFormatted() {
        launchUIKit(tab: "portfolio")
        onScreen(PortfolioScreen.self) { portfolio in
            portfolio.totalValue.assertLabelContains(",")
        }
    }

    /// Each holding row exposes its per-symbol locator. `rowLocatorMissing` never
    /// sets it, so `portfolio.holding.AAPL` can't be found → red.
    func test_uikit_portfolio_holdingRow_hasLocator() {
        launchUIKit(tab: "portfolio")
        onScreen(PortfolioScreen.self) { portfolio in
            portfolio.holding("AAPL").within(timeout: 5).assertExists()
        }
    }

    // MARK: Transfer

    /// Continue tracks form validity, so it's disabled on the empty form.
    /// `submitEnabledWhenInvalid` leaves it enabled → red.
    func test_uikit_transfer_continueDisabledWhenInvalid() {
        launchUIKit()
        onScreen(HomeScreen.self) { $0.transferAction.tap() }
        onScreen(TransferScreen.self) { transfer in
            transfer.continueButton.assertDisabled()
        }
    }

    // MARK: Exchange

    /// "You get" recomputes when the amount changes: 1000 EUR → USD at 1.08 minus
    /// the 0.5% fee is $1,074.60. `outputNotRecomputed` skips the recompute, so it
    /// stays at the initial $0.00 → red.
    func test_uikit_exchange_youGet_recomputesOnAmountChange() {
        launchUIKit()
        onScreen(HomeScreen.self) { $0.exchangeAction.tap() }
        onScreen(ExchangeScreen.self) { exchange in
            exchange.youGet.assertLabelContains("0.00")          // initial, empty amount
            exchange.amountField.tap()
            exchange.amountField.typeText("1000")
            exchange.youGet.within(timeout: 5).assertLabel("$1,074.60")
        }
    }
}
