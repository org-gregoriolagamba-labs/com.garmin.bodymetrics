import Toybox.Lang;

//! Presentation-layer cache for trend values and available windows.
class BodyMetricsTrendCacheService {

    const TREND_UP = 1;
    const TREND_DOWN = -1;
    const TREND_FLAT = 0;

    var _trendWindows as Array;
    var _trendValueCache as Dictionary;
    var _trendWindowsCache as Dictionary;

    function initialize(trendWindows as Array) {
        _trendWindows = trendWindows;
        _trendValueCache = {};
        _trendWindowsCache = {};
    }

    function invalidate() as Void {
        _trendValueCache = {};
        _trendWindowsCache = {};
    }

    function cacheTrendData(domain, metricIndex as Number, trendWindow as Number) as Dictionary {
        var availableWindows = availableTrendWindows(domain, metricIndex);
        var nextWindow = trendWindow;

        if (nextWindow == 0 && availableWindows.size() > 0) {
            nextWindow = availableWindows[availableWindows.size() - 1] as Number;
        }

        if (nextWindow > 0) {
            var currentValues = historyValuesCached(domain, metricIndex, nextWindow);
            if (currentValues.size() < 2) {
                if (availableWindows.size() > 0) {
                    nextWindow = availableWindows[availableWindows.size() - 1] as Number;
                } else {
                    nextWindow = 0;
                }
            }
        }

        if (nextWindow > 0) {
            var values = historyValuesCached(domain, metricIndex, nextWindow);
            return {
                :window => nextWindow,
                :values => values,
                :direction => computeTrendDirection(values),
                :availableWindows => availableWindows
            };
        }

        return {
            :window => 0,
            :values => [],
            :direction => TREND_FLAT,
            :availableWindows => availableWindows
        };
    }

    function cycleTrendWindow(domain, metricIndex as Number, trendWindow as Number, delta as Number) as Dictionary {
        var windows = availableTrendWindows(domain, metricIndex);
        if (windows.size() == 0) {
            return cacheTrendData(domain, metricIndex, 0);
        }

        var currentIndex = 0;
        for (var i = 0; i < windows.size(); i += 1) {
            if ((windows[i] as Number) == trendWindow) {
                currentIndex = i;
                break;
            }
        }

        currentIndex = (currentIndex + delta + windows.size()) % windows.size();
        return cacheTrendData(domain, metricIndex, windows[currentIndex] as Number);
    }

    function availableTrendWindows(domain, metricIndex as Number) as Array {
        var metricKey = metricIndex.toString();
        if (_trendWindowsCache.hasKey(metricKey)) {
            return _trendWindowsCache[metricKey] as Array;
        }

        var windows = [] as Array;
        for (var i = 0; i < _trendWindows.size(); i += 1) {
            var candidate = _trendWindows[i] as Number;
            if (historyValuesCached(domain, metricIndex, candidate).size() >= 2) {
                windows.add(candidate);
            }
        }

        _trendWindowsCache[metricKey] = windows;
        return windows;
    }

    function historyValuesCached(domain, metricIndex as Number, windowDays as Number) as Array {
        var key = _trendCacheKey(metricIndex, windowDays);
        if (_trendValueCache.hasKey(key)) {
            return _trendValueCache[key] as Array;
        }

        var values = domain.historyValues(metricIndex, windowDays);
        _trendValueCache[key] = values;
        return values;
    }

    function computeTrendDirection(values as Array) as Number {
        if (values.size() < 2) {
            return TREND_FLAT;
        }

        var first = (values[0] as Dictionary)[:val].toFloat();
        var last = (values[values.size() - 1] as Dictionary)[:val].toFloat();
        var base = first < 0.0 ? -first : first;
        if (base < 1.0) { base = 1.0; }

        var change = ((last - first) / base) * 100.0;
        if (change > 1.0) { return TREND_UP; }
        if (change < -1.0) { return TREND_DOWN; }
        return TREND_FLAT;
    }

    hidden function _trendCacheKey(metricIndex as Number, windowDays as Number) as String {
        return metricIndex.toString() + ":" + windowDays.toString();
    }
}