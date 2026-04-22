import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Uses InputDelegate (not BehaviorDelegate) to receive raw onTap
//! coordinates, needed to detect taps on the (i) info icon.
class BodyMetricsInputDelegate extends WatchUi.InputDelegate {

    var _view;
    var _selectDownTime as Number;
    var _lastKeyReleaseTime as Number;
    const LONG_PRESS_MS = 800;
    const DOUBLE_TAP_WINDOW_MS = 600;

    function initialize(view as BodyMetricsView) {
        InputDelegate.initialize();
        _view = view;
        _selectDownTime = 0;
        _lastKeyReleaseTime = 0;
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
            var items = [] as Array;
            items.add({:label => _view.text("menu.cat.data"), :id => :data_management});
            items.add({:label => _view.text("menu.cat.options"), :id => :options});
            items.add({:label => _view.text("menu.cat.info"), :id => :information});
            if (DEBUG) {
                items.add({:label => _view.text("debug.menu.title"), :id => :debug});
            }
            var menuView = new BodyMetricsMenuView(_view.text("menu.title"), items);
            WatchUi.pushView(menuView, new BodyMetricsCustomMenuDelegate(menuView, _view), WatchUi.SLIDE_UP);
        }
        return true;
    }
}
