import Toybox.Graphics;
import Toybox.Lang;

//! Dedicated renderer for summary and detail screens.
class BodyMetricsSummaryDetailRenderer {

    const COLOR_ACCENT = 0x66CCFF;
    const COLOR_ACCENT_DIM = 0x224466;

    function initialize() {
    }

    //! Draw summary screen and return info icon hitbox.
    function drawSummary(dc as Dc, model as Dictionary) as Dictionary {
        var domain = model[:domain];
        var selectedMetric = model[:selectedMetric].toNumber();
        var animPhase = model[:animPhase].toNumber();
        var hintUnavailableText = model[:hintUnavailableText].toString();

        var dateText = "";
        var dateTextObj = model[:dateText];
        if (dateTextObj != null) {
            dateText = dateTextObj.toString();
        }

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var metric = domain.metricAt(selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? domain.classify(metric) : ZONE_GREEN;
        var policy = domain.classificationPolicy(metric);

        // Zone arc at perimeter.
        if (available) {
            _drawZoneArc(dc, cx, cy, cx - pct(w, 2), metric, zone, policy, animPhase);
        }

        var hNumMild = dc.getFontHeight(Graphics.FONT_NUMBER_MILD);
        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = pct(h, 1);
        if (pad < 2) { pad = 2; }

        var topSafe = pct(h, 15);
        var bottomSafe = h - pct(h, 8);

        var labelText = domain.metricLabel(selectedMetric);
        var labelFont = Graphics.FONT_TINY;
        var labelSafeW = availableWidthAtYGlobal(w, h, topSafe, dc.getFontHeight(labelFont)) - pct(w, 10);
        var iconExtraW = 22;
        if (dc.getTextWidthInPixels(labelText, labelFont) + iconExtraW > labelSafeW) {
            labelFont = Graphics.FONT_XTINY;
        }
        var hLabelFont = dc.getFontHeight(labelFont);

        var dotsH = pct(h, 4);
        var totalH = hLabelFont + pad + hNumMild + pad + hXtiny + pad + hXtiny + dotsH;
        var labelY = cy - totalH / 2;
        if (labelY < topSafe) { labelY = topSafe; }

        dc.setColor(available ? domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText, Graphics.TEXT_JUSTIFY_CENTER);

        var iconHitbox = _drawInfoIcon(dc, cx, labelY, labelText, labelFont);

        var dateH = 0;
        if (!dateText.equals("")) {
            dateH = dc.getFontHeight(Graphics.FONT_XTINY);
            var dateY = labelY + hLabelFont + pct(h, 1);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, dateY, Graphics.FONT_XTINY, dateText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        var valueY = labelY + hLabelFont + dateH + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_NUMBER_MILD, _formatValue(metric), Graphics.TEXT_JUSTIFY_CENTER);

        var unitY = valueY + hNumMild + pad;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, unitY, Graphics.FONT_XTINY, metric[:unit].toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var hintY = unitY + hXtiny + pad;
        var hintText = available ? domain.semanticZoneHint(metric) : hintUnavailableText;
        var hintLayout = fitTextBlockGlobal(dc, hintText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, pct(w, 72));
        var dotsY = hintY + hintLayout[:height] + pct(h, 3);

        var overflow = dotsY - bottomSafe;
        if (overflow > 0) {
            hintY -= overflow;
            dotsY -= overflow;
        }

        if (available) {
            drawCenteredTextBlockGlobal(dc, cx, hintY, hintLayout, domain.zoneColor(metric, zone));
        } else {
            drawCenteredTextBlockGlobal(dc, cx, hintY, hintLayout, Graphics.COLOR_DK_GRAY);
        }

        _drawPageDots(dc, cx, dotsY, w, domain.metricsCount(), selectedMetric, domain.priorityMetricIndex());
        return iconHitbox;
    }

    function drawDetail(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var selectedMetric = model[:selectedMetric].toNumber();
        var hintUnavailableText = model[:hintUnavailableText].toString();
        var detailIdealPrefix = model[:detailIdealPrefix].toString();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var metric = domain.metricAt(selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? domain.classify(metric) : ZONE_GREEN;
        var policy = domain.classificationPolicy(metric);
        var showIdealRange = available && zone != ZONE_GREEN;

        var hLarge = dc.getFontHeight(Graphics.FONT_LARGE);
        var pad = pct(h, 1);
        if (pad < 3) { pad = 3; }
        var barH = pct(h, 4);
        if (barH < 16) { barH = 16; }

        var topSafe = pct(h, 11);
        var bottomSafe = h - pct(h, 9);

        var labelFont = Graphics.FONT_SMALL;
        var labelText = domain.metricLabel(selectedMetric);
        var safeW = availableWidthAtYGlobal(w, h, topSafe, dc.getFontHeight(labelFont)) - pct(w, 10);
        if (dc.getTextWidthInPixels(labelText, labelFont) > safeW) {
            labelFont = Graphics.FONT_TINY;
        }
        var hLabel = dc.getFontHeight(labelFont);

        var detailSafeW = pct(w, 74);
        var hintText = available ? domain.semanticZoneHint(metric) : hintUnavailableText;
        var hintLayout = fitTextBlockGlobal(dc, hintText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, detailSafeW);
        var rangeLayout = available ? fitTextBlockGlobal(dc, domain.zoneRangeText(metric), Graphics.FONT_XTINY, Graphics.FONT_XTINY, detailSafeW) : null;
        var idealLayout = showIdealRange
            ? fitTextBlockGlobal(dc, detailIdealPrefix + domain.idealRangeText(metric), Graphics.FONT_XTINY, Graphics.FONT_XTINY, detailSafeW)
            : null;

        var totalH = hLabel + pad + hLarge + pad + barH + pad + hintLayout[:height];
        if (available) {
            totalH += 2 + rangeLayout[:height];
        }
        if (showIdealRange) {
            totalH += 2 + idealLayout[:height];
        }
        var labelY = cy - totalH / 2;
        if (labelY < topSafe) { labelY = topSafe; }

        dc.setColor(available ? domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, labelY, labelFont, labelText, Graphics.TEXT_JUSTIFY_CENTER);

        var valueY = labelY + hLabel + pad;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, Graphics.FONT_LARGE, _formatValue(metric) + " " + metric[:unit].toString(), Graphics.TEXT_JUSTIFY_CENTER);

        var barY = valueY + hLarge + pad;
        var barX = pct(w, 14);
        var barW = pct(w, 72);

        var hintY = barY + barH + pad;
        var rangeY = hintY + hintLayout[:height] + 2;
        var idealY = rangeY + (available ? rangeLayout[:height] : 0) + 2;
        var afterRangeY = available ? (rangeY + rangeLayout[:height]) : (hintY + hintLayout[:height]);
        var afterIdealY = showIdealRange ? (idealY + idealLayout[:height]) : afterRangeY;
        var dotsY = afterIdealY + pct(h, 3);

        var overflow = dotsY - bottomSafe;
        if (overflow > 0) {
            labelY -= overflow;
            if (labelY < topSafe) { labelY = topSafe; }
            valueY = labelY + hLabel + pad;
            barY = valueY + hLarge + pad;
            hintY = barY + barH + pad;
            rangeY = hintY + hintLayout[:height] + 2;
            idealY = rangeY + (available ? rangeLayout[:height] : 0) + 2;
            afterRangeY = available ? (rangeY + rangeLayout[:height]) : (hintY + hintLayout[:height]);
            afterIdealY = showIdealRange ? (idealY + idealLayout[:height]) : afterRangeY;
            dotsY = afterIdealY + pct(h, 3);
        }

        if (available) {
            _drawDetailZoneBar(dc, barX, barY, barW, barH, metric, zone, policy);
            drawCenteredTextBlockGlobal(dc, cx, hintY, hintLayout, domain.zoneColor(metric, zone));
            drawCenteredTextBlockGlobal(dc, cx, rangeY, rangeLayout, Graphics.COLOR_DK_GRAY);

            if (showIdealRange) {
                drawCenteredTextBlockGlobal(dc, cx, idealY, idealLayout, Graphics.COLOR_LT_GRAY);
            }
        } else {
            drawCenteredTextBlockGlobal(dc, cx, hintY, hintLayout, Graphics.COLOR_DK_GRAY);
        }

        _drawPageDots(dc, cx, dotsY, w, domain.metricsCount(), selectedMetric, -1);
    }

    function _targetRangeDisplayIndex(metric as Dictionary, zone as Number) as Number {
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

    function _drawZoneArc(dc as Dc, cx as Number, cy as Number, r as Number,
        metric as Dictionary, activeZone as Number, policy, animPhase as Number) as Void {
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
        } else if (policy.equals(POLICY_REFERENCE_ONLY)) {
            arcStarts = [240, 165, 90, 15];
            arcEnds   = [165, 90, 15, 300];
            bright = [COLOR_ACCENT_DIM, 0x336699, 0x4D99CC, COLOR_ACCENT];
            dim    = [0x112233, 0x19334D, 0x204966, 0x2A607F];
        } else {
            arcStarts = [240, 205, 170, 135, 100, 65, 30];
            arcEnds   = [205, 170, 135, 100, 65, 30, 355];
            bright = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
            dim    = [0x330000, 0x331A00, 0x333300, 0x003300, 0x333300, 0x331A00, 0x330000];
            displayZone = _targetRangeDisplayIndex(metric, activeZone);
        }

        var thickPen = pct(cx * 2, 2);
        if (thickPen < 4) { thickPen = 4; }
        var glowExtra = (animPhase == 1) ? 3 : 0;

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

    function _drawPageDots(dc as Dc, cx as Number, y as Number, screenW as Number,
        count as Number, selectedMetric as Number, priorityIndex as Number) as Void {
        var spacing = pct(screenW, 4);
        if (spacing < 10) { spacing = 10; }
        var activeR = pct(screenW, 1);
        if (activeR < 3) { activeR = 3; }
        var inactiveR = activeR - 2;
        if (inactiveR < 2) { inactiveR = 2; }
        var startX = cx - ((count - 1) * spacing) / 2;

        for (var i = 0; i < count; i++) {
            var dotX = startX + i * spacing;
            if (i == selectedMetric) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, y, activeR);
            } else {
                if (priorityIndex == i) {
                    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                }
                dc.fillCircle(dotX, y, inactiveR);
            }
        }
    }

    function _drawInfoIcon(dc as Dc, cx as Number, labelY as Number, labelText as String, labelFont) as Dictionary {
        var labelW = dc.getTextWidthInPixels(labelText, labelFont);
        var labelH = dc.getFontHeight(labelFont);
        var r = 7;
        var iconX = cx + labelW / 2 + r + 4;
        var iconY = labelY + labelH / 2;

        dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(iconX, iconY, r);

        var dotR = 1;
        var dotY = iconY - r / 2;
        dc.fillCircle(iconX, dotY, dotR);

        var stemW = 2;
        var stemH = r - 2;
        var stemY = dotY + dotR + 2;
        dc.fillRectangle(iconX - stemW / 2, stemY, stemW, stemH);

        return {
            :iconX => iconX,
            :iconY => iconY,
            :iconR => r
        };
    }

    function _drawDetailZoneBar(dc as Dc, x as Number, y as Number, w as Number, h as Number,
        metric as Dictionary, zone as Number, policy) as Void {
        var colors = [Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
        var highlights = [0x88FF88, 0xFFFF88, 0xFFBB66, 0xFF8888];
        var displayZone = zone;
        var segCount = 4;

        if (policy.equals(POLICY_LOW_ONLY)) {
            colors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN];
            highlights = [0xFF8888, 0xFFBB66, 0xFFFF88, 0x88FF88];
            displayZone = 3 - zone;
        } else if (policy.equals(POLICY_REFERENCE_ONLY)) {
            colors = [COLOR_ACCENT_DIM, 0x336699, 0x4D99CC, COLOR_ACCENT];
            highlights = [0x335577, 0x4477AA, 0x66AAD9, 0x88DDFF];
        } else {
            colors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];
            highlights = [0xFF8888, 0xFFBB66, 0xFFFF88, 0x88FF88, 0xFFFF88, 0xFFBB66, 0xFF8888];
            displayZone = _targetRangeDisplayIndex(metric, zone);
            segCount = 7;
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

    function _formatValue(metric as Dictionary) as String {
        if (!metric[:available]) {
            return "--";
        }
        return _fmt1(metric[:value].toFloat());
    }

    function _fmt1(v as Float) as String {
        var scaled = Math.round(_round1(v) * 10.0).toNumber();
        var whole = scaled / 10;
        var frac = scaled - whole * 10;
        if (frac < 0) { frac = -frac; }
        return whole.toString() + "." + frac.toString();
    }

    function _round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }
}