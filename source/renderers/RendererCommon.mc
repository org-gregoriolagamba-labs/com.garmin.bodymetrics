import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! Fit multiline text using fallback font when needed.
function fitTextBlockGlobal(dc as Dc, value as String, primaryFont, fallbackFont, maxWidth as Number) as Dictionary {
    var font = primaryFont;
    var lines = wrapTextGlobal(dc, value, font, maxWidth);
    if (maxTextWidthGlobal(dc, lines, font) > maxWidth || lines.size() > 2) {
        font = fallbackFont;
        lines = wrapTextGlobal(dc, value, font, maxWidth);
    }
    return {
        :font => font,
        :lines => lines,
        :lineHeight => dc.getFontHeight(font),
        :height => lines.size() * dc.getFontHeight(font),
        :width => maxTextWidthGlobal(dc, lines, font)
    };
}

//! Return max width in pixels among all input lines.
function maxTextWidthGlobal(dc as Dc, lines as Array, font) as Number {
    var maxWidth = 0;
    for (var i = 0; i < lines.size(); i += 1) {
        var lineWidth = dc.getTextWidthInPixels(lines[i].toString(), font);
        if (lineWidth > maxWidth) {
            maxWidth = lineWidth;
        }
    }
    return maxWidth;
}

//! Draw a centered multiline text block.
function drawCenteredTextBlockGlobal(dc as Dc, cx as Number, startY as Number, layout as Dictionary, color as Number) as Void {
    var lines = layout[:lines] as Array;
    var font = layout[:font];
    var lineHeight = layout[:lineHeight];
    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    for (var i = 0; i < lines.size(); i += 1) {
        dc.drawText(cx, startY + i * lineHeight, font, lines[i].toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }
}

//! Percentage of a total value.
function pct(total as Number, percent as Number) as Number {
    return total * percent / 100;
}

//! Compute the usable horizontal width at a given Y on a round screen.
//! Uses the most constrained edge (top or bottom of text) to avoid clipping.
function availableWidthAtYGlobal(screenW as Number, screenH as Number, textY as Number, textH as Number) as Number {
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

//! Word-wrap text to fit within maxWidth pixels.
function wrapTextGlobal(dc as Dc, value as String, font, maxWidth as Number) as Array {
    var words = splitWordsGlobal(value);
    var lines = [] as Array;
    var current = "";
    for (var i = 0; i < words.size(); i += 1) {
        var word = words[i].toString();
        var candidate = current.equals("") ? word : current + " " + word;
        if (!current.equals("") && dc.getTextWidthInPixels(candidate, font) > maxWidth) {
            lines.add(current);
            current = word;
        } else {
            current = candidate;
        }
    }
    if (!current.equals("")) { lines.add(current); }
    return lines;
}

//! Split a string into words by spaces.
function splitWordsGlobal(value as String) as Array {
    var words = [] as Array;
    var start = 0;
    var length = value.length();
    for (var i = 0; i < length; i += 1) {
        if (value.substring(i, i + 1).equals(" ")) {
            if (i > start) { words.add(value.substring(start, i)); }
            start = i + 1;
        }
    }
    if (start < length) { words.add(value.substring(start, length)); }
    return words;
}