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
        
        if (id == :data_management) {
            _openDataSubmenu();
        } else if (id == :options) {
            _openOptionsSubmenu();
        } else if (id == :information) {
            _openInfoSubmenu();
        } else if (id == :debug) {
            _openDebugSubmenu();
        }
        return true;
    }
    
    function _openDataSubmenu() as Void {
        var items = [] as Array;
        items.add({:label => _view.text("menu.profile"), :id => :profile});
        items.add({:label => _view.text("menu.data"), :id => :data});
        var subView = new BodyMetricsMenuView(_view.text("menu.cat.data"), items);
        // 2 pops: main menu + data submenu
        WatchUi.pushView(subView, new BodyMetricsDataMenuDelegate(subView, _view, 2), WatchUi.SLIDE_UP);
    }
    
    function _openOptionsSubmenu() as Void {
        var items = [] as Array;
        items.add({:label => _view.text("menu.language"), :id => :language});
        var subView = new BodyMetricsMenuView(_view.text("menu.cat.options"), items);
        WatchUi.pushView(subView, new BodyMetricsOptionsMenuDelegate(subView, _view), WatchUi.SLIDE_UP);
    }
    
    function _openInfoSubmenu() as Void {
        var items = [] as Array;
        items.add({:label => _view.text("menu.badge_info"), :id => :badge_info});
        items.add({:label => _view.text("menu.system_info"), :id => :system_info});
        var subView = new BodyMetricsMenuView(_view.text("menu.cat.info"), items);
        WatchUi.pushView(subView, new BodyMetricsInfoMenuDelegate(subView, _view), WatchUi.SLIDE_UP);
    }
    
    function _openDebugSubmenu() as Void {
        var debugItems = [] as Array;
        if (_view.isDebugEnabled()) {
            debugItems.add({:label => _view.text("debug.menu.populate_history"), :id => :debug_populate_history});
            debugItems.add({:label => _view.text("debug.menu.clear_history"), :id => :debug_clear_history});
            debugItems.add({:label => _view.text("debug.menu.disable"), :id => :debug_disable});
        } else {
            debugItems.add({:label => _view.text("debug.menu.enable"), :id => :debug_enable});
        }
        var debugMenuView = new BodyMetricsMenuView(_view.text("debug.menu.title"), debugItems);
        WatchUi.pushView(debugMenuView, new BodyMetricsCustomDebugMenuDelegate(debugMenuView, _view), WatchUi.SLIDE_UP);
    }
}

//! Delegate per il sotto-menu dati (Profilo, Inserisci dati).
//! popCount: numero di view da rimuovere prima di tornare al main view.
//!   2 = aperto dal main menu (main menu + data submenu)
//!   1 = aperto direttamente (solo data submenu)
class BodyMetricsDataMenuDelegate extends BodyMetricsBaseMenuDelegate {

    var _popCount as Number;

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView, popCount as Number) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
        _popCount = popCount;
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :profile) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.requestDataMenuOnExit();
            _view.openProfileSetup();
        } else if (id == :data) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.requestDataMenuOnExit();
            _view.openDataEntry();
        }
        return true;
    }
}

//! Delegate per il sotto-menu opzioni (Lingua).
class BodyMetricsOptionsMenuDelegate extends BodyMetricsBaseMenuDelegate {

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :language) {
            _openLanguageSubmenu();
        }
        return true;
    }
    
    function _openLanguageSubmenu() as Void {
        var langItems = [] as Array;
        var codes = _view.supportedLanguages();
        for (var i = 0; i < codes.size(); i += 1) {
            var language = codes[i].toString();
            langItems.add({:label => _view.languageOptionLabel(language), :id => _view.languageSymbol(language)});
        }
        var langMenuView = new BodyMetricsMenuView(_view.text("menu.language"), langItems);
        WatchUi.pushView(langMenuView, new BodyMetricsCustomLanguageMenuDelegate(langMenuView, _view), WatchUi.SLIDE_UP);
    }
}

//! Delegate per il sotto-menu informazioni (Badge info, Info sistema).
class BodyMetricsInfoMenuDelegate extends BodyMetricsBaseMenuDelegate {

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :badge_info) {
            _view.openBadgeInfo();
        } else if (id == :system_info) {
            _view.openSystemInfo();
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
        
        if (id == :debug_populate_history) {
            _view.populateHistoryDebug();
            // Torna al menu parent (main menu)
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :debug_clear_history) {
            _view.clearHistoryDebug();
            // Torna al menu parent (main menu)
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :debug_disable) {
            _view.toggleDebugMode();
            // Dopo disabilitare debug, ritorna al menu principale
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :debug_enable) {
            _view.toggleDebugMode();
            // Dopo abilitare debug, rimani nella stessa pagina menu
            _refreshDebugMenu();
        }
        return true;
    }
    
    function _refreshDebugMenu() as Void {
        // Aggiorna il menu debug per mostrare le nuove opzioni
        var debugItems = [] as Array;
        if (_view.isDebugEnabled()) {
            debugItems.add({:label => _view.text("debug.menu.populate_history"), :id => :debug_populate_history});
            debugItems.add({:label => _view.text("debug.menu.clear_history"), :id => :debug_clear_history});
            debugItems.add({:label => _view.text("debug.menu.disable"), :id => :debug_disable});
        } else {
            debugItems.add({:label => _view.text("debug.menu.enable"), :id => :debug_enable});
        }
        var newMenuView = new BodyMetricsMenuView(_view.text("debug.menu.title"), debugItems);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.pushView(newMenuView, new BodyMetricsCustomDebugMenuDelegate(newMenuView, _view), WatchUi.SLIDE_UP);
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
        // Pop tutti i livelli menu (lingua → opzioni → principale) per tornare alla main view.
        // setLanguage chiama requestUpdate: la main view viene ridisegnata subito con la nuova lingua.
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        _view.setLanguage(lang);
        return true;
    }
}
