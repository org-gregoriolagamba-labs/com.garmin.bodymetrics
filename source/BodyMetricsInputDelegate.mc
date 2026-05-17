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
    // On FR265, long press of DOWN opens the Music Player (OS-level, cannot be
    // intercepted). Long press of UP fires onMenu() directly — the runtime
    // never delivers PRESS_TYPE_DOWN for KEY_UP in that case. Therefore
    // hold-duration detection is unreliable and is NOT used.
    //
    // Instead, each short press (PRESS_TYPE_ACTION) increments a streak counter
    // while the user keeps pressing the same button within RAPID_THRESHOLD_MS.
    // The step multiplier grows with the streak:
    //   1–2 presses  → ×1
    //   3–5 presses  → ×5
    //   6–9 presses  → ×10
    //   ≥10 presses  → ×50
    // The streak resets when direction changes or the gap exceeds the threshold.
    var _lastPressTime as Number;  // System.getTimer() of last wizard press
    var _rapidCount    as Number;  // consecutive rapid presses in the same direction
    var _rapidDir      as Number;  // +1 = DOWN, -1 = UP, 0 = none

    const RAPID_THRESHOLD_MS = 500; // gap below this → rapid consecutive press

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
    // Raw key override — intercepts UP/DOWN in wizard edit mode.
    // PRESS_TYPE_ACTION applies a step (with rapid-press acceleration).
    // PRESS_TYPE_DOWN / PRESS_TYPE_UP are consumed silently so the runtime
    // does not double-call onNextPage()/onPreviousPage() in wizard mode.
    // Everything else is forwarded to BehaviorDelegate.onKey().
    // -------------------------------------------------------------------------

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        var pressType = evt.getType();

        if ((key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) && _view.isWizardEditMode()) {
            if (pressType == WatchUi.PRESS_TYPE_ACTION) {
                var dir = (key == WatchUi.KEY_DOWN) ? 1 : -1;
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
                return true;
            }
            // Consume PRESS_TYPE_DOWN and PRESS_TYPE_UP silently.
            return true;
        }

        // On FR265, long press UP fires KEY_MENU via onMenu() — also block it
        // here in case the runtime routes it through onKey() on other devices.
        if (key == WatchUi.KEY_MENU && _view.isWizardEditMode()) {
            return true;
        }

        // Forward to BehaviorDelegate: KEY_ESC→onBack(), UP/DOWN→onPreviousPage/onNextPage(), etc.
        return BehaviorDelegate.onKey(evt);
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

    //! DOWN button → next metric / decrease value in wizard.
    //! In non-wizard modes this is called directly by the runtime.
    //! In wizard mode, onKey handles it with adaptive step.
    function onNextPage() as Boolean {
        _view.nextMetric();
        return true;
    }

    //! UP button → previous metric / increase value in wizard.
    function onPreviousPage() as Boolean {
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


