import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

class BodyMetricsView extends WatchUi.View {

    const TREND_WINDOWS = [7, 30, 90];

    //! DEBUG: Popola la history con dati casuali per test
    function populateHistoryDebug() as Void {
        _domain.populateHistoryDebug();
        _cacheTrendData();
        WatchUi.requestUpdate();
    }

    //! DEBUG: Cancella la history
    function clearHistoryDebug() as Void {
        _domain.clearHistoryDebug();
        _cacheTrendData();
        WatchUi.requestUpdate();
    }

    //! DEBUG: Toggle debug mode on/off
    function toggleDebugMode() as Boolean {
        if (_debugEnabled) {
            _domain.disableDebugMode();
            _cacheTrendData();
            WatchUi.requestUpdate();
        }
        _debugEnabled = !_debugEnabled;
        return _debugEnabled;
    }

    function isDebugEnabled() as Boolean {
        return _debugEnabled;
    }

    const MODE_SUMMARY = 0;
    const MODE_DETAIL = 1;
    const MODE_SETUP = 2;
    const MODE_DATA = 3;
    const MODE_TREND = 4;

    var _mode;
    var _selectedMetric;
    var _domain;
    var _animPhase;
    var _animTimer;
    var _setupIndex;
    var _profileDraft;
    var _pendingMenuAction;
    var _dataIndex;
    var _dataDraft;
    var _trendWindow;
    var _trendDirection;
    var _trendValues;
    var _debugEnabled = false;  // Debug menu: impostare a true solo durante lo sviluppo
    function initialize() {
        View.initialize();
        _mode = MODE_SUMMARY;
        _selectedMetric = 0;
        _domain = new BodyMetricsDomain();
        _animPhase = 0;
        _animTimer = null;
        _setupIndex = 0;
        _profileDraft = _domain.currentProfile();
        _pendingMenuAction = null;
        _dataIndex = 0;
        _dataDraft = _domain.currentMeasurements();
        _trendWindow = 0;
        _trendDirection = TREND_FLAT;
        _trendValues = [];

        if (!_domain.hasConfiguredProfile()) {
            enterSetupMode();
        }
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        if (_animTimer != null) {
            _animTimer.stop();
        }
        _animTimer = new Timer.Timer();
        _animTimer.start(method(:onAnimTick), 1500, true);

        if (_pendingMenuAction != null) {
            var pendingAction = _pendingMenuAction;
            _pendingMenuAction = null;
            if (pendingAction == :openLanguageMenu) {
                openLanguageMenu();
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_mode == MODE_SETUP) {
            drawSetup(dc);
        } else if (_mode == MODE_DATA) {
            drawDataEntry(dc);
        } else if (_mode == MODE_SUMMARY) {
            drawSummary(dc);
        } else if (_mode == MODE_TREND) {
            drawTrend(dc);
        } else {
            drawDetail(dc);
        }
    }

    function onHide() as Void {
        if (_animTimer != null) {
            _animTimer.stop();
            _animTimer = null;
        }
    }

    function onAnimTick() as Void {
        _animPhase = (_animPhase + 1) % 2;
        WatchUi.requestUpdate();
    }

    // --- Navigation ---

    function enterSetupMode() as Void {
        _profileDraft = _domain.currentProfile();
        _setupIndex = 0;
        _mode = MODE_SETUP;
    }

    function openProfileSetup() as Void {
        enterSetupMode();
        WatchUi.requestUpdate();
    }

    function openDataEntry() as Void {
        _dataDraft = _domain.currentMeasurements();
        _dataIndex = 0;
        _mode = MODE_DATA;
        WatchUi.requestUpdate();
    }

    function canOpenMenu() as Boolean {
        return true;
    }

    function canEditProfile() as Boolean {
        return _domain.hasConfiguredProfile() &&
            (_mode == MODE_SUMMARY || _mode == MODE_DETAIL || _mode == MODE_TREND);
    }

    function text(key as String) as String {
        return _domain.text(key);
    }

    function currentLanguage() as String {
        return _domain.currentLanguage();
    }

    function supportedLanguages() as Array {
        return _domain.supportedLanguages();
    }

    function languageLabel(language as String) as String {
        return _domain.languageLabel(language);
    }

    function currentLanguageLabel() as String {
        return languageLabel(currentLanguage());
    }

    function languageMenuLabel() as String {
        return text("menu.language") + ": " + currentLanguageLabel();
    }

    function setLanguage(language as String) as Void {
        _domain.setLanguage(language);
        WatchUi.requestUpdate();
    }

    function queueLanguageMenuOpen() as Void {
        _pendingMenuAction = :openLanguageMenu;
    }

    function openLanguageMenu() as Void {
        var items = [] as Array;
        var codes = supportedLanguages();
        for (var i = 0; i < codes.size(); i += 1) {
            var language = codes[i].toString();
            items.add({:label => languageOptionLabel(language), :id => languageSymbol(language)});
        }
        var menuView = new BodyMetricsMenuView(languageMenuLabel(), items);
        WatchUi.pushView(menuView, new BodyMetricsCustomLanguageMenuDelegate(menuView, self), WatchUi.SLIDE_UP);
    }

    function languageOptionLabel(language as String) as String {
        if (language.equals(currentLanguage())) {
            return "* " + languageLabel(language);
        }
        return languageLabel(language);
    }

    function languageSymbol(language as String) as Symbol {
        if (language.equals("en")) {
            return :lang_en;
        }
        if (language.equals("fr")) {
            return :lang_fr;
        }
        if (language.equals("es")) {
            return :lang_es;
        }
        return :lang_it;
    }

    function nextMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, -1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_DATA) {
            _dataDraft = _domain.cycleMeasurementField(_dataDraft, _dataIndex, -1);
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_TREND) {
            _cycleTrendWindow(1);
            WatchUi.requestUpdate();
            return;
        }

        _selectedMetric = (_selectedMetric + 1) % _domain.metricsCount();
        WatchUi.requestUpdate();
    }

    function previousMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, 1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_DATA) {
            _dataDraft = _domain.cycleMeasurementField(_dataDraft, _dataIndex, 1);
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_TREND) {
            _cycleTrendWindow(-1);
            WatchUi.requestUpdate();
            return;
        }

        _selectedMetric = (_selectedMetric - 1 + _domain.metricsCount()) % _domain.metricsCount();
        WatchUi.requestUpdate();
    }

    function toggleMode() as Void {
        if (_mode == MODE_SETUP) {
            if (_setupIndex < _domain.profileFieldCount() - 1) {
                _setupIndex += 1;
            } else {
                _domain.saveProfile(_profileDraft);
                _mode = MODE_SUMMARY;
                _selectedMetric = 0;
            }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_DATA) {
            if (_dataIndex < _domain.measurementFieldCount() - 1) {
                _dataIndex += 1;
            } else {
                _domain.saveMeasurements(_dataDraft);
                _mode = MODE_SUMMARY;
                _selectedMetric = 0;
            }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_SUMMARY) {
            _mode = MODE_DETAIL;
        } else if (_mode == MODE_DETAIL) {
            _mode = MODE_TREND;
            _cacheTrendData();
        } else {
            _mode = MODE_SUMMARY;
        }
        WatchUi.requestUpdate();
    }

    function handleBack() as Boolean {
        if (_mode == MODE_SETUP) {
            if (_setupIndex > 0) {
                _setupIndex -= 1;
            } else if (_domain.hasConfiguredProfile()) {
                _mode = MODE_SUMMARY;
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_DATA) {
            if (_dataIndex > 0) {
                _dataIndex -= 1;
            } else {
                _mode = MODE_SUMMARY;
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_DETAIL) {
            _mode = MODE_SUMMARY;
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_TREND) {
            _mode = MODE_DETAIL;
            WatchUi.requestUpdate();
            return true;
        }

        return true;
    }

    function drawSetup(dc as Dc) as Void {
        var field = _domain.profileFieldDefinition(_setupIndex) as Dictionary;
        drawWizardScreen(dc, _setupIndex, _domain.profileFieldCount(), field,
            _domain.profileFieldValueLabel(_profileDraft, _setupIndex),
            _domain.hasConfiguredProfile() ? text("setup.edit_profile") : text("setup.configure_profile"),
            text("setup.select_save"), text("setup.select_next"));
    }

    function drawDataEntry(dc as Dc) as Void {
        var field = _domain.measurementFieldDefinition(_dataIndex) as Dictionary;
        drawWizardScreen(dc, _dataIndex, _domain.measurementFieldCount(), field,
            _domain.measurementFieldValueLabel(_dataDraft, _dataIndex),
            text("data.title"),
            text("data.select_save"), text("data.select_next"));
    }

    //! Shared wizard screen for both profile setup and data entry modes.
    //! Draws progress dots, field label/badge, value with arrows, and footer hint.
    function drawWizardScreen(dc as Dc, stepIndex as Number, totalSteps as Number,
        field as Dictionary, valueText as String, titleText as String,
        saveHint as String, nextHint as String) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var hTiny = dc.getFontHeight(Graphics.FONT_TINY);
        var hMedium = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var gap = pct(h, 2);

        var isReadOnly = field.hasKey(:readOnly) && field[:readOnly];
        var badgeSpace = isReadOnly ? (hXtiny + gap) : 0;

        // Central content: label + optional badge + value, centered vertically
        var centralH = hTiny + gap + badgeSpace + hMedium;
        var labelY = cy - centralH / 2;
        var badgeY = labelY + hTiny + 2;
        var valueY = labelY + hTiny + gap + badgeSpace;

        // Field label
        dc.setColor(isReadOnly ? 0x66CCFF : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, Graphics.FONT_TINY,
            field[:label].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        if (isReadOnly && field.hasKey(:badgeText)) {
            drawReadOnlyBadge(dc, cx, badgeY, field[:badgeText].toString());
        }

        // Field value (auto-shrink if too wide)
        dc.setColor(isReadOnly ? 0x66CCFF : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var valueFont = Graphics.FONT_MEDIUM;
        var safeW = pct(w, 65);
        if (dc.getTextWidthInPixels(valueText, valueFont) > safeW) {
            valueFont = Graphics.FONT_SMALL;
        }
        dc.drawText(cx, valueY, valueFont, valueText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Progress dots
        var dotsY = pct(h, 16);
        var dotSpacing = pct(w, 5);
        if (dotSpacing < 14) { dotSpacing = 14; }
        var activeR = pct(w, 1);
        if (activeR < 4) { activeR = 4; }
        var inactiveR = activeR - 1;
        if (inactiveR < 2) { inactiveR = 2; }
        var dotsStartX = cx - ((totalSteps - 1) * dotSpacing) / 2;

        for (var i = 0; i < totalSteps; i++) {
            var dotX = dotsStartX + i * dotSpacing;
            if (i < stepIndex) {
                dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else if (i == stepIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, inactiveR);
            }
        }

        // Title below dots
        var titleY = dotsY + activeR + gap + 2;
        dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_XTINY,
            titleText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Arrows for editable fields
        if (!isReadOnly) {
            var arrowY = valueY + dc.getFontHeight(valueFont) / 2;
            var arrowX = pct(w, 12);
            dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
            drawTriangle(dc, arrowX, arrowY, pct(w, 2), true);
            drawTriangle(dc, w - arrowX, arrowY, pct(w, 2), false);
        }

        // Footer action hint
        var footerY = h - pct(h, 16) - hXtiny;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, footerY, Graphics.FONT_XTINY,
            isReadOnly ? field[:readOnlyText].toString() : (stepIndex == totalSteps - 1 ? saveHint : nextHint),
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function manualDateText(metric as Dictionary) as String {
        if (!metric[:available] || metric[:source] == null) {
            return "";
        }
        if (metric[:source].toString().equals(SOURCE_MANUAL)) {
            return _domain.lastUpdateDateLabel();
        }
        return "";
    }

    //! Draws source badge (and optional date for manual) centered at cx, y.
    //! Returns the total height consumed by the subtitle row.
    function drawSourceSubtitle(dc as Dc, cx as Number, y as Number, badgeText as String, dateText as String) as Number {
        var font = Graphics.FONT_XTINY;
        var padX = 4;
        var padY = 1;
        var badgeTextW = dc.getTextWidthInPixels(badgeText, font);
        var badgeW = badgeTextW + (padX * 2);
        var badgeH = dc.getFontHeight(font) + (padY * 2);

        if (dateText.equals("")) {
            // Badge only, centered
            var bx = cx - (badgeW / 2);
            dc.setColor(0x335C99, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(bx, y, badgeW, badgeH);
            dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
            dc.drawRectangle(bx, y, badgeW, badgeH);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, y + padY, font, badgeText, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Badge + date, centered together
            var gap = 4;
            var dateW = dc.getTextWidthInPixels(dateText, font);
            var totalW = badgeW + gap + dateW;
            var startX = cx - (totalW / 2);

            // Badge
            dc.setColor(0x335C99, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(startX, y, badgeW, badgeH);
            dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
            dc.drawRectangle(startX, y, badgeW, badgeH);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + badgeW / 2, y + padY, font, badgeText, Graphics.TEXT_JUSTIFY_CENTER);

            // Date text
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX + badgeW + gap, y + padY, font, dateText, Graphics.TEXT_JUSTIFY_LEFT);
        }
        return badgeH;
    }

    function drawReadOnlyBadge(dc as Dc, cx as Number, y as Number, textValue as String) as Void {
        var font = Graphics.FONT_XTINY;
        var textW = dc.getTextWidthInPixels(textValue, font);
        var padX = 6;
        var padY = 1;
        var badgeW = textW + (padX * 2);
        var badgeH = dc.getFontHeight(font) + (padY * 2);
        var x = cx - (badgeW / 2);

        dc.setColor(0x335C99, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, badgeW, badgeH);
        dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, badgeW, badgeH);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y + padY, font, textValue, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawTriangle(dc as Dc, cx as Number, cy as Number, size as Number, pointUp as Boolean) as Void {
        if (size < 4) { size = 4; }
        var half = size / 2;
        if (pointUp) {
            dc.fillPolygon([[cx, cy - half], [cx - half, cy + half], [cx + half, cy + half]]);
        } else {
            dc.fillPolygon([[cx, cy + half], [cx - half, cy - half], [cx + half, cy - half]]);
        }
    }

    // --- Summary Screen (fully responsive) ---

    function drawSummary(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? _domain.classify(metric) : ZONE_GREEN;

        var policy = _domain.classificationPolicy(metric);

        // Zone arc at perimeter
        if (available) {
            drawZoneArc(dc, cx, cy, cx - pct(w, 2), metric, zone, policy);
        }

        // Font heights for flow layout
        var hNumMild = dc.getFontHeight(Graphics.FONT_NUMBER_MILD);
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 1);
        if (pad < 2) { pad = 2; }

        // Safe zones
        var topSafe = pct(h, 15);
        var bottomSafe = h - pct(h, 8);

        // Source badge subtitle info
        var badgeText = _domain.metricSourceBadgeText(_selectedMetric);
        var dateText = manualDateText(metric);
        var hasSubtitle = !badgeText.equals("");

        // Metric label font (auto-shrink if too wide)
        var labelText = _domain.metricLabel(_selectedMetric);
        var labelFont = Graphics.FONT_TINY;
        var safeW = pct(w, 80);
        if (dc.getTextWidthInPixels(labelText, labelFont) > safeW) {
            labelFont = Graphics.FONT_XTINY;
        }
        var hLabelFont = dc.getFontHeight(labelFont);

        // Calculate total content height to center vertically
        var subtitleH = hasSubtitle ? (hXtiny + 1) : 0;
        var dotsH = pct(h, 4);
        var summaryH = hXtiny;
        // label + subtitle + value + unit + hint + dots + summary
        var totalH = hLabelFont + subtitleH + pad + hNumMild + pad + hXtiny + pad + hXtiny + dotsH + summaryH;
        var labelY = cy - totalH / 2;
        if (labelY < topSafe) { labelY = topSafe; }

        // Metric label
        dc.setColor(available ? _domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Source badge subtitle (under title, for all available metrics)
        if (hasSubtitle) {
            drawSourceSubtitle(dc, cx, labelY + hLabelFont + 1, badgeText, dateText);
        }

        // Hero value
        var valueY = labelY + hLabelFont + subtitleH + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_NUMBER_MILD,
            formatValue(metric),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Unit (XTINY for compact layout)
        var unitY = valueY + hNumMild + pad;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, unitY, Graphics.FONT_XTINY,
            metric[:unit].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Semantic zone hint (colored)
        var hintY = unitY + hXtiny + pad;
        var dotsY = hintY + hXtiny + pct(h, 2);
        var summaryY = dotsY + pct(h, 4);

        // Overflow check: ensure bottom content fits in safe zone
        var overflow = (summaryY + hXtiny) - bottomSafe;
        if (overflow > 0) {
            hintY -= overflow;
            dotsY -= overflow;
            summaryY -= overflow;
        }

        if (available) {
            dc.setColor(_domain.zoneColor(metric, zone), Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, hintY, Graphics.FONT_XTINY,
                _domain.semanticZoneHint(metric),
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, hintY, Graphics.FONT_XTINY,
                text("hint.unavailable"),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Page dots
        drawPageDots(dc, cx, dotsY, w);

        // Zone summary
        drawZoneSummary(dc, cx, summaryY, w);
    }

    // --- Detail Screen (fully responsive) ---

    function drawDetail(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? _domain.classify(metric) : ZONE_GREEN;
        var policy = _domain.classificationPolicy(metric);
        var showIdealRange = available && zone != ZONE_GREEN;

        var hLarge = dc.getFontHeight(Graphics.FONT_LARGE);
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 1);
        if (pad < 3) { pad = 3; }
        var barH = pct(h, 4);
        if (barH < 16) { barH = 16; }

        // Safe zones
        var topSafe = pct(h, 11);
        var bottomSafe = h - pct(h, 9);

        // Source badge subtitle info
        var badgeText = _domain.metricSourceBadgeText(_selectedMetric);
        var dateText = manualDateText(metric);
        var hasSubtitle = !badgeText.equals("");

        // Metric label in zone color (auto-shrink if too wide)
        var labelFont = Graphics.FONT_SMALL;
        var labelText = _domain.metricLabel(_selectedMetric);
        var safeW = pct(w, 80);
        if (dc.getTextWidthInPixels(labelText, labelFont) > safeW) {
            labelFont = Graphics.FONT_TINY;
        }
        var hLabel = dc.getFontHeight(labelFont);

        // Calculate total content height to center vertically
        var subtitleH = hasSubtitle ? (hXtiny + 1) : 0;
        var totalH = hLabel + subtitleH + pad + hLarge + pad + barH + pad + hXtiny + 2 + hXtiny;
        if (showIdealRange) {
            totalH = totalH + 2 + hXtiny;
        }
        var labelY = cy - totalH / 2;
        if (labelY < topSafe) { labelY = topSafe; }

        dc.setColor(available ? _domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Source badge subtitle
        if (hasSubtitle) {
            drawSourceSubtitle(dc, cx, labelY + hLabel + 1, badgeText, dateText);
        }

        // Value + unit
        var valueY = labelY + hLabel + subtitleH + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_LARGE,
            formatValue(metric) + " " + metric[:unit].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Zone bar
        var barY = valueY + hLarge + pad;
        var barX = pct(w, 14);
        var barW = pct(w, 72);

        // Zone hint and lower content
        var hintY = barY + barH + pad;
        var rangeY = hintY + hXtiny + 2;
        var idealY = rangeY + hXtiny + 2;

        // Overflow check: push everything up if bottom content exceeds safe zone
        var contentBottom = showIdealRange ? (idealY + hXtiny) : (rangeY + hXtiny);
        var overflow = contentBottom - bottomSafe;
        if (overflow > 0) {
            labelY -= overflow;
            if (labelY < topSafe) { labelY = topSafe; }
            valueY = labelY + hLabel + subtitleH + pad;
            barY = valueY + hLarge + pad;
            hintY = barY + barH + pad;
            rangeY = hintY + hXtiny + 2;
            idealY = rangeY + hXtiny + 2;
        }

        if (available) {
            drawDetailZoneBar(dc, barX, barY, barW, barH, metric, zone, policy);

            dc.setColor(_domain.zoneColor(metric, zone), Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, hintY, Graphics.FONT_XTINY,
                _domain.semanticZoneHint(metric),
                Graphics.TEXT_JUSTIFY_CENTER);

            var rangeText = _domain.zoneRangeText(metric);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, rangeY, Graphics.FONT_XTINY,
                rangeText, Graphics.TEXT_JUSTIFY_CENTER);

            if (showIdealRange) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, idealY, Graphics.FONT_XTINY,
                    text("detail.ideal") + _domain.idealRangeText(metric),
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, barY, Graphics.FONT_XTINY,
                text("hint.unavailable"),
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // --- Drawing Helpers ---

    function targetRangeDisplayIndex(metric as Dictionary, zone as Number) as Number {
        if (zone == ZONE_GREEN) {
            return 3;
        }

        var isLowSide = metric[:value] < metric[:greenMin];

        if (zone == ZONE_YELLOW) {
            return isLowSide ? 2 : 4;
        }

        if (zone == ZONE_ORANGE) {
            return isLowSide ? 1 : 5;
        }

        return isLowSide ? 0 : 6;
    }

    function drawZoneArc(dc as Dc, cx as Number, cy as Number, r as Number, metric as Dictionary, activeZone as Number, policy) as Void {
        var arcStarts;
        var arcEnds;
        var bright;
        var dim;
        var displayZone = activeZone;

        if (policy.equals(POLICY_LOW_ONLY)) {
            arcStarts = [240, 165, 90, 15];
            arcEnds   = [165, 90, 15, 300];
            bright = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN];
            dim    = [0x330000, 0x331A00, 0x333300, 0x003300];
            displayZone = 3 - activeZone;
        } else if (policy.equals(POLICY_TARGET_RANGE)) {
            arcStarts = [240, 205, 170, 135, 100, 65, 30];
            arcEnds   = [205, 170, 135, 100, 65, 30, 355];
            bright = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
            dim    = [0x330000, 0x331A00, 0x333300, 0x003300, 0x333300, 0x331A00, 0x330000];
            displayZone = targetRangeDisplayIndex(metric, activeZone);
        } else if (policy.equals(POLICY_REFERENCE_ONLY)) {
            arcStarts = [240, 165, 90, 15];
            arcEnds   = [165, 90, 15, 300];
            bright = [0x224466, 0x336699, 0x4D99CC, 0x66CCFF];
            dim    = [0x112233, 0x19334D, 0x204966, 0x2A607F];
        } else {
            arcStarts = [240, 165, 90, 15];
            arcEnds   = [165, 90, 15, 300];
            bright = [Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
            dim    = [0x003300, 0x333300, 0x331A00, 0x330000];
        }

        var thickPen = pct(cx * 2, 2);
        if (thickPen < 4) { thickPen = 4; }
        var glowExtra = (_animPhase == 1) ? 3 : 0;

        dc.setPenWidth(thickPen + 14 + glowExtra);
        dc.setColor(dim[displayZone], Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, arcStarts[displayZone], arcEnds[displayZone]);

        for (var i = 0; i < bright.size(); i++) {
            if (i == displayZone) {
                dc.setPenWidth(thickPen + 6 + glowExtra);
                dc.setColor(bright[i], Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setPenWidth(thickPen);
                dc.setColor(dim[i], Graphics.COLOR_TRANSPARENT);
            }
            dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, arcStarts[i], arcEnds[i]);
        }
        dc.setPenWidth(1);
    }

    function drawPageDots(dc as Dc, cx as Number, y as Number, screenW as Number) as Void {
        var count = _domain.metricsCount();
        var spacing = pct(screenW, 4);
        if (spacing < 10) { spacing = 10; }
        var activeR = pct(screenW, 1);
        if (activeR < 3) { activeR = 3; }
        var inactiveR = activeR - 2;
        if (inactiveR < 2) { inactiveR = 2; }
        var startX = cx - ((count - 1) * spacing) / 2;

        for (var i = 0; i < count; i++) {
            var dotX = startX + i * spacing;
            if (i == _selectedMetric) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, activeR);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, inactiveR);
            }
        }
    }

    function drawZoneSummary(dc as Dc, cx as Number, y as Number, screenW as Number) as Void {
        var colors = [Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
        var spacing = pct(screenW, 10);
        var dotR = pct(screenW, 1);
        if (dotR < 3) { dotR = 3; }
        var startX = cx - (3 * spacing) / 2;

        for (var i = 0; i < 4; i++) {
            var x = startX + i * spacing;
            var count = countByZone(i);
            dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x - dotR - 3, y, dotR);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + 2, y - 10, Graphics.FONT_XTINY,
                count.toString(), Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawDetailZoneBar(dc as Dc, x as Number, y as Number, w as Number, h as Number, metric as Dictionary, zone as Number, policy) as Void {
        var colors = [Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
        var highlights = [0x88FF88, 0xFFFF88, 0xFFBB66, 0xFF8888];
        var displayZone = zone;
        var segCount = 4;

        if (policy.equals(POLICY_LOW_ONLY)) {
            colors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN];
            highlights = [0xFF8888, 0xFFBB66, 0xFFFF88, 0x88FF88];
            displayZone = 3 - zone;
        } else if (policy.equals(POLICY_TARGET_RANGE)) {
            colors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
            highlights = [0xFF8888, 0xFFBB66, 0xFFFF88, 0x88FF88, 0xFFFF88, 0xFFBB66, 0xFF8888];
            displayZone = targetRangeDisplayIndex(metric, zone);
            segCount = 7;
        } else if (policy.equals(POLICY_REFERENCE_ONLY)) {
            colors = [0x224466, 0x336699, 0x4D99CC, 0x66CCFF];
            highlights = [0x335577, 0x4477AA, 0x66AAD9, 0x88DDFF];
        }

        var segW = w / segCount;
        var barR = h / 2;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.fillCircle(x + barR, y + barR, barR);
        dc.fillCircle(x + w - barR, y + barR, barR);
        dc.fillRectangle(x + barR, y, w - barR * 2, h);

        for (var i = 0; i < segCount; i++) {
            var sx = x + segW * i;
            var sw = (i < segCount - 1) ? segW + 1 : segW;
            dc.setColor(colors[i], colors[i]);
            dc.fillRectangle(sx, y, sw, h);
            dc.setColor(highlights[i], highlights[i]);
            dc.fillRectangle(sx, y, sw, h / 4);
        }

        dc.setColor(colors[0], colors[0]);
        dc.fillCircle(x + barR, y + barR, barR);
        dc.setColor(colors[segCount - 1], colors[segCount - 1]);
        dc.fillCircle(x + w - barR, y + barR, barR);

        var markerX = x + displayZone * segW + segW / 2;
        var markerY = y + h / 2;
        var outerR = h / 2 + 4;
        dc.setColor(colors[displayZone], colors[displayZone]);
        dc.fillCircle(markerX, markerY, outerR + 2);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillCircle(markerX, markerY, outerR);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillCircle(markerX, markerY, outerR - 3);
        dc.setColor(colors[displayZone], colors[displayZone]);
        dc.fillCircle(markerX, markerY, 4);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillCircle(markerX, markerY, 2);
    }

    // --- Formatting ---

    function formatValue(metric as Dictionary) as String {
        if (!metric[:available]) {
            return "--";
        }
        var rawValue = metric[:value];
        if (metric[:unit].toString().equals("kcal")) {
            return rawValue.toNumber().toString();
        }
        return fmtD2(rawValue.toFloat());
    }

    function countByZone(zone as Number) as Number {
        var count = 0;
        for (var i = 0; i < _domain.metricsCount(); i += 1) {
            var m = _domain.metricAt(i) as Dictionary;
            if (m[:available] && _domain.classify(m) == zone) {
                count += 1;
            }
        }
        return count;
    }

    // --- Trend Screen ---

    //! Cache trend data for the currently selected metric.
    function _cacheTrendData() as Void {
        if (_trendWindow == 0) {
            _trendWindow = _domain.historyBestWindow(_selectedMetric);
        }

        if (_trendWindow > 0) {
            var bestWindow = _domain.historyBestWindow(_selectedMetric);
            if (bestWindow > 0 && _domain.historyValues(_selectedMetric, _trendWindow).size() < 2) {
                _trendWindow = bestWindow;
            }
        }

        if (_trendWindow > 0) {
            _trendDirection = _domain.historyTrend(_selectedMetric, _trendWindow);
            _trendValues = _domain.historyValues(_selectedMetric, _trendWindow);
        } else {
            _trendDirection = TREND_FLAT;
            _trendValues = [];
        }
    }

    function _cycleTrendWindow(delta as Number) as Void {
        var currentIndex = 0;
        var windows = _availableTrendWindows();
        if (windows.size() == 0) {
            _trendWindow = 0;
            _cacheTrendData();
            return;
        }

        for (var i = 0; i < windows.size(); i += 1) {
            if ((windows[i] as Number) == _trendWindow) {
                currentIndex = i;
                break;
            }
        }

        currentIndex = (currentIndex + delta + windows.size()) % windows.size();
        _trendWindow = windows[currentIndex] as Number;
        _cacheTrendData();
    }

    function _availableTrendWindows() as Array {
        var windows = [] as Array;
        for (var i = 0; i < TREND_WINDOWS.size(); i += 1) {
            var candidate = TREND_WINDOWS[i] as Number;
            if (_domain.historyValues(_selectedMetric, candidate).size() >= 2) {
                windows.add(candidate);
            }
        }
        return windows;
    }

    //! Draw the trend/history screen with mini chart, trend indicator, and window label.
    function drawTrend(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? _domain.classify(metric) : ZONE_GREEN;

        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 2);
        if (pad < 3) { pad = 3; }

        // Metric label at top (round-screen-aware safe width)
        var topY = pct(h, 12);
        var labelText = _domain.metricLabel(_selectedMetric);
        var labelFont = Graphics.FONT_TINY;
        var labelSafeW = _availableWidthAtY(w, h, topY, dc.getFontHeight(labelFont)) - pct(w, 10);
        if (dc.getTextWidthInPixels(labelText, labelFont) > labelSafeW) {
            labelFont = Graphics.FONT_XTINY;
        }
        var labelH = dc.getFontHeight(labelFont);
        dc.setColor(available ? _domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, topY, labelFont, labelText, Graphics.TEXT_JUSTIFY_CENTER);

        // Current value + unit (round-screen-aware safe width)
        var valueY = topY + labelH + 2;
        var valueFont = Graphics.FONT_SMALL;
        var valueText = formatValue(metric) + " " + metric[:unit].toString();
        var valueSafeW = _availableWidthAtY(w, h, valueY, dc.getFontHeight(valueFont)) - pct(w, 10);
        if (dc.getTextWidthInPixels(valueText, valueFont) > valueSafeW) {
            valueFont = Graphics.FONT_TINY;
        }
        var valueH = dc.getFontHeight(valueFont);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, valueFont,
            valueText,
            Graphics.TEXT_JUSTIFY_CENTER);

        if (_trendWindow == 0 || (_trendValues as Array).size() < 2) {
            // No history data - show message
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h / 2, Graphics.FONT_XTINY,
                text("trend.no_data"), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var compactLayout = (_trendWindow >= 90 || w < 240);
            var bounds = _trendValueBounds(_trendValues as Array);
            var axisLabels = _trendAxisLabels(bounds, compactLayout);
            var axisLabelW = _maxTextWidth(dc, axisLabels, Graphics.FONT_XTINY);

            // Compute bottom positions first for round-screen-aware label width
            var windowY = h - pct(h, 10);
            var trendY = windowY - hXtiny - pad;
            var windowLabelMaxW = _availableWidthAtY(w, h, windowY, hXtiny) - pct(w, 4);
            var windowLabel = _trendWindowLabel(dc, Graphics.FONT_XTINY, windowLabelMaxW);

            // Mini chart
            var chartX = pct(w, 11) + axisLabelW;
            var chartRightPad = pct(w, 8);
            var chartY = valueY + valueH + pad + 2;
            var chartH = trendY - chartY - pad;
            var minChartH = pct(h, 22);
            if (minChartH < 34) { minChartH = 34; }
            if (chartH < minChartH) {
                chartH = minChartH;
                chartY = trendY - pad - chartH;
            }
            var chartW = w - chartX - chartRightPad;
            var lineColor = available ? _domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY;
            drawMiniChart(dc, chartX, chartY, chartW, chartH, _trendValues as Array, lineColor,
                bounds, axisLabels, compactLayout);

            // Trend label + arrow
            var trendLabel = "";
            if (_trendDirection == TREND_UP) {
                trendLabel = text("trend.up");
            } else if (_trendDirection == TREND_DOWN) {
                trendLabel = text("trend.down");
            } else {
                trendLabel = text("trend.flat");
            }

            var arrowSize = pct(w, 2);
            if (arrowSize < 5) { arrowSize = 5; }
            var labelW = dc.getTextWidthInPixels(trendLabel, Graphics.FONT_XTINY);
            var arrowX = cx - labelW / 2 - arrowSize - 4;
            var arrowY = trendY + hXtiny / 2;

            var arrowColor = _trendArrowColor(_selectedMetric, _trendDirection);
            if (_trendDirection == TREND_UP) {
                dc.setColor(arrowColor, Graphics.COLOR_TRANSPARENT);
                drawTriangle(dc, arrowX, arrowY, arrowSize, true);
            } else if (_trendDirection == TREND_DOWN) {
                dc.setColor(arrowColor, Graphics.COLOR_TRANSPARENT);
                drawTriangle(dc, arrowX, arrowY, arrowSize, false);
            } else {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(arrowX - arrowSize / 2, arrowY - 1, arrowSize, 3);
            }

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, trendY, Graphics.FONT_XTINY,
                trendLabel, Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, windowY, Graphics.FONT_XTINY,
                windowLabel,
                Graphics.TEXT_JUSTIFY_CENTER);

        }

        // Vertical scroll dots (window indicator) on the left edge
        drawVerticalScrollDots(dc, pct(w, 8), h / 2, h);
    }

    //! Draw a mini line chart within the given bounding box.
    function drawMiniChart(dc as Dc, x as Number, y as Number, w as Number, h as Number,
        values as Array, lineColor, bounds as Dictionary, axisLabels as Array, compactLayout as Boolean) as Void {
        if (values.size() < 2) { return; }

        var minV = bounds[:minV].toFloat();
        var range = bounds[:range].toFloat();

        // Time range
        var tsMin = (values[0] as Dictionary)[:ts].toNumber();
        var tsMax = (values[values.size() - 1] as Dictionary)[:ts].toNumber();
        var tsRange = tsMax - tsMin;
        if (tsRange < 1) { tsRange = 1; }

        // Plot area padding to prevent the line from visually becoming the x-axis.
        var plotPadX = compactLayout ? 2 : 3;
        var plotPadY = compactLayout ? 4 : 3;
        var plotX = x + plotPadX;
        var plotY = y + plotPadY;
        var plotW = w - plotPadX * 2;
        var plotH = h - plotPadY * 2;
        if (plotW < 10 || plotH < 10) { return; }

        // Map to pixel coordinates
        var pts = new [values.size()];
        for (var i = 0; i < values.size(); i++) {
            var entry = values[i] as Dictionary;
            var px = plotX + ((entry[:ts].toNumber() - tsMin) * plotW / tsRange);
            var fpy = (entry[:val].toFloat() - minV) * plotH.toFloat() / range;
            var py = plotY + plotH - fpy.toNumber();
            pts[i] = [px, py];
        }

        // Subtle horizontal grid lines (top and middle only)
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(plotX, plotY, plotX + plotW, plotY);
        dc.drawLine(plotX, plotY + plotH / 2, plotX + plotW, plotY + plotH / 2);

        // Y-axis numeric references
        var axisFont = Graphics.FONT_XTINY;
        var axisX = x - 4;
        var axisColor = 0x777777;
        var axisH = dc.getFontHeight(axisFont);
        dc.setColor(axisColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(axisX, y - axisH / 2, axisFont,
            axisLabels[0] as String, Graphics.TEXT_JUSTIFY_RIGHT);
        if (axisLabels[1] != null) {
            dc.drawText(axisX, y + h / 2 - axisH / 2, axisFont,
                axisLabels[1] as String, Graphics.TEXT_JUSTIFY_RIGHT);
        }
        dc.drawText(axisX, y + h - axisH, axisFont,
            axisLabels[2] as String, Graphics.TEXT_JUSTIFY_RIGHT);

        // Connecting lines
        dc.setPenWidth(compactLayout ? 1 : 2);
        dc.setColor(lineColor, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < pts.size() - 1; i++) {
            var p1 = pts[i] as Array;
            var p2 = pts[i + 1] as Array;
            dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
        }
        dc.setPenWidth(1);

        // Data point dots (last point larger)
        var dotStep = values.size() / 24;
        if (dotStep < 1) { dotStep = 1; }
        for (var i = 0; i < pts.size(); i++) {
            if (i != pts.size() - 1 && (i % dotStep) != 0) {
                continue;
            }
            var p = pts[i] as Array;
            var dotR = (i == pts.size() - 1) ? 4 : (compactLayout ? 1 : 2);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(p[0], p[1], dotR);
        }
    }

    //! Draw vertical scroll dots (Garmin-style page indicator for UP/DOWN scrolling).
    //! Shows only the currently available trend windows for the selected metric.
    function drawVerticalScrollDots(dc as Dc, x as Number, cy as Number, screenH as Number) as Void {
        var windows = _availableTrendWindows();
        var count = windows.size();
        if (count == 0) { return; }

        var spacing = pct(screenH, 4);
        if (spacing < 8) { spacing = 8; }
        var activeR = 4;
        var inactiveR = 2;
        var startY = cy - ((count - 1) * spacing) / 2;

        var currentIndex = 0;
        for (var i = 0; i < windows.size(); i += 1) {
            if ((windows[i] as Number) == _trendWindow) {
                currentIndex = i;
                break;
            }
        }

        for (var i = 0; i < count; i++) {
            var dotY = startY + i * spacing;
            if (i == currentIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, dotY, activeR);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, dotY, inactiveR);
            }
        }
    }

    //! Returns the appropriate color for a trend arrow based on metric and direction.
    //! For "lower is better" metrics (BMI, fat%, weight): DOWN=green, UP=red.
    //! For "higher is better" metrics (muscle%, muscleKg, water%, bone, BMR): UP=green, DOWN=red.
    function _trendArrowColor(metricIndex as Number, direction as Number) as Number {
        // Metrics where LOWER is better: BMI(0), fat%(1), weight(6)
        // Metrics where HIGHER is better: muscleKg(2), muscle%(3), water%(4), bone(5), BMR(7)
        var lowerIsBetter = (metricIndex == 0 || metricIndex == 1 || metricIndex == 6);

        if (direction == TREND_UP) {
            return lowerIsBetter ? Graphics.COLOR_RED : Graphics.COLOR_GREEN;
        } else if (direction == TREND_DOWN) {
            return lowerIsBetter ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
        }
        return Graphics.COLOR_YELLOW;
    }

    function _trendValueBounds(values as Array) as Dictionary {
        var minV = (values[0] as Dictionary)[:val].toFloat();
        var maxV = minV;
        for (var i = 1; i < values.size(); i++) {
            var v = (values[i] as Dictionary)[:val].toFloat();
            if (v < minV) { minV = v; }
            if (v > maxV) { maxV = v; }
        }

        var range = maxV - minV;
        if (range < 0.01) { range = 1.0; }
        var vPad = range * 0.15;
        minV = minV - vPad;
        maxV = maxV + vPad;
        range = maxV - minV;

        return {
            :minV => minV,
            :maxV => maxV,
            :midV => minV + range / 2.0,
            :range => range
        };
    }

    function _trendAxisLabels(bounds as Dictionary, compactLayout as Boolean) as Array {
        var range = bounds[:range].toFloat();
        var topLabel = _formatAxisValue(bounds[:maxV].toFloat(), range, compactLayout);
        var midLabel = compactLayout ? null : _formatAxisValue(bounds[:midV].toFloat(), range, compactLayout);
        var bottomLabel = _formatAxisValue(bounds[:minV].toFloat(), range, compactLayout);
        return [topLabel, midLabel, bottomLabel];
    }

    function _maxTextWidth(dc as Dc, values as Array, font) as Number {
        var maxWidth = 0;
        for (var i = 0; i < values.size(); i++) {
            var value = values[i];
            if (value == null) { continue; }
            var width = dc.getTextWidthInPixels(value as String, font);
            if (width > maxWidth) {
                maxWidth = width;
            }
        }
        return maxWidth;
    }

    //! Compute the usable horizontal width at a given Y on a round screen.
    //! Uses the most constrained edge (top or bottom of text) to avoid clipping.
    function _availableWidthAtY(screenW as Number, screenH as Number, textY as Number, textH as Number) as Number {
        var r = screenW < screenH ? screenW / 2 : screenH / 2;
        var cy = screenH / 2;
        var dyTop = textY - cy;
        if (dyTop < 0) { dyTop = -dyTop; }
        var dyBottom = (textY + textH) - cy;
        if (dyBottom < 0) { dyBottom = -dyBottom; }
        var dy = dyTop > dyBottom ? dyTop : dyBottom;
        if (dy >= r) { return 24; }
        return (Math.sqrt((r * r - dy * dy).toFloat()).toNumber()) * 2;
    }

    function _trendWindowLabel(dc as Dc, font, maxWidth as Number) as String {
        var fullLabel = text("trend.last_prefix") + " " + _trendWindow.toString() + " " + text("trend.last_suffix");
        if (dc.getTextWidthInPixels(fullLabel, font) <= maxWidth) {
            return fullLabel;
        }

        var compactLabel = _trendWindow.toString() + " " + text("trend.last_suffix_short");
        if (dc.getTextWidthInPixels(compactLabel, font) <= maxWidth) {
            return compactLabel;
        }
        return _trendWindow.toString();
    }

    function _formatAxisValue(value as Float, range as Float, compactLayout as Boolean) as String {
        return fmt1Global(value);
    }

}

//! Percentage of a total value.
function pct(total as Number, percent as Number) as Number {
    return total * percent / 100;
}
