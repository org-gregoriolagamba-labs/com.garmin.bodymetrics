import Toybox.Graphics;
import Toybox.Lang;

//! Dedicated renderer for setup/data/target wizard screens.
class BodyMetricsWizardRenderer {

    function initialize() {
    }

    function drawSetup(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var setupIndex = model[:setupIndex].toNumber();
        var profileDraft = model[:profileDraft] as Dictionary;

        var field = domain.profileFieldDefinition(setupIndex) as Dictionary;
        drawWizardScreen(dc, setupIndex, domain.profileFieldCount(), field,
            domain.profileFieldValueLabel(profileDraft, setupIndex),
            model[:titleText].toString(), model[:saveHint].toString(), model[:nextHint].toString());
    }

    function drawDataEntry(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var dataIndex = model[:dataIndex].toNumber();
        var dataDraft = model[:dataDraft] as Dictionary;

        var field = domain.measurementFieldDefinition(dataIndex) as Dictionary;
        drawWizardScreen(dc, dataIndex, domain.measurementFieldCount(), field,
            domain.measurementFieldValueLabel(dataDraft, dataIndex),
            model[:titleText].toString(), model[:saveHint].toString(), model[:nextHint].toString());
    }

    function drawTargetEditor(dc as Dc, model as Dictionary) as Void {
        var domain = model[:domain];
        var targetIndex = model[:targetIndex].toNumber();
        var targetDraft = model[:targetDraft] as Dictionary;

        var field = domain.targetFieldDefinition(targetIndex) as Dictionary;
        drawWizardScreen(dc, targetIndex, domain.targetFieldCount(), field,
            domain.targetFieldValueLabel(targetDraft, targetIndex),
            model[:titleText].toString(), model[:saveHint].toString(), model[:nextHint].toString());
    }

    //! Shared wizard screen for setup/data/target modes.
    function drawWizardScreen(dc as Dc, stepIndex as Number, totalSteps as Number,
        field as Dictionary, valueText as String, titleText as String,
        saveHint as String, nextHint as String) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        var hSmall = dc.getFontHeight(Graphics.FONT_SMALL);
        var gap = pct(h, 2);

        var isReadOnly = field.hasKey(:readOnly) && field[:readOnly];

        var fieldLabelLayout = fitTextBlockGlobal(dc, field[:label].toString(), Graphics.FONT_XTINY, Graphics.FONT_XTINY, pct(w, 72));
        var titleLayout = fitTextBlockGlobal(dc, titleText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, pct(w, 72));
        var footerText = isReadOnly ? field[:readOnlyText].toString() : (stepIndex == totalSteps - 1 ? saveHint : nextHint);
        var footerLayout = fitTextBlockGlobal(dc, footerText, Graphics.FONT_XTINY, Graphics.FONT_XTINY, pct(w, 76));

        var centralH = fieldLabelLayout[:height] + gap + hSmall;
        var labelY = cy - centralH / 2;
        var valueY = labelY + fieldLabelLayout[:height] + gap;

        drawCenteredTextBlockGlobal(dc, cx, labelY, fieldLabelLayout, isReadOnly ? COLOR_ACCENT : Graphics.COLOR_LT_GRAY);

        dc.setColor(isReadOnly ? COLOR_ACCENT : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var valueFont = Graphics.FONT_SMALL;
        dc.drawText(cx, valueY, valueFont, valueText, Graphics.TEXT_JUSTIFY_CENTER);

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
                dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else if (i == stepIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, activeR);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(dotX, dotsY, inactiveR);
            }
        }

        var titleY = dotsY + activeR + gap + 2;
        drawCenteredTextBlockGlobal(dc, cx, titleY, titleLayout, COLOR_ACCENT);

        if (!isReadOnly) {
            var arrowY = valueY + dc.getFontHeight(valueFont) / 2;
            var arrowX = pct(w, 12);
            dc.setColor(COLOR_ACCENT, Graphics.COLOR_TRANSPARENT);
            _drawTriangle(dc, arrowX, arrowY, pct(w, 2), true);
            _drawTriangle(dc, w - arrowX, arrowY, pct(w, 2), false);
        }

        var footerY = h - pct(h, 16) - footerLayout[:height];
        drawCenteredTextBlockGlobal(dc, cx, footerY, footerLayout, Graphics.COLOR_LT_GRAY);
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
}