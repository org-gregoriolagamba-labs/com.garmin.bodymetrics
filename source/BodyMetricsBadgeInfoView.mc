import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Scrollable information view used for system/app details.
//! Displays structured key-value items on a round screen.
class BodyMetricsBadgeInfoView extends WatchUi.View {

    var _title as String;
    var _lines as Array;      // [{:label, :value}]
    var _scrollY as Number;
    var _contentH as Number;

    function initialize(title as String, lines as Array) {
        View.initialize();
        _title = title;
        _lines = lines;
        _scrollY = 0;
        _contentH = 0;
    }

    function scrollBy(delta as Number) as Void {
        _scrollY += delta;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        var titleFont = Graphics.FONT_TINY;
        var topMargin = pct(h, 10);
        var contentTop = topMargin + dc.getFontHeight(titleFont) + pct(h, 2);
        var visibleH = h - contentTop - pct(h, 15);
        var visibleBottom = contentTop + visibleH;
        var wTop = availableWidthAtYGlobal(w, h, contentTop, lineH) - pct(w, 14);
        var wBot = availableWidthAtYGlobal(w, h, visibleBottom - lineH, lineH) - pct(w, 14);
        var safeW = wTop < wBot ? wTop : wBot;
        var itemW = safeW;

        // Decorative separators
        var sepHalfW = pct(w, 24);
        var topSepY = topMargin - pct(h, 2);
        var bottomSepY = h - pct(h, 9);
        dc.setPenWidth(2);
        dc.setColor(COLOR_ACCENT_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - sepHalfW, topSepY, cx + sepHalfW, topSepY);
        dc.drawLine(cx - sepHalfW, bottomSepY, cx + sepHalfW, bottomSepY);
        dc.setPenWidth(1);

        // Fixed title
        dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, topMargin, titleFont, _title, Graphics.TEXT_JUSTIFY_CENTER);

        // Build renderable lines from structured data
        var allLines = [] as Array;
        for (var i = 0; i < _lines.size(); i += 1) {
            var item = _lines[i] as Dictionary;
            var lbl = item[:label].toString();
            var val = item[:value].toString();
            if (lbl.equals("") && val.equals("")) {
                allLines.add({:text => "", :type => :empty});
            } else if (!lbl.equals("") && val.equals("")) {
                allLines.add({:text => lbl, :type => :centered});
            } else {
                var labelWrapped = wrapTextGlobal(dc, lbl, font, itemW);
                for (var li = 0; li < labelWrapped.size(); li += 1) {
                    allLines.add({:text => labelWrapped[li].toString(), :type => :label});
                }
                var valueWrapped = wrapTextGlobal(dc, val, Graphics.FONT_TINY, itemW);
                for (var vi = 0; vi < valueWrapped.size(); vi += 1) {
                    allLines.add({:text => valueWrapped[vi].toString(), :type => :value});
                }
                allLines.add({:text => "", :type => :empty});
            }
        }

        // Scroll clamping
        _contentH = allLines.size() * lineH;
        var maxScroll = _contentH - visibleH;
        if (maxScroll < 0) { maxScroll = 0; }
        if (_scrollY > maxScroll) { _scrollY = maxScroll; }
        if (_scrollY < 0) { _scrollY = 0; }

        // Draw with clipping
        dc.setClip(0, contentTop, w, visibleH);
        var y = contentTop - _scrollY;
        for (var i = 0; i < allLines.size(); i += 1) {
            var line = allLines[i] as Dictionary;
            var lineType = line[:type];
            if (y + lineH > contentTop - lineH && y < contentTop + visibleH + lineH) {
                if (lineType == :centered) {
                    dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                } else if (lineType == :label) {
                    dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                } else if (lineType == :value) {
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, Graphics.FONT_TINY, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                } else if (lineType == :centeredText) {
                    dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                }
            }
            y += lineH;
        }
        dc.clearClip();

        // Scroll indicator
        if (maxScroll > 0) {
            var trackH = visibleH - 8;
            var trackY = contentTop + 4;
            var thumbH = trackH * visibleH / _contentH;
            if (thumbH < 8) { thumbH = 8; }
            var thumbY = trackY + (_scrollY * (trackH - thumbH) / maxScroll);
            var trackX = w - pct(w, 5);
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(trackX, trackY, 3, trackH);
            dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(trackX, thumbY, 3, thumbH);
        }
    }
}

//! Delegate for the badge info scrollable view.
class BodyMetricsBadgeInfoDelegate extends WatchUi.BehaviorDelegate {

    var _badgeView as BodyMetricsBadgeInfoView;

    function initialize(badgeView as BodyMetricsBadgeInfoView) {
        BehaviorDelegate.initialize();
        _badgeView = badgeView;
    }

    function onNextPage() as Boolean {
        _badgeView.scrollBy(30);
        return true;
    }

    function onPreviousPage() as Boolean {
        _badgeView.scrollBy(-30);
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onSelect() as Boolean {
        return true;
    }
}
