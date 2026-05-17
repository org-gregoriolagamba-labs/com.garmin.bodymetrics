import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Uses BehaviorDelegate so that onBack() is invoked by the CIQ runtime for
//! the BACK button. This is the only correct pattern for widget dismissal.
//! onTap() is available because BehaviorDelegate extends InputDelegate.
class BodyMetricsInputDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    // Rapid-press acceleration for wizard edit mode.
    //
    // IMPORTANT: BehaviorDelegate dispatch order — the runtime calls the
    // behavior method (onNextPage / onPreviousPage) FIRST. Only when it returns
    // false does the runtime also call the raw onKey(). Therefore the rapid-press
    // logic must live in onNextPage() / onPreviousPage(), not in onKey().
    //
    // On FR265, long press DOWN opens the Music Player (OS-level, cannot be
    // intercepted). Long press UP fires onMenu() directly — the runtime never
    // delivers PRESS_TYPE_DOWN for KEY_UP in that case. Hold-duration detection
    // is therefore unreliable and is not used.
    //
    // Instead, each short press increments a streak counter while the user
    // keeps pressing the same button within RAPID_THRESHOLD_MS. The step
    // multiplier grows with the streak:
    //   1–2 presses  → ×1
    //   3–5 presses  → ×5
    //   6–9 presses  → ×10
    //   ≥10 presses  → ×50
    // The streak resets when direction changes or the gap exceeds the threshold.
    var _lastPressTime as Number;  // System.getTimer() of last wizard press
    var _rapidCount    as Number;  // consecutive rapid presses in the same direction
    var _rapidDir      as Number;  // +1 = DOWN, -1 = UP, 0 = none

    const RAPID_THRESHOLD_MS = 600; // gap below this → rapid consecutive press

    function initialize(view as BodyMetricsView) {
        BehaviorDelegate.initialize();
        _view = view;
        _lastPressTime = 0;
        _rapidCount    = 0;
        _rapidDir      = 0;
    }

    function _rapidMultiplier() as Number {
        if (_rapidCount >= 10) { return 50; }
        if (_rapidCount >=  6) { return 10; }
        if (_rapidCount >=  3) { return  5; }
        return 1;
    }

    // -------------------------------------------------------------------------
    // Touch
    // -------------------------------------------------------------------------

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        _view.toggleMode();
        return true;
    }

    // -------------------------------------------------------------------------
    // Raw key override — only used for KEY_MENU safety net in wizard mode.
    // UP/DOWN are handled by onNextPage()/onPreviousPage() which the runtime
    // calls BEFORE onKey(), so the UP/DOWN block here is never reached for
    // those events.
    // -------------------------------------------------------------------------

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        // Safety net: block KEY_MENU in wizard mode in case the runtime routes
        // it through onKey() rather than onMenu() on some devices.
        if (key == WatchUi.KEY_MENU && _view.isWizardEditMode()) {
            return true;
        }
        return BehaviorDelegate.onKey(evt);
    }

    // -------------------------------------------------------------------------
    // Rapid-press step helper
    // -------------------------------------------------------------------------

    function _applyRapidStep(dir as Number) as Void {
        var now = System.getTimer();
        if (dir == _rapidDir && (now - _lastPressTime) < RAPID_THRESHOLD_MS) {
            _rapidCount += 1;
        } else {
            _rapidCount = 1;
            _rapidDir   = dir;
        }
        _lastPressTime = now;
        var mul = _rapidMultiplier();
        if (dir > 0) {
            _view.nextMetricBy(mul);
        } else {
            _view.previousMetricBy(mul);
        }
    }

    // -------------------------------------------------------------------------
    // Semantic behavior methods
    // -------------------------------------------------------------------------

    //! MENU behavior (= long press UP on FR265) — called DIRECTLY by the CIQ
    //! runtime, bypassing onKey(). In wizard edit mode we consume it to prevent
    //! the main menu from opening. Outside wizard mode, open menu.
    function onMenu() as Boolean {
        if (_view.isWizardEditMode()) {
            return true;
        }
        return _openMenu();
    }

    //! BACK button → exit widget at root, navigate back in sub-screens.
    function onBack() as Boolean {
        _view.logBackInputEvent("BACK", "onBack_called");
        if (_view.isSummaryMode()) {
            _view.logBackInputEvent("BACK", "summary_return_false_dismiss");
            return false;  // CIQ runtime dismisses the widget.
        }
        var handled = _view.handleBack();
        _view.logBackInputEvent("BACK", handled ? "handled" : "pass_to_os");
        return handled;
    }

    //! SELECT / ENTER → toggle mode (detail/summary).
    function onSelect() as Boolean {
        _view.toggleMode();
        return true;
    }

    //! DOWN button → next metric (non-wizard) or accelerated step (wizard).
    //! Called by the runtime BEFORE onKey() for the DOWN button short press.
    function onNextPage() as Boolean {
        if (_view.isWizardEditMode()) {
            _applyRapidStep(1);
            return true;
        }
        _view.nextMetric();
        return true;
    }

    //! UP button → previous metric (non-wizard) or accelerated step (wizard).
    //! Called by the runtime BEFORE onKey() for the UP button short press.
    function onPreviousPage() as Boolean {
        if (_view.isWizardEditMode()) {
            _applyRapidStep(-1);
            return true;
        }
        _view.previousMetric();
        return true;
    }

    // -------------------------------------------------------------------------
    // Swipe
    // -------------------------------------------------------------------------

    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            _view.handleSwipeUp();
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _view.handleSwipeDown();
            return true;
        }
        return false;
    }

    // -------------------------------------------------------------------------

    function _openMenu() as Boolean {
        _view.openMenu();
        return true;
    }
}


