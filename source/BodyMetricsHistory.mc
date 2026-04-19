import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;

//! Persistent timeseries storage for body metrics trend analysis.
//! Each daily snapshot: [timestamp, bmi, fat%, muscleKg, muscle%, water%, boneKg, weight, bmr].
//! Metric indices 0-7 match the order in BodyMetricsDomain.buildMetrics().

const HISTORY_KEY = "bm.hist";
const HISTORY_DEBUG_BACKUP_KEY = "bm.hist.debug.backup";
const HISTORY_DEBUG_ACTIVE_KEY = "bm.hist.debug.active";
const HISTORY_MAX_ENTRIES = 90;
const HISTORY_FIELDS = 9; // timestamp + 8 metrics

const TREND_UP = 1;
const TREND_FLAT = 0;
const TREND_DOWN = -1;

class BodyMetricsHistory {
    //! DEBUG: Popola la history con dati realistici per 90 giorni
    function populateHistoryDebug() as Void {
        if (!isDebugHistoryActive()) {
            Storage.setValue(HISTORY_DEBUG_BACKUP_KEY, _loadEntries());
        }

        var entries = [] as Array;
        var now = Time.now().value();
        var weight = 78.5;
        var fat = 21.5;
        var musclePct = 39.0;
        var water = 54.0;
        var bone = 3.3;
        var bmi = 25.2;
        var muscleKg = 30.6;
        var bmr = 1675.0;
        var seed = now;
        for (var i = 89; i >= 0; i -= 1) {
            var ts = now - (i * 86400);

            // Skip some days (roughly 15%) for realism - not every day gets measured
            var skipRoll = _nextDebugUnit(seed + i * 7);
            if (skipRoll < 0.15 && i > 0 && i < 85) {
                seed += 8;
                continue;
            }

            // Phase-based drift: first 30d slow start, middle 30d main progress, last 30d maintenance
            var phase = (89 - i) / 30;
            var driftScale = 1.0;
            if (phase == 0) { driftScale = 0.5; }
            else if (phase == 2) { driftScale = 0.3; }

            // Weekly fluctuation (weekends tend to disrupt diet)
            var dayOfWeek = (i + 3) % 7;  // arbitrary offset
            var weekendBump = 0.0;
            if (dayOfWeek >= 5) { weekendBump = 0.03; } // Sat/Sun: slight weight/fat bump

            // Occasional plateau (days 40-50 stall)
            var plateauScale = 1.0;
            if (i >= 39 && i <= 49) { plateauScale = 0.1; }

            var effDrift = driftScale * plateauScale;

            weight = _driftValue(weight, (-0.015 + weekendBump) * effDrift, 0.12, seed);
            seed += 1;
            fat = _driftValue(fat, (-0.010 + weekendBump * 0.5) * effDrift, 0.10, seed);
            seed += 1;
            musclePct = _driftValue(musclePct, 0.004 * effDrift, 0.06, seed);
            seed += 1;
            water = _driftValue(water, 0.003 * effDrift, 0.08, seed);
            seed += 1;
            bone = _driftValue(bone, 0.0002 * effDrift, 0.01, seed);
            seed += 1;
            bmi = weight / (1.75 * 1.75);  // derive from weight for consistency
            seed += 1;
            muscleKg = weight * musclePct / 100.0;  // derive from weight + muscle%
            seed += 1;
            bmr = _driftValue(bmr, -0.12 * effDrift, 3.0, seed);
            seed += 1;
            var entry = [ts, bmi, fat, muscleKg, musclePct, water, bone, weight, bmr];
            entries.add(entry);
        }
        Storage.setValue(HISTORY_KEY, entries);
        Storage.setValue(HISTORY_DEBUG_ACTIVE_KEY, true);
    }

    function initialize() {
    }

    //! Record current metric values. Replaces same-day entry; otherwise appends.
    function recordSnapshot(metrics as Array) as Void {
        if (isDebugHistoryActive()) {
            disableDebugHistory();
        }

        var entries = _loadEntries();
        var now = Time.now().value();
        var todayNum = now / 86400;
        var entry = _buildEntry(now, metrics);

        if (entries.size() > 0) {
            var last = entries[entries.size() - 1] as Array;
            if ((last[0] as Number) / 86400 == todayNum) {
                entries[entries.size() - 1] = entry;
            } else {
                entries.add(entry);
            }
        } else {
            entries.add(entry);
        }

        if (entries.size() > HISTORY_MAX_ENTRIES) {
            var trimmed = [] as Array;
            for (var i = entries.size() - HISTORY_MAX_ENTRIES; i < entries.size(); i++) {
                trimmed.add(entries[i]);
            }
            entries = trimmed;
        }

        Storage.setValue(HISTORY_KEY, entries);
    }

    //! Data points for metric index (0-7) within windowDays.
    //! Returns Array of {:ts => Number, :val => Float}, oldest first.
    function valuesForMetric(metricIndex as Number, windowDays as Number) as Array {
        var entries = _loadEntries();
        var cutoff = Time.now().value() - (windowDays * 86400);
        var fi = metricIndex + 1;
        var result = [] as Array;
        for (var i = 0; i < entries.size(); i++) {
            var e = entries[i] as Array;
            if ((e[0] as Number) >= cutoff && fi < e.size() && e[fi] != null) {
                result.add({:ts => e[0], :val => e[fi]});
            }
        }
        return result;
    }

    //! Trend direction: TREND_UP/DOWN/FLAT. Threshold: +/-1% change.
    function computeTrend(metricIndex as Number, windowDays as Number) as Number {
        var vals = valuesForMetric(metricIndex, windowDays);
        if (vals.size() < 2) { return TREND_FLAT; }
        var first = (vals[0] as Dictionary)[:val].toFloat();
        var last = (vals[vals.size() - 1] as Dictionary)[:val].toFloat();
        var base = first < 0.0 ? -first : first;
        if (base < 1.0) { base = 1.0; }
        var change = ((last - first) / base) * 100.0;
        if (change > 1.0) { return TREND_UP; }
        if (change < -1.0) { return TREND_DOWN; }
        return TREND_FLAT;
    }

    //! Largest window (90, 30, 7) with >= 2 data points, or 0 if none.
    function bestWindow(metricIndex as Number) as Number {
        var entries = _loadEntries();
        var now = Time.now().value();
        var fi = metricIndex + 1;
        var windows = [90, 30, 7];
        for (var w = 0; w < windows.size(); w++) {
            var cutoff = now - ((windows[w] as Number) * 86400);
            var count = 0;
            for (var i = 0; i < entries.size(); i++) {
                var e = entries[i] as Array;
                if ((e[0] as Number) >= cutoff && fi < e.size() && e[fi] != null) {
                    count++;
                    if (count >= 2) { return windows[w] as Number; }
                }
            }
        }
        return 0;
    }

    //! Number of stored history entries.
    function entryCount() as Number {
        var stored = Storage.getValue(HISTORY_KEY);
        if (stored == null) { return 0; }
        return (stored as Array).size();
    }

    //! DEBUG: Clear all history entries.
    function clearHistory() as Void {
        if (isDebugHistoryActive()) {
            disableDebugHistory();
            return;
        }

        Storage.deleteValue(HISTORY_KEY);
    }

    //! DEBUG: Restore real history if debug data is active.
    function disableDebugHistory() as Void {
        if (!isDebugHistoryActive()) { return; }

        var backup = Storage.getValue(HISTORY_DEBUG_BACKUP_KEY);
        if (backup != null) {
            Storage.setValue(HISTORY_KEY, backup as Array);
        } else {
            Storage.deleteValue(HISTORY_KEY);
        }

        Storage.deleteValue(HISTORY_DEBUG_BACKUP_KEY);
        Storage.deleteValue(HISTORY_DEBUG_ACTIVE_KEY);
    }

    function isDebugHistoryActive() as Boolean {
        var active = Storage.getValue(HISTORY_DEBUG_ACTIVE_KEY);
        return active != null && (active as Boolean);
    }

    hidden function _buildEntry(ts as Number, metrics as Array) as Array {
        var entry = new [HISTORY_FIELDS];
        entry[0] = ts;
        for (var i = 0; i < 8 && i < metrics.size(); i++) {
            var m = metrics[i] as Dictionary;
            entry[i + 1] = m[:available] ? m[:value] : null;
        }
        return entry;
    }

    hidden function _loadEntries() as Array {
        var stored = Storage.getValue(HISTORY_KEY);
        if (stored == null) { return [] as Array; }
        var arr = stored as Array;
        var result = [] as Array;
        for (var i = 0; i < arr.size(); i++) {
            result.add(arr[i]);
        }
        return result;
    }

    hidden function _nextDebugUnit(seed as Number) as Float {
        // Deterministic pseudo-random value in [0, 1) for simulator debug data.
        var next = (seed * 1103515245 + 12345) % 2147483647;
        return next.toFloat() / 2147483647.0;
    }

    hidden function _driftValue(current as Float, drift as Float, noiseAmplitude as Float, seed as Number) as Float {
        var noise = (_nextDebugUnit(seed) - 0.5) * noiseAmplitude;
        return current + drift + noise;
    }
}
