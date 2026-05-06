import Toybox.Lang;

//! Orchestrates history/trend reads and debug-history operations.
class BodyMetricsTrendUseCase {

    var _history;

    function initialize(history) {
        _history = history;
    }

    function populateHistoryDebug(heightCm as Float, bmrBase as Float) as Void {
        _history.populateHistoryDebug(heightCm, bmrBase);
    }

    function clearHistoryDebug() as Void {
        _history.clearHistory();
    }

    function disableDebugMode() as Void {
        _history.disableDebugHistory();
    }

    function lastRawEntry() as Array? {
        return _history.lastRawEntry();
    }

    function recordSnapshot(metrics as Array) as Void {
        _history.recordSnapshot(metrics);
    }

    function historyValues(metricIndex as Number, windowDays as Number) as Array {
        return _history.valuesForMetric(metricIndex, windowDays);
    }

    function hasHistoryEntries() as Boolean {
        return _history.hasEntries();
    }

    function removeLastHistoryEntry() as Void {
        _history.removeLastEntry();
    }
}