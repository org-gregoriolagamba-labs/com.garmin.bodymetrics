import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Custom-drawn menu view with responsive layout for round watch screens.
//! Replaces the built-in WatchUi.Menu for a modern, adaptive appearance.
class BodyMetricsMenuView extends WatchUi.View {

    const ACCENT = 0x66CCFF;
    const ACCENT_DIM = 0x224466;

    var _items as Array;       // [{:label, :id}]
    var _title as String;
    var _selected as Number;

    function initialize(title as String, items as Array) {
        View.initialize();
        _title = title;
        _items = items;
        _selected = 0;
    }

    function selectedId() {
        var item = _items[_selected] as Dictionary;
        return item[:id];
    }

    function moveUp() as Void {
        _selected = (_selected - 1 + _items.size()) % _items.size();
        WatchUi.requestUpdate();
    }

    function moveDown() as Void {
        _selected = (_selected + 1) % _items.size();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        // Black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Decorative top accent line
        var lineY = pct(h, 8);
        var lineHalfW = pct(w, 25);
        dc.setPenWidth(2);
        dc.setColor(ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - lineHalfW, lineY, cx + lineHalfW, lineY);
        dc.setPenWidth(1);

        // Title
        var titleY = lineY + pct(h, 2);
        var titleFont = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(_title, titleFont) > pct(w, 75)) {
            titleFont = Graphics.FONT_XTINY;
        }
        dc.setColor(ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, titleFont, _title, Graphics.TEXT_JUSTIFY_CENTER);

        // Separator below title
        var sepY = titleY + dc.getFontHeight(titleFont) + pct(h, 2);
        dc.setColor(ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - lineHalfW, sepY, cx + lineHalfW, sepY);

        // Items layout
        var itemFont = Graphics.FONT_TINY;
        var itemH = dc.getFontHeight(itemFont);
        var itemGap = pct(h, 3);
        var totalItemsH = _items.size() * itemH + (_items.size() - 1) * itemGap;

        // Vertical centering of items in remaining space
        var availTop = sepY + pct(h, 3);
        var availBottom = h - pct(h, 10);
        var itemsStartY = availTop + (availBottom - availTop - totalItemsH) / 2;
        if (itemsStartY < availTop) {
            itemsStartY = availTop;
        }

        // Check if items need smaller font
        var safeW = pct(w, 70);
        var needsSmallFont = false;
        for (var i = 0; i < _items.size(); i++) {
            var item = _items[i] as Dictionary;
            if (dc.getTextWidthInPixels(item[:label].toString(), itemFont) > safeW) {
                needsSmallFont = true;
                break;
            }
        }
        if (needsSmallFont) {
            itemFont = Graphics.FONT_XTINY;
            itemH = dc.getFontHeight(itemFont);
            totalItemsH = _items.size() * itemH + (_items.size() - 1) * itemGap;
            itemsStartY = availTop + (availBottom - availTop - totalItemsH) / 2;
            if (itemsStartY < availTop) {
                itemsStartY = availTop;
            }
        }

        // Draw items
        for (var i = 0; i < _items.size(); i++) {
            var iy = itemsStartY + i * (itemH + itemGap);
            var item = _items[i] as Dictionary;
            var label = item[:label].toString();

            if (i == _selected) {
                // Highlight pill for selected item
                var textW = dc.getTextWidthInPixels(label, itemFont);
                var pillPadX = pct(w, 5);
                var pillW = textW + pillPadX * 2;
                var pillH = itemH + pct(h, 2);
                var pillX = cx - pillW / 2;
                var pillY = iy - pct(h, 1);
                var pillR = pillH / 2;

                dc.setColor(ACCENT_DIM, ACCENT_DIM);
                dc.fillRoundedRectangle(pillX, pillY, pillW, pillH, pillR);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            }

            dc.drawText(cx, iy, itemFont, label, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Bottom accent line
        var bottomLineY = h - pct(h, 8);
        dc.setColor(ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(cx - lineHalfW, bottomLineY, cx + lineHalfW, bottomLineY);
        dc.setPenWidth(1);
    }

}

//! Toggle globale per abilitare funzioni di debug nel menu.
//! Impostare a false prima della build di release.
const DEBUG = true;

//! Delegate base per tutti i menu. Fornisce navigazione condivisa
//! (UP/DOWN per scorrere, BACK per chiudere). Ogni menu sovrascrive solo onSelect().
class BodyMetricsBaseMenuDelegate extends WatchUi.BehaviorDelegate {

    var _menuView as BodyMetricsMenuView;
    var _view as BodyMetricsView;

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BehaviorDelegate.initialize();
        _menuView = menuView;
        _view = view;
    }

    function onNextPage() as Boolean {
        _menuView.moveDown();
        return true;
    }

    function onPreviousPage() as Boolean {
        _menuView.moveUp();
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}

//! Delegate per il menu principale impostazioni.
class BodyMetricsCustomMenuDelegate extends BodyMetricsBaseMenuDelegate {

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :profile) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.openProfileSetup();
        } else if (id == :data) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.openDataEntry();
        } else if (id == :language) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.queueLanguageMenuOpen();
        } else if (id == :debug) {
            var debugItems = [] as Array;
            if (_view.isDebugEnabled()) {
                debugItems.add({:label => "Popola history", :id => :debug_populate_history});
                debugItems.add({:label => "Cancella history", :id => :debug_clear_history});
                debugItems.add({:label => "Disabilita debug", :id => :debug_disable});
            } else {
                debugItems.add({:label => "Abilita debug", :id => :debug_enable});
            }

            var debugMenuView = new BodyMetricsMenuView("Debug", debugItems);
            WatchUi.pushView(debugMenuView, new BodyMetricsCustomDebugMenuDelegate(debugMenuView, _view), WatchUi.SLIDE_UP);
        }
        return true;
    }
}

//! Delegate per il sotto-menu debug.
class BodyMetricsCustomDebugMenuDelegate extends BodyMetricsBaseMenuDelegate {

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (id == :debug_populate_history) {
            _view.populateHistoryDebug();
        } else if (id == :debug_clear_history) {
            _view.clearHistoryDebug();
        } else if (id == :debug_disable || id == :debug_enable) {
            _view.toggleDebugMode();
        }
        return true;
    }
}

//! Delegate per la selezione lingua.
class BodyMetricsCustomLanguageMenuDelegate extends BodyMetricsBaseMenuDelegate {

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        var lang = "it";
        if (id == :lang_en) { lang = "en"; }
        else if (id == :lang_fr) { lang = "fr"; }
        else if (id == :lang_es) { lang = "es"; }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _view.setLanguage(lang);
        return true;
    }
}
