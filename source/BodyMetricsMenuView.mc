import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Custom-drawn menu view with responsive layout for round watch screens.
//! Replaces the built-in WatchUi.Menu for a modern, adaptive appearance.
class BodyMetricsMenuView extends WatchUi.View {

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

    function fitMenuText(dc as Dc, value as String, primaryFont, fallbackFont, maxWidth as Number) as Dictionary {
        var font = primaryFont;
        var lines = wrapTextGlobal(dc, value, font, maxWidth);
        if (lines.size() > 2 || maxTextWidth(dc, lines, font) > maxWidth) {
            font = fallbackFont;
            lines = wrapTextGlobal(dc, value, font, maxWidth);
        }
        return {
            :font => font,
            :lines => lines,
            :lineHeight => dc.getFontHeight(font),
            :width => maxTextWidth(dc, lines, font)
        };
    }

    function maxTextWidth(dc as Dc, lines as Array, font) as Number {
        var maxWidth = 0;
        for (var i = 0; i < lines.size(); i += 1) {
            var lineWidth = dc.getTextWidthInPixels(lines[i].toString(), font);
            if (lineWidth > maxWidth) {
                maxWidth = lineWidth;
            }
        }
        return maxWidth;
    }

    function drawCenteredLines(dc as Dc, cx as Number, startY as Number, layout as Dictionary, color as Number) as Void {
        var lines = layout[:lines] as Array;
        var font = layout[:font];
        var lineHeight = layout[:lineHeight];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < lines.size(); i += 1) {
            dc.drawText(cx, startY + i * lineHeight, font, lines[i].toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
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
        dc.setColor(COLOR_ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - lineHalfW, lineY, cx + lineHalfW, lineY);
        dc.setPenWidth(1);

        // Title
        var titleY = lineY + pct(h, 2);
        var titleLayout = fitMenuText(dc, _title, Graphics.FONT_TINY, Graphics.FONT_XTINY, pct(w, 72));
        var titleLineHeight = titleLayout[:lineHeight];
        drawCenteredLines(dc, cx, titleY, titleLayout, COLOR_ACCENT);

        // Separator below title
        var titleBlockH = (titleLayout[:lines] as Array).size() * titleLineHeight;
        var sepY = titleY + titleBlockH + pct(h, 2);
        dc.setColor(COLOR_ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - lineHalfW, sepY, cx + lineHalfW, sepY);

        // Items layout
        var itemGap = pct(h, 3);
        var safeW = pct(w, 70);
        var itemLayouts = [] as Array;
        var totalItemsH = 0;

        for (var i = 0; i < _items.size(); i += 1) {
            var item = _items[i] as Dictionary;
            var layout = fitMenuText(dc, item[:label].toString(), Graphics.FONT_TINY, Graphics.FONT_XTINY, safeW);
            itemLayouts.add(layout);
            totalItemsH += (layout[:lines] as Array).size() * layout[:lineHeight];
            if (i < _items.size() - 1) {
                totalItemsH += itemGap;
            }
        }

        // Vertical centering of items in remaining space
        var availTop = sepY + pct(h, 3);
        var availBottom = h - pct(h, 10);
        var itemsStartY = availTop + (availBottom - availTop - totalItemsH) / 2;
        if (itemsStartY < availTop) {
            itemsStartY = availTop;
        }

        // Draw items
        var currentY = itemsStartY;
        for (var i = 0; i < _items.size(); i++) {
            var layout = itemLayouts[i] as Dictionary;
            var itemH = (layout[:lines] as Array).size() * layout[:lineHeight];

            if (i == _selected) {
                // Highlight pill for selected item
                var textW = layout[:width];
                var pillPadX = pct(w, 5);
                var pillW = textW + pillPadX * 2;
                var pillH = itemH + pct(h, 3);
                var pillX = cx - pillW / 2;
                var pillY = currentY - pct(h, 1);
                var pillR = pillH / 2;

                dc.setColor(COLOR_ACCENT_DIM, COLOR_ACCENT_DIM);
                dc.fillRoundedRectangle(pillX, pillY, pillW, pillH, pillR);
                drawCenteredLines(dc, cx, currentY, layout, Graphics.COLOR_WHITE);
            } else {
                drawCenteredLines(dc, cx, currentY, layout, Graphics.COLOR_LT_GRAY);
            }
            currentY += itemH + itemGap;
        }

        // Bottom accent line
        var bottomLineY = h - pct(h, 8);
        dc.setColor(COLOR_ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(cx - lineHalfW, bottomLineY, cx + lineHalfW, bottomLineY);
        dc.setPenWidth(1);
    }

}

//! Toggle globale per abilitare funzioni di debug nel menu.
//! Impostare a false prima della build di release.
const DEBUG = true;

function buildDebugMenuItems(view as BodyMetricsView) as Array {
    var items = [] as Array;
    if (view.isDebugEnabled()) {
        items.add({:label => view.text("debug.menu.populate_history"), :id => :debug_populate_history});
        items.add({:label => view.text("debug.menu.clear_history"), :id => :debug_clear_history});
        items.add({:label => view.text("debug.menu.validate_locale"), :id => :debug_validate_locale});
        items.add({:label => view.text("debug.menu.disable"), :id => :debug_disable});
    } else {
        items.add({:label => view.text("debug.menu.enable"), :id => :debug_enable});
    }
    return items;
}

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
        items.add({:label => _view.text("menu.targets"), :id => :targets});
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
        items.add({:label => _view.text("menu.system_info"), :id => :system_info});
        items.add({:label => _view.text("menu.reset_data"), :id => :reset_data});
        var subView = new BodyMetricsMenuView(_view.text("menu.cat.info"), items);
        WatchUi.pushView(subView, new BodyMetricsInfoMenuDelegate(subView, _view), WatchUi.SLIDE_UP);
    }
    
    function _openDebugSubmenu() as Void {
        var debugItems = buildDebugMenuItems(_view);
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
            var dataItems = [] as Array;
            dataItems.add({:label => _view.text("menu.data_entry"), :id => :data_entry});
            dataItems.add({:label => _view.text("menu.data_clear"), :id => :data_clear});
            var dataView = new BodyMetricsMenuView(_view.text("menu.data"), dataItems);
            WatchUi.pushView(dataView, new BodyMetricsDataEntryMenuDelegate(dataView, _view, _popCount + 1), WatchUi.SLIDE_UP);
        } else if (id == :targets) {
            var targetsItems = [] as Array;
            targetsItems.add({:label => _view.text("menu.targets_set"), :id => :targets_set});
            targetsItems.add({:label => _view.text("menu.targets_reset_all"), :id => :targets_reset_all});
            var targetsView = new BodyMetricsMenuView(_view.text("menu.targets"), targetsItems);
            WatchUi.pushView(targetsView, new BodyMetricsTargetsMenuDelegate(targetsView, _view, _popCount + 1), WatchUi.SLIDE_UP);
        }
        return true;
    }
}

//! Delegate per il sotto-menu Rilevazioni (Inserisci, Cancella).
class BodyMetricsDataEntryMenuDelegate extends BodyMetricsBaseMenuDelegate {

    var _popCount as Number;

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView, popCount as Number) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
        _popCount = popCount;
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :data_entry) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.requestDataMenuOnExit();
            _view.openDataEntry();
        } else if (id == :data_clear) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.clearMeasurementsWithFeedback();
        }
        return true;
    }
}

//! Delegate per il menu contestuale del singolo campo wizard (rilevazione o obiettivo).
//! :mode = :data  → offre "Cancella campo"
//! :mode = :target → offre "Ripristina default"
class BodyMetricsFieldContextMenuDelegate extends BodyMetricsBaseMenuDelegate {

    var _fieldMode as Symbol;

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView, fieldMode as Symbol) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
        _fieldMode = fieldMode;
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (id == :field_clear) {
            _view.clearCurrentMeasurementField();
        } else if (id == :target_reset_field) {
            _view.clearCurrentTargetField();
        } else if (id == :history_remove_last) {
            _view.removeLastHistoryEntryWithFeedback();
        }
        return true;
    }
}

//! Delegate per il sotto-menu obiettivi (Imposta, Cancella tutto).
class BodyMetricsTargetsMenuDelegate extends BodyMetricsBaseMenuDelegate {

    var _popCount as Number;

    function initialize(menuView as BodyMetricsMenuView, view as BodyMetricsView, popCount as Number) {
        BodyMetricsBaseMenuDelegate.initialize(menuView, view);
        _popCount = popCount;
    }

    function onSelect() as Boolean {
        var id = _menuView.selectedId();
        if (id == :targets_set) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.requestDataMenuOnExit();
            _view.openTargetEditor();
        } else if (id == :targets_reset_all) {
            for (var i = 0; i < _popCount; i++) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            }
            _view.clearTargetsWithFeedback();
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
        if (id == :system_info) {
            _view.openSystemInfo();
        } else if (id == :reset_data) {
            _view.resetAllDataWithFeedback();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
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
            // Pop debug submenu + main menu → torna alla view principale
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.populateHistoryDebug();
        } else if (id == :debug_clear_history) {
            // Pop debug submenu + main menu → torna alla view principale
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.clearHistoryDebug();
        } else if (id == :debug_validate_locale) {
            // Pop debug submenu + main menu → badge visibile sulla view principale
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _view.validateLocaleDebug();
        } else if (id == :debug_disable) {
            _view.toggleDebugMode();
            // Torna al menu principale (1 pop: esce solo dal debug submenu)
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :debug_enable) {
            _view.toggleDebugMode();
            // Rimani nel debug submenu aggiornato
            _refreshDebugMenu();
        }
        return true;
    }
    
    function _refreshDebugMenu() as Void {
        // Aggiorna il menu debug per mostrare le nuove opzioni
        var debugItems = buildDebugMenuItems(_view);
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
