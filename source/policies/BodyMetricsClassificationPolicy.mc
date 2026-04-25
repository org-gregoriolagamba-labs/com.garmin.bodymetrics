import Toybox.Lang;

//! Pure-ish classification and semantic policy for metric zones.
//! The only external dependency is locale text lookup for user-facing strings.
class BodyMetricsClassificationPolicy {

    var _locale;

    function initialize(locale) {
        _locale = locale;
    }

    function classify(metric as Dictionary) {
        if (metric.hasKey(:available) && !metric[:available]) {
            return ZONE_GREEN;
        }

        var value = metric[:value];
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return classifyLowOnly(metric, value);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return classifyReferenceOnly(metric, value);
        }

        return classifyTargetRange(metric, value);
    }

    function classificationPolicy(metric as Dictionary) {
        if (metric.hasKey(:policy)) {
            return metric[:policy];
        }

        return POLICY_TARGET_RANGE;
    }

    function classifyTargetRange(metric as Dictionary, value) {
        var yellowLowMin = _thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = _thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = _thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = _thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = _thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = _thresholdOr(metric, :orangeLowMax, :yellowMin);
        var orangeHighMin = _thresholdOr(metric, :orangeHighMin, :yellowMax);
        var orangeHighMax = _thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (_inRange(value, metric[:greenMin], metric[:greenMax])) {
            return ZONE_GREEN;
        }

        if (_inRange(value, yellowLowMin, yellowLowMax) || _inRange(value, yellowHighMin, yellowHighMax)) {
            return ZONE_YELLOW;
        }

        if (_inRange(value, orangeLowMin, orangeLowMax) || _inRange(value, orangeHighMin, orangeHighMax)) {
            return ZONE_ORANGE;
        }

        return ZONE_RED;
    }

    function classifyLowOnly(metric as Dictionary, value) {
        if (value >= metric[:greenMin]) {
            return ZONE_GREEN;
        }

        if (value >= metric[:yellowMin]) {
            return ZONE_YELLOW;
        }

        if (value >= metric[:orangeMin]) {
            return ZONE_ORANGE;
        }

        return ZONE_RED;
    }

    function classifyReferenceOnly(metric as Dictionary, value) {
        var deltaPct = referenceDeltaPct(metric, value);
        if (deltaPct <= metric[:toleranceGoodPct].toFloat()) {
            return ZONE_GREEN;
        }
        if (deltaPct <= metric[:toleranceMildPct].toFloat()) {
            return ZONE_YELLOW;
        }
        return ZONE_ORANGE;
    }

    function referenceDeltaPct(metric as Dictionary, value) as Float {
        var reference = metric[:referenceValue].toFloat();
        if (reference == 0.0) {
            return 0.0;
        }

        var delta = (value.toFloat() - reference) / reference;
        if (delta < 0.0) {
            delta = -delta;
        }
        return delta * 100.0;
    }

    function zoneRangeText(metric as Dictionary) as String {
        var value = metric[:value];
        var zone = classify(metric);
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return zoneRangeTextLowOnly(metric, zone);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return zoneRangeTextReferenceOnly(metric);
        }

        return zoneRangeTextTarget(metric, zone, value);
    }

    function idealRangeText(metric as Dictionary) as String {
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return _fmtThreshold(metric[:greenMin]) + "-" + _fmtThreshold(metric[:greenMax]);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return zoneRangeTextReferenceOnly(metric);
        }

        var greenMin = _thresholdOr(metric, :greenMin, :yellowLowMax);
        var greenMax = _thresholdOr(metric, :greenMax, :yellowHighMin);
        return _fmtThreshold(greenMin) + "-" + _fmtThreshold(greenMax);
    }

    function zoneRangeTextTarget(metric as Dictionary, zone as Number, value) as String {
        var greenMin = _thresholdOr(metric, :greenMin, :yellowLowMax);
        var greenMax = _thresholdOr(metric, :greenMax, :yellowHighMin);
        var yellowLowMin = _thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = _thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = _thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = _thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = _thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = _thresholdOr(metric, :orangeLowMax, :yellowLowMin);
        var orangeHighMin = _thresholdOr(metric, :orangeHighMin, :yellowHighMax);
        var orangeHighMax = _thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (zone == ZONE_GREEN) {
            return _fmtThreshold(greenMin) + "-" + _fmtThreshold(greenMax);
        }

        if (zone == ZONE_YELLOW) {
            if (value < greenMin) {
                return _fmtThreshold(yellowLowMin) + "-" + _fmtThreshold(yellowLowMax);
            }
            return _fmtThreshold(yellowHighMin) + "-" + _fmtThreshold(yellowHighMax);
        }

        if (zone == ZONE_ORANGE) {
            if (value < greenMin) {
                return _fmtThreshold(orangeLowMin) + "-" + _fmtThreshold(orangeLowMax);
            }
            return _fmtThreshold(orangeHighMin) + "-" + _fmtThreshold(orangeHighMax);
        }

        if (orangeLowMin != null && value < orangeLowMin) {
            return "< " + _fmtThreshold(orangeLowMin);
        }
        return "> " + _fmtThreshold(orangeHighMax);
    }

    function zoneRangeTextLowOnly(metric as Dictionary, zone as Number) as String {
        if (zone == ZONE_GREEN) {
            return _fmtThreshold(metric[:greenMin]) + "-" + _fmtThreshold(metric[:greenMax]);
        }

        if (zone == ZONE_YELLOW) {
            return _fmtThreshold(metric[:yellowMin]) + "-" + _fmtThreshold(metric[:greenMin]);
        }

        if (zone == ZONE_ORANGE) {
            return _fmtThreshold(metric[:orangeMin]) + "-" + _fmtThreshold(metric[:yellowMin]);
        }

        return "< " + _fmtThreshold(metric[:orangeMin]);
    }

    function zoneRangeTextReferenceOnly(metric as Dictionary) as String {
        return _locale.text("reference.prefix") + " " + _fmtThreshold(metric[:referenceValue]) + " (+/-" + _fmtThreshold(metric[:toleranceGoodPct]) + "%)";
    }

    function semanticZoneHint(metric as Dictionary) as String {
        var zone = classify(metric);
        var policy = classificationPolicy(metric);
        var value = metric[:value];

        if (policy.equals(POLICY_LOW_ONLY)) {
            if (zone == ZONE_GREEN) {
                return _locale.text("hint.low_only.green");
            }
            if (zone == ZONE_YELLOW) {
                return _locale.text("hint.low_only.yellow");
            }
            if (zone == ZONE_ORANGE) {
                return _locale.text("hint.low_only.orange");
            }
            return _locale.text("hint.low_only.red");
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return _locale.text("hint.reference.green");
            }
            if (value.toFloat() < metric[:referenceValue].toFloat()) {
                return _locale.text("hint.reference.below");
            }
            return _locale.text("hint.reference.above");
        }

        if (zone == ZONE_GREEN) {
            return _locale.text("hint.target.green");
        }
        if (zone == ZONE_YELLOW) {
            if (value < metric[:greenMin]) {
                return _locale.text("hint.target.yellow_low");
            }
            return _locale.text("hint.target.yellow_high");
        }
        if (zone == ZONE_ORANGE) {
            return _locale.text("hint.target.orange");
        }
        if (value < metric[:greenMin]) {
            return _locale.text("hint.target.red_low");
        }
        return _locale.text("hint.target.red_high");
    }

    hidden function _thresholdOr(metric as Dictionary, key, fallbackKey) {
        if (metric.hasKey(key)) {
            return metric[key];
        }

        if (metric.hasKey(fallbackKey)) {
            return metric[fallbackKey];
        }

        return null;
    }

    hidden function _inRange(value, minValue, maxValue) {
        if (minValue == null || maxValue == null) {
            return false;
        }
        return value >= minValue && value <= maxValue;
    }

    hidden function _fmtThreshold(value) as String {
        if (value == null) {
            return "--";
        }
        return _fmt1(value.toFloat());
    }

    hidden function _fmt1(v as Float) as String {
        var scaled = Math.round(_round1(v) * 10.0).toNumber();
        var whole = scaled / 10;
        var frac = scaled - whole * 10;
        if (frac < 0) { frac = -frac; }
        return whole.toString() + "." + frac.toString();
    }

    hidden function _round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }
}