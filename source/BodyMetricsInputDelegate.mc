import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Uses BehaviorDelegate so that onBack() is invoked by the CIQ runtime for
//! the BACK button. This is the only correct pattern for widget dismissal.
//! onTap() is available because BehaviorDelegate extends InputDelegate.
class BodyMetricsInputDelegate extends WatchUi.BehaviorDelegate {

    var _view;
    var _selectDownTime as Number;
    var _lastKeyReleaseTime as Number;
    const LONG_PRESS_MS = 800;
    const DOUBLE_TAP_WINDOW_MS = 600;

    function initialize(view as BodyMetricsView) {
        BehaviorDelegate.initialize();
        _view = view;
        _selectDownTime = 0;
        _lastKeyReleaseTime = 0;
    }

    // -------------------------------------------------------------------------
    // Touch
    // -------------------------------------------------------------------------

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        if (_view.isInfoIconTap(coords[0], coords[1])) {
            _view.openMetricInfo();
            return true;
        }
        _view.toggleMode();
        return true;
    }

    // -------------------------------------------------------------------------
    // Raw key override — ONLY intercepts KEY_ENTER PRESS_TYPE_DOWN for
    // long-press timing. Everything else is forwarded to BehaviorDelegate.onKey()
    // so the runtime can invoke onBack(), onSelect(), onNextPage(), etc.
    // -------------------------------------------------------------------------

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if ((key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) &&
             evt.getType() == WatchUi.PRESS_TYPE_DOWN) {
            _selectDownTime = System.getTimer();
            return true;
        }
        // Forward to BehaviorDelegate so it can map KEY_ESC→onBack(), etc.
        return BehaviorDelegate.onKey(evt);
    }

    // -------------------------------------------------------------------------
    // Semantic behavior methods (called by BehaviorDelegate.onKey internally)
    // -------------------------------------------------------------------------

    //! BACK button → exit widget at root, navigate back in sub-screens.
    function onBack() as Boolean {
        _view.logBackInputEvent("BACK", "onBack_called");
        if (_view.isSummaryMode()) {
            // Return false: the CIQ runtime dismisses the widget naturally.
            _view.logBackInputEvent("BACK", "summary_return_false_dismiss");
            return false;
        }
        var handled = _view.handleBack();
        _view.logBackInputEvent("BACK", handled ? "handled" : "pass_to_os");
        return handled;
    }

    //! SELECT / ENTER button release — includes long-press and double-tap detection.
    function onSelect() as Boolean {
        var downTime = _selectDownTime;
        var currentTime = System.getTimer();
        _selectDownTime = 0;

        if (downTime > 0 && _view.isSummaryMode()) {
            if (currentTime - downTime >= LONG_PRESS_MS) {
                _view.openMetricInfo();
                _lastKeyReleaseTime = currentTime;
                return true;
            }
        }

        if (downTime == 0) {
            var timeSinceLastRelease = currentTime - _lastKeyReleaseTime;
            if (_lastKeyReleaseTime > 0 && timeSinceLastRelease < DOUBLE_TAP_WINDOW_MS) {
                _view.openMetricInfo();
                _lastKeyReleaseTime = 0;
                return true;
            }
        }

        _view.toggleMode();
        _lastKeyReleaseTime = currentTime;
        return true;
    }

    //! DOWN button / DOWN swipe → next metric.
    function onNextPage() as Boolean {
        _view.nextMetric();
        return true;
    }

    //! UP button / UP swipe → previous metric.
    function onPreviousPage() as Boolean {
        _view.previousMetric();
        return true;
    }

    //! MENU button → open menu.
    function onMenu() as Boolean {
        return _openMenu();
    }

    // -------------------------------------------------------------------------
    // Swipe (directional, beyond next/prev page)
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
        if (_view.canOpenMenu()) {
            _view.openMenu();
        }
        return true;
    }
}

