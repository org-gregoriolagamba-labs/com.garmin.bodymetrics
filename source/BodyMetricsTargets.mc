import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Math;

const TARGET_KEY_PREFIX = "bodyMetrics.target.";

//! Gestisce i target utente per metrica e calcolo delta vs target.
class BodyMetricsTargets {

    function initialize() {
    }

    function keyFor(metricId as String) as String {
        return TARGET_KEY_PREFIX + metricId;
    }

    function getUserTarget(metricId as String) {
        return Storage.getValue(keyFor(metricId));
    }

    function setUserTarget(metricId as String, value as Float) as Void {
        Storage.setValue(keyFor(metricId), value);
    }

    function clearUserTarget(metricId as String) as Void {
        Storage.deleteValue(keyFor(metricId));
    }

    function defaultTarget(metric as Dictionary) {
        var policy = metric.hasKey(:policy) ? metric[:policy].toString() : POLICY_TARGET_RANGE;

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return null;
        }

        if (policy.equals(POLICY_LOW_ONLY)) {
            if (metric.hasKey(:greenMin) && metric[:greenMin] != null) {
                return round1(metric[:greenMin].toFloat());
            }
            return null;
        }

        if (metric.hasKey(:greenMin) && metric[:greenMin] != null &&
            metric.hasKey(:greenMax) && metric[:greenMax] != null) {
            var minValue = metric[:greenMin].toFloat();
            var maxValue = metric[:greenMax].toFloat();
            return round1((minValue + maxValue) / 2.0);
        }

        return null;
    }

    function getEffectiveTarget(metricId as String, metric as Dictionary) {
        var userTarget = getUserTarget(metricId);
        if (userTarget != null) {
            return round1(userTarget.toFloat());
        }
        return defaultTarget(metric);
    }

    function deltaToTarget(current as Float, target as Float) as Float {
        return current - target;
    }

    function deltaPctToTarget(current as Float, target as Float) {
        if (target == 0.0) {
            return null;
        }
        var delta = deltaToTarget(current, target);
        return round1((delta / target) * 100.0);
    }

    function round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }
}
