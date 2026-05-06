import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! Dedicated renderer for trend screen drawing.
//! The view remains the state coordinator and provides a render model.
class BodyMetricsTrendRenderer {

    const TREND_UP = 1;
    const TREND_DOWN = -1;
    const TREND_FLAT = 0;
    const COLOR_ACCENT = 0x66CCFF;

    function initialize() {
    }

    function draw(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var selectedMetric = model[:selectedMetric].toNumber();
        var trendWindow = model[:trendWindow].toNumber();
        var trendValues = model[:trendValues] as Array;
        var trendSampleCount = model[:trendSampleCount].toNumber();
        var trendDirection = model[:trendDirection].toNumber();
        var availableWindows = model[:availableWindows] as Array;

        var trendNoDataText = model[:trendNoDataText].toString();
        var trendSingleEntryText = model[:trendSingleEntryText].toString();
        var trendUpText = model[:trendUpText].toString();
        var trendDownText = model[:trendDownText].toString();
        var trendFlatText = model[:trendFlatText].toString();
        var trendLastPrefix = model[:trendLastPrefix].toString();
        var trendLastSuffix = model[:trendLastSuffix].toString();
        var trendLastSuffixShort = model[:trendLastSuffixShort].toString();
        var currentValueText = model[:currentValueText].toString();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var metric = domain.metricAt(selectedMetric) as Dictionary;
        var available = metric[:available];
        var zone = available ? domain.classify(metric) : 0;

        var hXtiny = dc.getFontHeight(Graphics.FONT_XTINY);
        var pad = _pct(h, 2);
        if (pad < 3) { pad = 3; }

        // Combined title in metric color.
        var topY = _pct(h, 10);
        var labelText = domain.metricLabel(selectedMetric);
        var labelFont = Graphics.FONT_TINY;
        var labelSafeW = _availableWidthAtY(w, h, topY, dc.getFontHeight(labelFont)) - _pct(w, 10);
        if (dc.getTextWidthInPixels(labelText, labelFont) > labelSafeW) {
            labelFont = Graphics.FONT_XTINY;
        }
        var labelH = dc.getFontHeight(labelFont);
        dc.setColor(available ? domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, topY, labelFont, labelText, Graphics.TEXT_JUSTIFY_CENTER);

        // Current value + unit.
        var valueY = topY + labelH + 2;
        var valueFont = Graphics.FONT_SMALL;
        var valueSafeW = _availableWidthAtY(w, h, valueY, dc.getFontHeight(valueFont)) - _pct(w, 10);
        if (dc.getTextWidthInPixels(currentValueText, valueFont) > valueSafeW) {
            valueFont = Graphics.FONT_TINY;
        }
        var valueH = dc.getFontHeight(valueFont);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, valueY, valueFont, currentValueText, Graphics.TEXT_JUSTIFY_CENTER);

        if (trendWindow == 0 || trendValues.size() < 2) {
            var emptyStateText = trendSampleCount == 1 ? trendSingleEntryText : trendNoDataText;
            var noDataLayout = fitTextBlockGlobal(dc, emptyStateText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, _pct(w, 72));
            drawCenteredTextBlockGlobal(dc, cx, (h / 2) - (noDataLayout[:height] / 2), noDataLayout, Graphics.COLOR_DK_GRAY);
        } else {
            var compactLayout = (trendWindow >= 90 || w < 240);
            var bounds = _trendValueBounds(trendValues);
            var axisLabels = _trendAxisLabels(bounds, compactLayout);
            var axisLabelW = _maxTextWidth(dc, axisLabels, Graphics.FONT_XTINY);

            // Compute bottom positions first for round-screen-aware label width.
            var windowY = h - _pct(h, 10);
            var trendY = windowY - hXtiny - pad;
            var windowLabelMaxW = _availableWidthAtY(w, h, windowY, hXtiny) * 0.66;
            var hardCap = _pct(w, 72);
            if (windowLabelMaxW > hardCap) {
                windowLabelMaxW = hardCap;
            }
            var windowLabel = _trendWindowLabel(dc, Graphics.FONT_XTINY, windowLabelMaxW,
                trendWindow, trendLastPrefix, trendLastSuffix, trendLastSuffixShort);

            // Mini chart.
            var chartX = _pct(w, 11) + axisLabelW;
            var chartRightPad = _pct(w, 8);
            var chartY = valueY + valueH + pad + 2;
            var chartH = trendY - chartY - pad;
            var minChartH = _pct(h, 22);
            if (minChartH < 34) { minChartH = 34; }
            if (chartH < minChartH) {
                chartH = minChartH;
                chartY = trendY - pad - chartH;
            }
            var chartW = w - chartX - chartRightPad;
            var lineColor = available ? domain.zoneColor(metric, zone) : Graphics.COLOR_DK_GRAY;
            _drawMiniChart(dc, chartX, chartY, chartW, chartH, trendValues, lineColor,
                bounds, axisLabels, compactLayout);

            // Trend label + arrow.
            var trendLabel = trendFlatText;
            if (trendDirection == TREND_UP) {
                trendLabel = trendUpText;
            } else if (trendDirection == TREND_DOWN) {
                trendLabel = trendDownText;
            }

            var arrowSize = _pct(w, 2);
            if (arrowSize < 5) { arrowSize = 5; }
            var labelW = dc.getTextWidthInPixels(trendLabel, Graphics.FONT_XTINY);
            var arrowX = cx - labelW / 2 - arrowSize - 4;
            var arrowY = trendY + hXtiny / 2;

            var arrowColor = _trendArrowColor(selectedMetric, trendDirection);
            if (trendDirection == TREND_UP) {
                dc.setColor(arrowColor, Graphics.COLOR_TRANSPARENT);
                _drawTriangle(dc, arrowX, arrowY, arrowSize, true);
            } else if (trendDirection == TREND_DOWN) {
                dc.setColor(arrowColor, Graphics.COLOR_TRANSPARENT);
                _drawTriangle(dc, arrowX, arrowY, arrowSize, false);
            } else {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(arrowX - arrowSize / 2, arrowY - 1, arrowSize, 3);
            }

            var trendFont = Graphics.FONT_XTINY;
            var trendTextMaxW = _availableWidthAtY(w, h, trendY, dc.getFontHeight(trendFont)) * 0.66;
            var trendHardCap = _pct(w, 72);
            if (trendTextMaxW > trendHardCap) {
                trendTextMaxW = trendHardCap;
            }
            var trendLayout = _fitSingleLineText(dc, trendLabel, trendFont, trendFont, trendTextMaxW);

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, trendY, trendLayout[:font], trendLayout[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, windowY, Graphics.FONT_XTINY, windowLabel, Graphics.TEXT_JUSTIFY_CENTER);
        }

        _drawVerticalScrollDots(dc, _pct(w, 8), h / 2, h, availableWindows, trendWindow);
    }

    function _drawMiniChart(dc as Dc, x as Number, y as Number, w as Number, h as Number,
        values as Array, lineColor, bounds as Dictionary, axisLabels as Array, compactLayout as Boolean) as Void {
        if (values.size() < 2) { return; }

        var minV = bounds[:minV].toFloat();
        var range = bounds[:range].toFloat();

        var tsMin = (values[0] as Dictionary)[:ts].toNumber();
        var tsMax = (values[values.size() - 1] as Dictionary)[:ts].toNumber();
        var tsRange = tsMax - tsMin;
        if (tsRange < 1) { tsRange = 1; }

        var plotPadX = compactLayout ? 2 : 3;
        var plotPadY = compactLayout ? 4 : 3;
        var plotX = x + plotPadX;
        var plotY = y + plotPadY;
        var plotW = w - plotPadX * 2;
        var plotH = h - plotPadY * 2;
        if (plotW < 10 || plotH < 10) { return; }

        var pts = new [values.size()];
        for (var i = 0; i < values.size(); i++) {
            var entry = values[i] as Dictionary;
            var px = plotX + ((entry[:ts].toNumber() - tsMin) * plotW / tsRange);
            var fpy = (entry[:val].toFloat() - minV) * plotH.toFloat() / range;
            var py = plotY + plotH - fpy.toNumber();
            pts[i] = [px, py];
        }

        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(plotX, plotY, plotX + plotW, plotY);
        dc.drawLine(plotX, plotY + plotH / 2, plotX + plotW, plotY + plotH / 2);

        var axisFont = Graphics.FONT_XTINY;
        var axisX = x - 4;
        var axisColor = 0x777777;
        var axisH = dc.getFontHeight(axisFont);
        dc.setColor(axisColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(axisX, plotY - axisH / 2, axisFont, axisLabels[0] as String, Graphics.TEXT_JUSTIFY_RIGHT);
        if (axisLabels[1] != null) {
            dc.drawText(axisX, plotY + plotH / 2 - axisH / 2, axisFont,
                axisLabels[1] as String, Graphics.TEXT_JUSTIFY_RIGHT);
        }
        dc.drawText(axisX, plotY + plotH - axisH / 2, axisFont, axisLabels[2] as String, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setPenWidth(compactLayout ? 1 : 2);
        dc.setColor(lineColor, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < pts.size() - 1; i++) {
            var p1 = pts[i] as Array;
            var p2 = pts[i + 1] as Array;
            dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
        }
        dc.setPenWidth(1);

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

    function _drawVerticalScrollDots(dc as Dc, x as Number, cy as Number, screenH as Number,
        windows as Array, trendWindow as Number) as Void {
        var count = windows.size();
        if (count == 0) { return; }

        var spacing = _pct(screenH, 4);
        if (spacing < 8) { spacing = 8; }
        var activeR = 4;
        var inactiveR = 2;
        var startY = cy - ((count - 1) * spacing) / 2;

        var currentIndex = 0;
        for (var i = 0; i < windows.size(); i += 1) {
            if ((windows[i] as Number) == trendWindow) {
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

    function _trendArrowColor(metricIndex as Number, direction as Number) as Number {
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

    function _trendWindowLabel(dc as Dc, font, maxWidth as Number, trendWindow as Number,
        lastPrefix as String, lastSuffix as String, lastSuffixShort as String) as String {
        var fullLabel = lastPrefix + " " + trendWindow.toString() + " " + lastSuffix;
        if (dc.getTextWidthInPixels(fullLabel, font) <= maxWidth) {
            return fullLabel;
        }

        var compactLabel = trendWindow.toString() + " " + lastSuffixShort;
        if (dc.getTextWidthInPixels(compactLabel, font) <= maxWidth) {
            return compactLabel;
        }
        return trendWindow.toString();
    }

    function _formatAxisValue(value as Float, range as Float, compactLayout as Boolean) as String {
        return _fmt1(value);
    }

    function _fitSingleLineText(dc as Dc, value as String, primaryFont, fallbackFont, maxWidth as Number) as Dictionary {
        var font = primaryFont;
        if (dc.getTextWidthInPixels(value, font) > maxWidth) {
            font = fallbackFont;
        }
        return {:font => font, :text => value};
    }

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

    function _drawTriangle(dc as Dc, cx as Number, cy as Number, size as Number, pointUp as Boolean) as Void {
        if (size < 4) { size = 4; }
        var half = size / 2;
        if (pointUp) {
            dc.fillPolygon([[cx, cy - half], [cx - half, cy + half], [cx + half, cy + half]]);
        } else {
            dc.fillPolygon([[cx, cy + half], [cx - half, cy - half], [cx + half, cy - half]]);
        }
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

    function _pct(total as Number, percent as Number) as Number {
        return total * percent / 100;
    }
}
