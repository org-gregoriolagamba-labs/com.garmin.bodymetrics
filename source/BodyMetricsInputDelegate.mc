import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

//! Uses BehaviorDelegate so that onBack() is invoked by the CIQ runtime for
//! the BACK button. This is the only correct pattern for widget dismissal.
//! onTap() is available because BehaviorDelegate extends InputDelegate.
class BodyMetricsInputDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    // Adaptive step: track when UP/DOWN was first pressed in wizard edit mode.
    // Step multiplier increases with hold duration:
    //   0–1 s  → ×1  (step 0.1 for floats, 1 for ints)
    //   1–3 s  → ×10 (step 1.0 for floats, 10 for ints)
    //   >3 s   → ×50 (step 5.0 for floats, 50 for ints)
    // Option B: a Timer fires every NAV_REPEAT_MS while key is held,
    // re-applying the step with the updated multiplier on each tick.
    var _navDownTime as Number;   // System.getTimer() when UP/DOWN was pressed
    var _navDirection as Number;  // +1 = next (DOWN), -1 = prev (UP), 0 = none
    var _navTimer as Timer.Timer?;

    const STEP_MID_MS  = 1000;   // after 1 s → ×10
    const STEP_HIGH_MS = 3000;   // after 3 s → ×50
    const STEP_MID_MUL = 10;
    const STEP_HIGH_MUL = 50;
    const NAV_REPEAT_MS = 300;   // timer repeat interval while key held

    function initialize(view as BodyMetricsView) {
        BehaviorDelegate.initialize();
        _view = view;
        _navDownTime = 0;
        _navDirection = 0;
        _navTimer = null;
    }

    // -------------------------------------------------------------------------
    // Touch
    // -------------------------------------------------------------------------

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        _view.toggleMode();
        return true;
    }

    // -------------------------------------------------------------------------
    // Raw key override — intercepts UP/DOWN PRESS_TYPE_DOWN for adaptive step
    // timing, and UP/DOWN PRESS_TYPE_UP to reset tracking.
    // Everything else is forwarded to BehaviorDelegate.onKey() so the runtime
    // can invoke onBack(), onSelect(), onNextPage(), onPreviousPage(), etc.
    // -------------------------------------------------------------------------

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        var pressType = evt.getType();

        if ((key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN) && _view.isWizardEditMode()) {
            if (pressType == WatchUi.PRESS_TYPE_DOWN) {
                // Guard against firmware auto-repeat: only initialize on the
                // very first PRESS_TYPE_DOWN (when no timer is running yet).
                // Subsequent auto-repeat PRESS_TYPE_DOWN events are consumed
                // silently so the timer keeps running uninterrupted.
                if (_navTimer == null) {
                    _navDownTime = System.getTimer();
                    _navDirection = (key == WatchUi.KEY_DOWN) ? 1 : -1;
                    _applyNavStep();
                    _startNavTimer();
                }
                return true;
            }
            if (pressType == WatchUi.PRESS_TYPE_UP) {
                _stopNavTimer();
                _navDownTime = 0;
                _navDirection = 0;
                return true;
            }
            if (pressType == WatchUi.PRESS_TYPE_ACTION) {
                // Timer is already running; consume silently and let it continue.
                return true;
            }
        }

        // On FR265, long press of the UP physical button fires KEY_MENU (a
        // separate key code), NOT KEY_UP + PRESS_TYPE_ACTION. Intercept it in
        // wizard edit mode so it does not open the main menu.
        if (key == WatchUi.KEY_MENU && _view.isWizardEditMode()) {
            return true;
        }

        // Forward to BehaviorDelegate: KEY_ESC→onBack(), UP/DOWN→onPreviousPage/onNextPage(), etc.
        return BehaviorDelegate.onKey(evt);
    }

    // Called on each timer tick (every NAV_REPEAT_MS) while UP/DOWN is held in
    // wizard edit mode. Multiplier increases as elapsed time grows.
    function _onNavTick() as Void {
        _applyNavStep();
    }

    function _startNavTimer() as Void {
        _stopNavTimer();
        _navTimer = new Timer.Timer();
        _navTimer.start(method(:_onNavTick), NAV_REPEAT_MS, true);
    }

    function _stopNavTimer() as Void {
        if (_navTimer != null) {
            _navTimer.stop();
            _navTimer = null;
        }
    }

    // Computes current multiplier based on how long the key has been held,
    // then calls nextMetricBy/previousMetricBy on the view.
    function _applyNavStep() as Void {
        if (_navDirection == 0 || _navDownTime == 0) { return; }
        var elapsed = System.getTimer() - _navDownTime;
        var mul = 1;
        if (elapsed >= STEP_HIGH_MS) {
            mul = STEP_HIGH_MUL;
        } else if (elapsed >= STEP_MID_MS) {
            mul = STEP_MID_MUL;
        }
        if (_navDirection > 0) {
            _view.nextMetricBy(mul);
        } else {
            _view.previousMetricBy(mul);
        }
    }

    // -------------------------------------------------------------------------
    // Semantic behavior methods
    // -------------------------------------------------------------------------

    //! MENU behavior (= long press UP on FR265) — called DIRECTLY by the CIQ
    //! runtime, bypassing onKey(). In wizard edit mode the adaptive step timer
    //! is already running from PRESS_TYPE_DOWN, so we just consume this event
    //! to prevent the main menu from opening. Outside wizard mode, open menu.
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
        if (_view.canOpenMenu()) {
            _view.openMenu();
        }
        return true;
    }
}


