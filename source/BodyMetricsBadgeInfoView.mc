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
    var _selectedItemIndex as Number;  // Track selected item for actions

    function initialize(title as String, lines as Array) {
        View.initialize();
        _title = title;
        _lines = lines;
        _scrollY = 0;
        _contentH = 0;
        _selectedItemIndex = _firstSelectableItemIndex();
    }

    function _firstSelectableItemIndex() as Number {
        for (var i = 0; i < _lines.size(); i += 1) {
            var item = _lines[i] as Dictionary;
            if (item[:action] != null && (item[:action] as Boolean)) {
                return i;
            }
        }
        return -1;
    }

    function selectItemWithAction() as Symbol or Null {
        if (_selectedItemIndex >= 0 && _selectedItemIndex < _lines.size()) {
            var item = _lines[_selectedItemIndex] as Dictionary;
            if (item[:action] != null && (item[:action] as Boolean) && item[:actionId] != null) {
                return item[:actionId] as Symbol;
            }
        }
        return null;
    }

    function nextSelectableItem() as Void {
        var startIdx = _selectedItemIndex >= 0 ? _selectedItemIndex + 1 : 0;
        for (var i = startIdx; i < _lines.size(); i += 1) {
            var item = _lines[i] as Dictionary;
            if (item[:action] != null && (item[:action] as Boolean)) {
                _selectedItemIndex = i;
                WatchUi.requestUpdate();
                return;
            }
        }
        _selectedItemIndex = -1;
        WatchUi.requestUpdate();
    }

    function prevSelectableItem() as Void {
        var startIdx = _selectedItemIndex >= 0 ? _selectedItemIndex - 1 : _lines.size() - 1;
        for (var i = startIdx; i >= 0; i -= 1) {
            var item = _lines[i] as Dictionary;
            if (item[:action] != null && (item[:action] as Boolean)) {
                _selectedItemIndex = i;
                WatchUi.requestUpdate();
                return;
            }
        }
        _selectedItemIndex = -1;
        WatchUi.requestUpdate();
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
            
            // Check if this is a pure button item (action, no value, no image)
            var hasAction = item[:action] != null && (item[:action] as Boolean);
            if (hasAction && item[:value] == null && item[:image] == null) {
                allLines.add({:text => lbl, :type => :button, :itemIndex => i});
                allLines.add({:text => "", :type => :empty, :itemIndex => -1});
            } else if (item[:image] != null) {
                allLines.add({:text => lbl, :type => :label, :itemIndex => i});
                allLines.add({:type => :image, :resourceId => item[:image], :itemIndex => i});
                allLines.add({:text => "", :type => :empty, :itemIndex => -1});
            } else {
                var val = item[:value].toString();
                if (lbl.equals("") && val.equals("")) {
                    allLines.add({:text => "", :type => :empty, :itemIndex => -1});
                } else if (!lbl.equals("") && val.equals("")) {
                    allLines.add({:text => lbl, :type => :centered, :itemIndex => i});
                } else {
                    var labelWrapped = wrapTextGlobal(dc, lbl, font, itemW);
                    for (var li = 0; li < labelWrapped.size(); li += 1) {
                        allLines.add({:text => labelWrapped[li].toString(), :type => :label, :itemIndex => i});
                    }
                    var valueWrapped = wrapTextGlobal(dc, val, font, itemW);
                    for (var vi = 0; vi < valueWrapped.size(); vi += 1) {
                        allLines.add({:text => valueWrapped[vi].toString(), :type => :value, :itemIndex => i});
                    }
                    allLines.add({:text => "", :type => :empty, :itemIndex => -1});
                }
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
        var lastWasImage = false;
        for (var i = 0; i < allLines.size(); i += 1) {
            var line = allLines[i] as Dictionary;
            var lineType = line[:type];
            if (y + lineH > contentTop - lineH && y < contentTop + visibleH + lineH) {
                if (lineType == :image) {
                    // Draw image centered
                    var resourceId = line[:resourceId] as ResourceId;
                    try {
                        var img = WatchUi.loadResource(resourceId) as BitmapResource;
                        var imgW = img.getWidth();
                        var imgH = img.getHeight();
                        var imgX = (w - imgW) / 2;
                        dc.drawBitmap(imgX, y, img);
                        y += imgH + 8;  // Add spacing after image
                        lastWasImage = true;
                    } catch (ex) {
                        System.println("[BodyMetrics] Failed to load image resource");
                        lastWasImage = false;
                    }
                } else if (lineType == :centered) {
                    dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                    lastWasImage = false;
                } else if (lineType == :label) {
                    dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                    lastWasImage = false;
                } else if (lineType == :button) {
                    var btnIdx = line[:itemIndex] as Number;
                    var btnText = line[:text].toString();
                    var btnSelected = btnIdx == _selectedItemIndex;
                    var btnW = dc.getTextWidthInPixels("[ " + btnText + " ]", font) + pct(w, 6);
                    var btnH = lineH + 4;
                    var btnX = cx - btnW / 2;
                    var btnY = y - 2;
                    if (btnSelected) {
                        dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                        dc.fillRoundedRectangle(btnX, btnY, btnW, btnH, 4);
                        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                    } else {
                        dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
                        dc.drawRoundedRectangle(btnX, btnY, btnW, btnH, 4);
                        dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
                    }
                    dc.drawText(cx, y, font, btnText, Graphics.TEXT_JUSTIFY_CENTER);
                    lastWasImage = false;
                } else if (lineType == :value) {
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                    lastWasImage = false;
                } else if (lineType == :centeredText) {
                    dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(cx, y, font, line[:text].toString(), Graphics.TEXT_JUSTIFY_CENTER);
                    lastWasImage = false;
                } else if (lineType == :empty) {
                    lastWasImage = false;
                }
            }
            if (!lastWasImage) {
                y += lineH;
            }
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
    var _parentView as BodyMetricsView or Null;

    function initialize(badgeView as BodyMetricsBadgeInfoView, parentView as BodyMetricsView or Null) {
        BehaviorDelegate.initialize();
        _badgeView = badgeView;
        _parentView = parentView;
    }

    function onNextPage() as Boolean {
        _badgeView.scrollBy(30);
        return true;
    }

    function onPreviousPage() as Boolean {
        _badgeView.scrollBy(-30);
        return true;
    }

    function onUp() as Boolean {
        _badgeView.prevSelectableItem();
        return true;
    }

    function onDown() as Boolean {
        _badgeView.nextSelectableItem();
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onSelect() as Boolean {
        var action = _badgeView.selectItemWithAction();
        if (action == :open_qrcode && _parentView != null) {
            (_parentView as BodyMetricsView).openQrcodeView();
            return true;
        }
        return false;
    }
}

