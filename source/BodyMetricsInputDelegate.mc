import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class BodyMetricsInputDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view as BodyMetricsView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Boolean {
        _view.nextMetric();
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.previousMetric();
        return true;
    }

    function onSelect() as Boolean {
        _view.toggleMode();
        return true;
    }

    function onMenu() as Boolean {
        System.println("onMenu called");
        if (_view.canOpenMenu()) {
            var menu = new WatchUi.Menu();
            menu.setTitle("Menu");
            menu.addItem("Profilo", :profile);
            WatchUi.pushView(menu, new BodyMetricsMenuDelegate(_view), WatchUi.SLIDE_UP);
        }
        return true;
    }

    function onBack() as Boolean {
        System.println("onBack called");
        var result = _view.handleBack();
        System.println("onBack result=" + result);
        return result;
    }
}

class BodyMetricsMenuDelegate extends WatchUi.MenuInputDelegate {

    var _view;

    function initialize(view as BodyMetricsView) {
        MenuInputDelegate.initialize();
        _view = view;
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :profile) {
            _view.openProfileSetup();
        }
    }
}
