import Toybox.Lang;

//! Orchestrates target editor workflow and target lookup helpers.
class BodyMetricsTargetsUseCase {

    var _locale;
    var _targets;

    function initialize(locale, targets) {
        _locale = locale;
        _targets = targets;
    }

    function targetFieldDefinitions() as Array {
        return [
            {:key => :bmi, :metricId => "bmi", :label => _locale.metricLabel("bmi"), :unit => "kg/m2", :min => 15.0, :max => 35.0, :step => 0.1},
            {:key => :fat_pct, :metricId => "fat_pct", :label => _locale.metricLabel("fat_pct"), :unit => "%", :min => 5.0, :max => 45.0, :step => 0.1},
            {:key => :muscle_kg, :metricId => "muscle_kg", :label => _locale.metricLabel("muscle_kg"), :unit => "kg", :min => 15.0, :max => 70.0, :step => 0.1},
            {:key => :water_pct, :metricId => "water_pct", :label => _locale.metricLabel("water_pct"), :unit => "%", :min => 40.0, :max => 75.0, :step => 0.1},
            {:key => :bone_kg, :metricId => "bone_kg", :label => _locale.metricLabel("bone_kg"), :unit => "kg", :min => 1.0, :max => 6.0, :step => 0.1},
            {:key => :weight, :metricId => "weight", :label => _locale.metricLabel("weight"), :unit => "kg", :min => 40.0, :max => 200.0, :step => 0.1}
        ];
    }

    function targetFieldCount() as Number {
        return targetFieldDefinitions().size();
    }

    function targetFieldDefinition(index as Number) as Dictionary {
        return targetFieldDefinitions()[index] as Dictionary;
    }

    function currentTargets(metrics as Array) as Dictionary {
        var draft = {};
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            var metricId = field[:metricId].toString();
            var metric = _metricById(metrics, metricId);
            if (metric != null) {
                draft[field[:key]] = _targets.getEffectiveTarget(metricId, metric as Dictionary);
            }
        }
        return draft;
    }

    function cycleTargetField(draft as Dictionary, index as Number, delta as Number) as Dictionary {
        var field = targetFieldDefinition(index);
        var key = field[:key];
        var minVal = field[:min].toFloat();
        var rawCurrent = draft[key] != null ? draft[key].toFloat() : 0.0;
        var current = rawCurrent >= minVal ? rawCurrent : minVal;
        var maxVal = field[:max].toFloat();
        var step = field[:step].toFloat();
        var next = current + (delta * step);
        if (next < minVal) {
            next = maxVal;
        } else if (next > maxVal) {
            next = minVal;
        }
        draft[key] = _round1(next);
        return draft;
    }

    function targetFieldValueLabel(draft as Dictionary, index as Number) as String {
        var field = targetFieldDefinition(index);
        var key = field[:key];
        if (draft[key] == null) {
            return _locale.text("hint.unavailable");
        }
        return _fmt1(draft[key].toFloat()) + " " + field[:unit].toString();
    }

    function saveTargets(draft as Dictionary) as Void {
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            var key = field[:key];
            var metricId = field[:metricId].toString();
            if (draft[key] != null) {
                _targets.setUserTarget(metricId, draft[key].toFloat());
            }
        }
    }

    function resetAllTargets() as Void {
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            _targets.clearUserTarget(field[:metricId].toString());
        }
    }

    function clearTargetField(fieldIndex as Number) as Void {
        var field = targetFieldDefinition(fieldIndex);
        _targets.clearUserTarget(field[:metricId].toString());
    }

    function effectiveTargetForMetric(metric as Dictionary) {
        if (metric == null || !metric.hasKey(:id)) {
            return null;
        }
        return _targets.getEffectiveTarget(metric[:id].toString(), metric);
    }

    function getEffectiveTargetForMetric(metric as Dictionary) {
        if (!metric[:available]) {
            return null;
        }
        return effectiveTargetForMetric(metric);
    }

    function getDeltaToTargetForMetric(metric as Dictionary, policy as String) {
        if (!metric[:available]) {
            return null;
        }
        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return null;
        }

        var target = effectiveTargetForMetric(metric);
        if (target == null) {
            return null;
        }
        return _targets.deltaToTarget(metric[:value].toFloat(), target.toFloat());
    }

    hidden function _round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }

    hidden function _fmt1(v as Float) as String {
        var scaled = Math.round(_round1(v) * 10.0).toNumber();
        var whole = scaled / 10;
        var frac = scaled - whole * 10;
        if (frac < 0) { frac = -frac; }
        return whole.toString() + "." + frac.toString();
    }

    hidden function _metricById(metrics as Array, metricId as String) {
        for (var i = 0; i < metrics.size(); i += 1) {
            var metric = metrics[i] as Dictionary;
            if (metric[:id].toString().equals(metricId)) {
                return metric;
            }
        }
        return null;
    }
}