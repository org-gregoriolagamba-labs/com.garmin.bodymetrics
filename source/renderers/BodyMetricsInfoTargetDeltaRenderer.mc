import Toybox.Graphics;
import Toybox.Lang;

//! Dedicated renderer for info and target-delta screens.
class BodyMetricsInfoTargetDeltaRenderer {

    const COLOR_ACCENT = 0x66CCFF;
    const COLOR_ACCENT_DIM = 0x224466;

    function initialize() {
    }

    //! Draw info screen and return updated scroll/content state.
    function drawInfo(dc as Dc, model as Dictionary) as Dictionary {
        var domain = model[:domain];
        var selectedMetric = model[:selectedMetric].toNumber();
        var infoScrollY = model[:infoScrollY].toNumber();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var metric = domain.metricAt(selectedMetric) as Dictionary;
        var info = domain.metricInfo(selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? domain.classify(metric) : ZONE_GREEN;

        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        var topMargin = pct(h, 10);
        var titleFont = Graphics.FONT_TINY;
        var contentTop = topMargin + dc.getFontHeight(titleFont) + pct(h, 2);
        var visibleH = h - contentTop - pct(h, 15);
        var visibleBottom = contentTop + visibleH;

        var wTop = availableWidthAtYGlobal(w, h, contentTop, lineH) - pct(w, 14);
        var wBot = availableWidthAtYGlobal(w, h, visibleBottom - lineH, lineH) - pct(w, 14);
        var safeW = wTop < wBot ? wTop : wBot;
        var textLeft = pct(w, 11);
        var itemW = safeW;

        dc.setColor(available ? domain.zoneColor(metric, zone) : COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, topMargin, titleFont, domain.metricLabel(selectedMetric), Graphics.TEXT_JUSTIFY_CENTER);

        var allLines = [] as Array;

        var descLines = wrapTextGlobal(dc, info[:description].toString(), font, safeW);
        for (var b = 0; b < descLines.size(); b += 1) {
            allLines.add({:text => descLines[b].toString(), :type => :body});
        }

        allLines.add({:text => "", :type => :empty});
        var rangeLines = info[:rangeLines] as Array;
        for (var r = 0; r < rangeLines.size(); r += 1) {
            var item = rangeLines[r] as Dictionary;
            var lbl = item[:label].toString();
            var val = item[:value].toString();
            if (lbl.equals("") && val.equals("")) {
                allLines.add({:text => "", :type => :empty});
            } else {
                if (!lbl.equals("")) {
                    var labelWrapped = wrapTextGlobal(dc, lbl, font, itemW);
                    for (var li = 0; li < labelWrapped.size(); li += 1) {
                        allLines.add({:text => labelWrapped[li].toString(), :type => :rangeLabel});
                    }
                }
                if (!val.equals("")) {
                    var valueWrapped = wrapTextGlobal(dc, val, font, itemW);
                    for (var vi = 0; vi < valueWrapped.size(); vi += 1) {
                        allLines.add({:text => valueWrapped[vi].toString(), :type => :rangeValue});
                    }
                }
                allLines.add({:text => "", :type => :empty});
            }
        }

        var infoContentH = allLines.size() * lineH;
        var maxScroll = infoContentH - visibleH;
        if (maxScroll < 0) { maxScroll = 0; }
        if (infoScrollY > maxScroll) { infoScrollY = maxScroll; }
        if (infoScrollY < 0) { infoScrollY = 0; }

        dc.setClip(0, contentTop, w, visibleH);
        var y = contentTop - infoScrollY;
        for (var i = 0; i < allLines.size(); i += 1) {
            var line = allLines[i] as Dictionary;
            var lineType = line[:type];
            if (y + lineH > contentTop - lineH && y < contentTop + visibleH + lineH) {
                if (lineType == :heading) {
                    dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                } else if (lineType == :body) {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                } else if (lineType == :rangeLabel) {
                    dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(textLeft, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_LEFT);
                } else if (lineType == :rangeValue) {
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(textLeft, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_LEFT);
                }
            }
            y += lineH;
        }
        dc.clearClip();

        if (maxScroll > 0) {
            var trackH = visibleH - 8;
            var trackY = contentTop + 4;
            var thumbH = trackH * visibleH / infoContentH;
            if (thumbH < 8) { thumbH = 8; }
            var thumbY = trackY + (infoScrollY * (trackH - thumbH) / maxScroll);
            var trackX = w - pct(w, 5);
            dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(trackX, trackY, 3, trackH);
            dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(trackX, thumbY, 3, thumbH);
        }

        return {
            :infoScrollY => infoScrollY,
            :infoContentH => infoContentH
        };
    }

    function drawTargetDelta(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var selectedMetric = model[:selectedMetric].toNumber();

        var targetViewTitleText = model[:targetViewTitleText].toString();
        var targetCurrentText = model[:targetCurrentText].toString();
        var targetLabelText = model[:targetLabelText].toString();
        var targetDeltaAbsText = model[:targetDeltaAbsText].toString();
        var targetDisclaimerText = model[:targetDisclaimerText].toString();
        var targetUnavailableText = model[:targetUnavailableText].toString();
        var hintUnavailableText = model[:hintUnavailableText].toString();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var metric = domain.metricAt(selectedMetric) as Dictionary;
        var available = metric[:available];
        var policy = domain.classificationPolicy(metric);
        var zone = available ? domain.classify(metric) : ZONE_GREEN;

        var topSafe = pct(h, 10);
        var bottomSafe = h - pct(h, 10);
        var contentW = pct(w, 80);
        var gap = 2;
        var sectionGap = 5;

        var effectiveTarget = domain.getEffectiveTargetForIndex(selectedMetric);
        var deltaAbs = domain.getDeltaToTargetForIndex(selectedMetric);
        var deltaPct = domain.getDeltaPctToTargetForIndex(selectedMetric);
        var showData = available && !policy.equals(POLICY_REFERENCE_ONLY) &&
            effectiveTarget != null && deltaAbs != null && deltaPct != null;

        var currentText = targetCurrentText + ": " + _fmt1(metric[:value].toFloat()) + " " + metric[:unit].toString();
        var targetText = showData
            ? targetLabelText + ": " + _fmt1(effectiveTarget.toFloat()) + " " + metric[:unit].toString()
            : hintUnavailableText;
        var deltaText = showData
            ? targetDeltaAbsText + ": " + _formatDeltaValue(deltaAbs.toFloat(), metric[:unit].toString())
            : hintUnavailableText;

        var titleFont = Graphics.FONT_TINY;
        var metricText = domain.metricLabel(selectedMetric);
        if (dc.getTextWidthInPixels(metricText, Graphics.FONT_TINY) > contentW ||
            dc.getTextWidthInPixels(targetViewTitleText, Graphics.FONT_TINY) > contentW) {
            titleFont = Graphics.FONT_XTINY;
        }

        var titleFit = _fitSingleLineText(dc, targetViewTitleText, titleFont, titleFont, contentW);
        var metricFit = _fitSingleLineText(dc, metricText, titleFont, titleFont, contentW);
        var currentFit = _fitSingleLineText(dc, currentText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, contentW);
        var targetFit = _fitSingleLineText(dc, targetText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, contentW);
        var deltaFit = _fitSingleLineText(dc, deltaText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, contentW);
        var disclaimerFit = _fitSingleLineText(dc,
            showData ? targetDisclaimerText : targetUnavailableText,
            Graphics.FONT_XTINY, Graphics.FONT_XTINY, contentW);

        var titleLineH = dc.getFontHeight(titleFont);
        var lineH = dc.getFontHeight(Graphics.FONT_XTINY);
        var graphH = pct(h, 12);
        if (graphH < 20) { graphH = 20; }

        var totalH = titleLineH + gap + titleLineH + sectionGap + lineH;
        if (showData) {
            totalH += lineH + gap + lineH + sectionGap + graphH + gap;
        } else {
            totalH += graphH + sectionGap;
        }
        var y = (h - totalH) / 2;
        if (y < topSafe) { y = topSafe; }

        _drawSingleLineCentered(dc, cx, y, titleFit, COLOR_ACCENT);
        y += titleLineH + gap;

        _drawSingleLineCentered(dc, cx, y, metricFit, available ? domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY);
        y += titleLineH + sectionGap;

        if (showData) {
            _drawSingleLineCentered(dc, cx, y, currentFit, Graphics.COLOR_LT_GRAY);
            y += lineH + gap;

            _drawSingleLineCentered(dc, cx, y, targetFit, COLOR_ACCENT);
            y += lineH + gap;

            var deltaColor = _deltaColorByPct(deltaPct.toFloat());
            _drawSingleLineCentered(dc, cx, y, deltaFit, deltaColor);
            y += lineH + sectionGap;

            _drawTargetDeltaGraph(dc, cx, y, contentW, graphH, deltaPct.toFloat(), true);
            y += graphH + gap;
        } else {
            y += graphH + sectionGap;
        }

        if (y > bottomSafe - lineH) {
            y = bottomSafe - lineH;
        }
        _drawSingleLineCentered(dc, cx, y, disclaimerFit, Graphics.COLOR_DK_GRAY);

        _drawPageDots(dc, cx, bottomSafe + 1, w, domain.metricsCount(), selectedMetric, -1);
    }

    function _drawTargetDeltaGraph(dc as Dc, cx as Number, y as Number, width as Number, height as Number,
        deltaPct as Float, hasData as Boolean) as Void {
        var barX = cx - width / 2;
        var barY = y + height / 2 - 3;
        var barH = 6;
        var centerX = cx;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, width, barH);

        dc.setColor(COLOR_ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(centerX, barY - 6, centerX, barY + barH + 6);

        if (!hasData) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, barY + barH / 2, 4);
            return;
        }

        var ratio = deltaPct / 30.0;
        if (ratio > 1.0) { ratio = 1.0; }
        if (ratio < -1.0) { ratio = -1.0; }

        var currentX = centerX + (ratio * (width / 2 - 6));
        var startX = centerX;
        var fillX = startX < currentX ? startX : currentX;
        var fillW = startX < currentX ? (currentX - startX) : (startX - currentX);
        if (fillW < 2) { fillW = 2; }

        var color = _deltaColorByPct(deltaPct);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(fillX, barY, fillW, barH);

        dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, barY + barH / 2, 4);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(currentX, barY + barH / 2, 5);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(currentX, barY + barH / 2, 2);
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

    function _formatDeltaValue(value as Float, unit as String) as String {
        var sign = value >= 0.0 ? "+" : "";
        return sign + _fmt1(value) + " " + unit;
    }

    function _fitSingleLineText(dc as Dc, value as String, primaryFont, fallbackFont, maxWidth as Number) as Dictionary {
        var font = primaryFont;
        if (dc.getTextWidthInPixels(value, font) > maxWidth) {
            font = fallbackFont;
        }
        return {:font => font, :text => value};
    }

    function _drawSingleLineCentered(dc as Dc, cx as Number, y as Number, layout as Dictionary, color as Number) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, layout[:font], layout[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function _deltaColorByPct(deltaPct as Float) {
        var absDelta = deltaPct;
        if (absDelta < 0.0) {
            absDelta = -absDelta;
        }
        if (absDelta < 5.0) {
            return Graphics.COLOR_GREEN;
        }
        if (absDelta < 10.0) {
            return Graphics.COLOR_YELLOW;
        }
        if (absDelta < 20.0) {
            return Graphics.COLOR_ORANGE;
        }
        return Graphics.COLOR_RED;
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