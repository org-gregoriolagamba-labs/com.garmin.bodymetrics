import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class BodyMetricsView extends WatchUi.View {

    const MODE_SUMMARY = 0;
    const MODE_DETAIL = 1;
    const MODE_SETUP = 2;

    var _mode;
    var _selectedMetric;
    var _domain;
    var _animPhase;
    var _animTimer;
    var _setupIndex;
    var _profileDraft;
    function initialize() {
        View.initialize();
        _mode = MODE_SUMMARY;
        _selectedMetric = 0;
        _domain = new BodyMetricsDomain();
        _animPhase = 0;
        _animTimer = null;
        _setupIndex = 0;
        _profileDraft = _domain.currentProfile();

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
    }

    function onUpdate(dc as Dc) as Void {
        System.println("onUpdate mode=" + _mode);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_mode == MODE_SETUP) {
            drawSetup(dc);
        } else if (_mode == MODE_SUMMARY) {
            drawSummary(dc);
        } else {
            drawDetail(dc);
        }
        System.println("onUpdate done");
    }

    function onHide() as Void {
        System.println("onHide");
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

    function canOpenMenu() as Boolean {
        return (_mode == MODE_SUMMARY || _mode == MODE_DETAIL) && _domain.hasConfiguredProfile();
    }

    function nextMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, 1);
            WatchUi.requestUpdate();
            return;
        }

        _selectedMetric = (_selectedMetric + 1) % _domain.metricsCount();
        WatchUi.requestUpdate();
    }

    function previousMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, -1);
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

        if (_mode == MODE_SUMMARY) {
            _mode = MODE_DETAIL;
        } else {
            _mode = MODE_SUMMARY;
        }
        WatchUi.requestUpdate();
    }

    function handleBack() as Boolean {
        System.println("handleBack mode=" + _mode);
        if (_mode == MODE_SETUP) {
            if (_setupIndex > 0) {
                _setupIndex -= 1;
            } else if (_domain.hasConfiguredProfile()) {
                _mode = MODE_SUMMARY;
            }
            WatchUi.requestUpdate();
            System.println("handleBack setup->true");
            return true;
        }

        if (_mode == MODE_DETAIL) {
            _mode = MODE_SUMMARY;
            WatchUi.requestUpdate();
            System.println("handleBack detail->true");
            return true;
        }

        System.println("handleBack summary->true (stay)");
        return true;
    }

    function drawSetup(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var field = _domain.profileFieldDefinition(_setupIndex) as Dictionary;
        var totalSteps = _domain.profileFieldCount();

        // Measure fonts for dynamic layout
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var hTiny = dc.getFontHeight(Graphics.FONT_TINY);
        var hMedium = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var gap = pct(h, 2);

        // --- Central content block: label + value, centered vertically ---
        var centralH = hTiny + gap + hMedium;
        var labelY = cy - centralH / 2;
        var valueY = labelY + hTiny + gap;

        // Field label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, Graphics.FONT_TINY,
            field[:label].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Field value (large, white, prominent)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var valueText = _domain.profileFieldValueLabel(_profileDraft, _setupIndex);
        var valueFont = Graphics.FONT_MEDIUM;
        var safeW = pct(w, 65);
        if (dc.getTextWidthInPixels(valueText, valueFont) > safeW) {
            valueFont = Graphics.FONT_SMALL;
        }
        dc.drawText(cx, valueY, valueFont, valueText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // --- Top: progress dots ---
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
            if (i < _setupIndex) {
                dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else if (i == _setupIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, inactiveR);
            }
        }

        // --- Title below dots ---
        var titleY = dotsY + activeR + gap + 2;
        dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_XTINY,
            _domain.hasConfiguredProfile() ? "Modifica profilo" : "Configura profilo",
            Graphics.TEXT_JUSTIFY_CENTER);

        // --- Arrows hint (up/down triangles flanking the value) ---
        var arrowY = valueY + dc.getFontHeight(valueFont) / 2;
        var arrowX = pct(w, 12);
        dc.setColor(0x66CCFF, Graphics.COLOR_TRANSPARENT);
        // Up arrow (left side)
        drawTriangle(dc, arrowX, arrowY, pct(w, 2), true);
        // Down arrow (right side)
        drawTriangle(dc, w - arrowX, arrowY, pct(w, 2), false);

        // --- Bottom: action hint ---
        var footerY = h - pct(h, 16) - hXtiny;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, footerY, Graphics.FONT_XTINY,
            _setupIndex == totalSteps - 1 ? "SELECT  salva" : "SELECT  avanti",
            Graphics.TEXT_JUSTIFY_CENTER);
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
        var zone = _domain.classify(metric);

        var policy = _domain.classificationPolicy(metric);

        // Zone arc at perimeter
        drawZoneArc(dc, cx, cy, cx - pct(w, 2), metric, zone, policy);

        // Font heights for flow layout
        var hTiny = dc.getFontHeight(Graphics.FONT_TINY);
        var hNumMild = dc.getFontHeight(Graphics.FONT_NUMBER_MILD);
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 2);

        // Metric label (auto-shrink if too wide)
        var labelY = pct(h, 17);
        var labelText = _domain.metricLabel(_selectedMetric);
        var labelFont = Graphics.FONT_TINY;
        var safeW = pct(w, 80);
        if (dc.getTextWidthInPixels(labelText, labelFont) > safeW) {
            labelFont = Graphics.FONT_XTINY;
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Hero value
        var valueY = labelY + hTiny + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_NUMBER_MILD,
            formatValue(metric),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Unit
        var unitY = valueY + hNumMild + pad;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, unitY, Graphics.FONT_TINY,
            metric[:unit].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Semantic zone hint (colored)
        var hintY = unitY + hTiny + pct(h, 3);
        var dotsY = hintY + hXtiny + pct(h, 2);
        var summaryY = dotsY + pct(h, 5);
        var summarySafeBottom = h - pct(h, 9);
        var summaryOverflow = (summaryY + hXtiny) - summarySafeBottom;
        if (summaryOverflow > 0) {
            hintY -= summaryOverflow;
            dotsY -= summaryOverflow;
            summaryY -= summaryOverflow;
        }

        dc.setColor(_domain.zoneColor(metric, zone), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hintY, Graphics.FONT_XTINY,
            _domain.semanticZoneHint(metric),
            Graphics.TEXT_JUSTIFY_CENTER);

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
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        var zone = _domain.classify(metric);
        var policy = _domain.classificationPolicy(metric);

        var hLarge = dc.getFontHeight(Graphics.FONT_LARGE);
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 1);
        if (pad < 4) { pad = 4; }
        var barH = pct(h, 4);
        if (barH < 18) { barH = 18; }

        // Metric label in zone color (auto-shrink if too wide)
        var labelY = pct(h, 12);
        var labelText = _domain.metricLabel(_selectedMetric);
        var labelFont = Graphics.FONT_SMALL;
        var safeW = pct(w, 80);
        if (dc.getTextWidthInPixels(labelText, labelFont) > safeW) {
            labelFont = Graphics.FONT_TINY;
        }
        var hLabel = dc.getFontHeight(labelFont);
        dc.setColor(_domain.zoneColor(metric, zone), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText,
            Graphics.TEXT_JUSTIFY_CENTER);

        // Value + unit
        var valueY = labelY + hLabel + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_LARGE,
            formatValue(metric) + " " + metric[:unit].toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Zone bar
        var barY = valueY + hLarge + pad + pct(h, 1);
        var barX = pct(w, 14);
        var barW = pct(w, 72);

        // Zone hint and lower safe area
        var hintY = barY + barH + pad + 2;
        var rangeY = hintY + hXtiny + 2;
        var bottomSafe = h - pct(h, 10);
        var overflow = (rangeY + hXtiny) - bottomSafe;
        if (overflow > 0) {
            barY -= overflow;
            hintY -= overflow;
            rangeY -= overflow;
        }

        drawDetailZoneBar(dc, barX, barY, barW, barH, metric, zone, policy);

        dc.setColor(_domain.zoneColor(metric, zone), Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hintY, Graphics.FONT_XTINY,
            _domain.semanticZoneHint(metric),
            Graphics.TEXT_JUSTIFY_CENTER);

        var rangeText = _domain.zoneRangeText(metric);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, rangeY, Graphics.FONT_XTINY,
            rangeText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // --- Drawing Helpers ---

    function pct(total as Number, percent as Number) as Number {
        return total * percent / 100;
    }

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

    // --- Formatting (2 decimal places) ---

    function formatValue(metric as Dictionary) as String {
        var rawValue = metric[:value];
        if (metric[:unit].toString().equals("kcal")) {
            return rawValue.toNumber().toString();
        }
        return fmt2(rawValue.toFloat());
    }

    function fmt2(v as Float) as String {
        var sign = "";
        if (v < 0) {
            sign = "-";
            v = -v;
        }
        var hundredths = Math.round(v * 100.0).toNumber();
        var integer = hundredths / 100;
        var frac = hundredths - integer * 100;
        var fracStr;
        if (frac < 10) {
            fracStr = "0" + frac.toString();
        } else {
            fracStr = frac.toString();
        }
        return sign + integer.toString() + "." + fracStr;
    }

    function countByZone(zone as Number) as Number {
        var count = 0;
        for (var i = 0; i < _domain.metricsCount(); i += 1) {
            if (_domain.classify(_domain.metricAt(i)) == zone) {
                count += 1;
            }
        }
        return count;
    }

}

