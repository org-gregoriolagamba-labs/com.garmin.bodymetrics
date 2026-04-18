import Toybox.Lang;
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
        if (_view.canOpenMenu()) {
            var items = [] as Array;
            if (_view.canEditProfile()) {
                items.add({:label => _view.text("menu.profile"), :id => :profile});
            }
            items.add({:label => _view.languageMenuLabel(), :id => :language});
            var menuView = new BodyMetricsMenuView(_view.text("menu.title"), items);
            WatchUi.pushView(menuView, new BodyMetricsCustomMenuDelegate(menuView, _view), WatchUi.SLIDE_UP);
        }
        return true;
    }

    function onBack() as Boolean {
        return _view.handleBack();
    }
}

// Menu delegates are now in BodyMetricsMenuView.mc
