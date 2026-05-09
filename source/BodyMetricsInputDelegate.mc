import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Uses InputDelegate (not BehaviorDelegate) to receive raw onTap
//! coordinates, needed to detect taps on the (i) info icon.
class BodyMetricsInputDelegate extends WatchUi.InputDelegate {

    var _view;
    var _selectDownTime as Number;
    var _lastKeyReleaseTime as Number;
    var _backDownSeen as Boolean;
    const LONG_PRESS_MS = 800;
    const DOUBLE_TAP_WINDOW_MS = 600;

    function initialize(view as BodyMetricsView) {
        InputDelegate.initialize();
        _view = view;
        _selectDownTime = 0;
        _lastKeyReleaseTime = 0;
        _backDownSeen = false;
    }

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        var coords = evt.getCoordinates();
        if (_view.isInfoIconTap(coords[0], coords[1])) {
            _view.openMetricInfo();
            return true;
        }
        // Tap anywhere else on screen = SELECT
        _view.toggleMode();
        return true;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.previousMetric();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            _view.nextMetric();
            return true;
        }
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            var pressType = evt.getType();
            if (pressType == WatchUi.PRESS_TYPE_DOWN) {
                _selectDownTime = System.getTimer();
                return true;
            }
            // PRESS_TYPE_ACTION = release
            var downTime = _selectDownTime;
            var currentTime = System.getTimer();
            _selectDownTime = 0;
            
            
            // Check for traditional long-press (with PRESS_TYPE_DOWN timing)
            if (downTime > 0 && _view.isSummaryMode()) {
                var held = currentTime - downTime;
                if (held >= LONG_PRESS_MS) {
                    _view.openMetricInfo();
                    _lastKeyReleaseTime = currentTime;
                    return true;
                }
            }
            
            // Simulator fallback: if downTime is 0 (PRESS_TYPE_DOWN not received),
            // use double-tap detection as a long-press substitute
            if (downTime == 0) {
                var timeSinceLastRelease = currentTime - _lastKeyReleaseTime;
                if (_lastKeyReleaseTime > 0 && timeSinceLastRelease < DOUBLE_TAP_WINDOW_MS) {
                    _view.openMetricInfo();
                    _lastKeyReleaseTime = 0;  // Reset to prevent triple-tap
                    return true;
                }
            }
            
            _view.toggleMode();
            _lastKeyReleaseTime = currentTime;
            return true;
        }
        if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            var backPressType = evt.getType();
            _view.logBackInputEvent(_pressTypeName(backPressType), "received");

            if (_view.isSummaryMode()) {
                if (backPressType == WatchUi.PRESS_TYPE_DOWN) {
                    // Device sends DOWN before ACTION. Consume and wait for ACTION.
                    _backDownSeen = true;
                    _view.logBackInputEvent(_pressTypeName(backPressType), "summary_down_consumed_wait_action");
                    return true;
                }

                if (backPressType == WatchUi.PRESS_TYPE_ACTION) {
                    var hadDown = _backDownSeen;
                    _backDownSeen = false;
                    if (hadDown) {
                        _view.logBackInputEvent(_pressTypeName(backPressType), "summary_action_with_down_try_exit");
                        _safeExitFromSummary();
                        return true;
                    } else {
                        // ACTION-only path is typically simulator behavior; keep it safe to avoid root-exit crashes.
                        _view.logBackInputEvent(_pressTypeName(backPressType), "summary_action_without_down_safe_consume");
                        return true;
                    }
                }

                _backDownSeen = false;
                _view.logBackInputEvent(_pressTypeName(backPressType), "summary_other_pass_system");
                return false;
            }

            _backDownSeen = false;
            if (backPressType == WatchUi.PRESS_TYPE_DOWN) {
                // Consume key-down and decide behavior on key release only.
                _view.logBackInputEvent(_pressTypeName(backPressType), "non_summary_consume_down");
                return true;
            }
            if (backPressType != WatchUi.PRESS_TYPE_ACTION) {
                _view.logBackInputEvent(_pressTypeName(backPressType), "non_summary_ignore_non_action");
                return true;
            }
            _view.logBackInputEvent(_pressTypeName(backPressType), "non_summary_delegate_to_view");
            return _view.handleBack();
        }
        if (key == WatchUi.KEY_MENU) {
            return _openMenu();
        }
        return false;
    }

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

    function _openMenu() as Boolean {
        if (_view.canOpenMenu()) {
            _view.openMenu();
        }
        return true;
    }

    function _pressTypeName(pressType as Number) as String {
        if (pressType == WatchUi.PRESS_TYPE_DOWN) {
            return "DOWN";
        }
        if (pressType == WatchUi.PRESS_TYPE_ACTION) {
            return "ACTION";
        }
        if (pressType == WatchUi.PRESS_TYPE_UP) {
            return "UP";
        }
        return "UNKNOWN(" + pressType.toString() + ")";
    }

    function _safeExitFromSummary() as Void {
        try {
            // System.exit() is the most reliable way to leave the app across
            // simulator and physical devices.
            System.exit();
            _view.logBackInputEvent("ACTION", "summary_exit_system_exit_invoked");
        } catch (exitEx) {
            _view.logBackInputEvent("ACTION", "summary_exit_system_exit_failed:" + exitEx.toString());
            try {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                _view.logBackInputEvent("ACTION", "summary_exit_pop_view_fallback_invoked");
            } catch (popEx) {
                _view.logBackInputEvent("ACTION", "summary_exit_pop_view_fallback_failed:" + popEx.toString());
            }
        }
    }

}
