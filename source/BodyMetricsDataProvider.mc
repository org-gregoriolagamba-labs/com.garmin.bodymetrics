import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

//! Storage keys for persisted measurements
const MEAS_WEIGHT_KEY = "bodyMetrics.meas.weightKg";
const MEAS_FAT_KEY = "bodyMetrics.meas.fatPct";
const MEAS_MUSCLE_KEY = "bodyMetrics.meas.musclePct";  // legacy key (pre-v2): no longer written, kept for cleanup
const MEAS_MUSCLE_KG_KEY = "bodyMetrics.meas.muscleKg";
const MEAS_WATER_KEY = "bodyMetrics.meas.waterPct";
const MEAS_BONE_KEY = "bodyMetrics.meas.boneKg";
const MEAS_TIMESTAMP_KEY = "bodyMetrics.meas.timestamp";
const MEAS_SYNC_TIMESTAMP_KEY = "bodyMetrics.meas.syncTimestamp";
const MEAS_SOURCE_KEY = "bodyMetrics.meas.source";

const SOURCE_MANUAL = "manual";

//! Manages body composition measurements with persistence.
//! v1: manual entry only (Index S2 API not accessible from CIQ widgets).
//! Garmin UserProfile provides weight; other body comp requires manual entry.
class BodyMetricsDataProvider {

    var _garminProfile as BodyMetricsGarminProfile;

    //! @param garminProfile shared BodyMetricsGarminProfile instance
    function initialize(garminProfile as BodyMetricsGarminProfile) {
        _garminProfile = garminProfile;
    }

    //! Load measurements: Garmin weight has priority, body comp from Storage only.
    function loadMeasurements() as Dictionary {
        // Garmin weight has priority over manual entry
        var garmin = _garminProfile.readProfile() as Dictionary;
        var garminWeight = _garminProfile.hasWeight() ? garmin[:weightKg] : null;
        var storageWeight = Storage.getValue(MEAS_WEIGHT_KEY);
        var syncTimestamp = Storage.getValue(MEAS_SYNC_TIMESTAMP_KEY);
        var weightKg = null;
        var weightSource = null;
        if (garminWeight != null) {
            weightKg = garminWeight.toFloat();
            weightSource = SOURCE_GARMIN;
            if (syncTimestamp == null || Storage.getValue(MEAS_SOURCE_KEY) != SOURCE_GARMIN) {
                syncTimestamp = Time.now().value();
                Storage.setValue(MEAS_SYNC_TIMESTAMP_KEY, syncTimestamp);
                Storage.setValue(MEAS_SOURCE_KEY, SOURCE_GARMIN);
            }
        } else if (storageWeight != null) {
            weightKg = storageWeight.toFloat();
            weightSource = SOURCE_MANUAL;
        }

        // Body composition: only from manual entry (Storage)
        var fatVal = Storage.getValue(MEAS_FAT_KEY);
        var muscleKgVal = Storage.getValue(MEAS_MUSCLE_KG_KEY);
        var waterVal = Storage.getValue(MEAS_WATER_KEY);
        var boneVal = Storage.getValue(MEAS_BONE_KEY);

        // muscle_pct is derived from muscleKg / weightKg (Garmin Index provides kg, not %)
        var musclePctDerived = null;
        if (muscleKgVal != null && weightKg != null && weightKg > 0.0) {
            musclePctDerived = Math.round(muscleKgVal.toFloat() / weightKg.toFloat() * 1000.0).toFloat() / 10.0;
        }

        return {
            :weightKg => weightKg,
            :fatPct => fatVal != null ? fatVal.toFloat() : null,
            :muscleKg => muscleKgVal != null ? muscleKgVal.toFloat() : null,
            :musclePct => musclePctDerived,
            :waterPct => waterVal != null ? waterVal.toFloat() : null,
            :boneKg => boneVal != null ? boneVal.toFloat() : null,
            :bmr => null,
            :weightSource => weightSource,
            :bodyCompSource => fatVal != null ? SOURCE_MANUAL : null,
            :syncTimestamp => syncTimestamp
        };
    }

    //! Save manual measurements to persistent storage.
    function saveMeasurements(measurements as Dictionary) as Void {
        Storage.setValue(MEAS_WEIGHT_KEY, measurements[:weightKg].toFloat());
        Storage.setValue(MEAS_FAT_KEY, measurements[:fatPct].toFloat());
        Storage.setValue(MEAS_MUSCLE_KG_KEY, measurements[:muscleKg].toFloat());
        Storage.deleteValue(MEAS_MUSCLE_KEY);  // remove legacy musclePct key if present
        Storage.setValue(MEAS_WATER_KEY, measurements[:waterPct].toFloat());
        Storage.setValue(MEAS_BONE_KEY, measurements[:boneKg].toFloat());
        Storage.setValue(MEAS_TIMESTAMP_KEY, Time.now().value());
        Storage.deleteValue(MEAS_SYNC_TIMESTAMP_KEY);
        Storage.setValue(MEAS_SOURCE_KEY, SOURCE_MANUAL);
    }

    //! Clears a single measurement field from persistent storage by its draft key.
    //! Read-only/derived fields (musclePct, bmr) are silently ignored.
    function clearMeasurementFieldByKey(fieldKey as Symbol) as Void {
        if (fieldKey == :weightKg) {
            Storage.deleteValue(MEAS_WEIGHT_KEY);
            Storage.deleteValue(MEAS_SYNC_TIMESTAMP_KEY);
            Storage.deleteValue(MEAS_SOURCE_KEY);
        } else if (fieldKey == :fatPct) {
            Storage.deleteValue(MEAS_FAT_KEY);
        } else if (fieldKey == :muscleKg) {
            Storage.deleteValue(MEAS_MUSCLE_KG_KEY);
        } else if (fieldKey == :waterPct) {
            Storage.deleteValue(MEAS_WATER_KEY);
        } else if (fieldKey == :boneKg) {
            Storage.deleteValue(MEAS_BONE_KEY);
        }
        // :musclePct and :bmr are derived — no storage key to delete
    }

    //! Clears all persisted measurement values and related metadata.
    function clearStoredMeasurements() as Void {        Storage.deleteValue(MEAS_WEIGHT_KEY);
        Storage.deleteValue(MEAS_FAT_KEY);
        Storage.deleteValue(MEAS_MUSCLE_KG_KEY);
        Storage.deleteValue(MEAS_MUSCLE_KEY);  // legacy key cleanup
        Storage.deleteValue(MEAS_WATER_KEY);
        Storage.deleteValue(MEAS_BONE_KEY);
        Storage.deleteValue(MEAS_TIMESTAMP_KEY);
        Storage.deleteValue(MEAS_SYNC_TIMESTAMP_KEY);
        Storage.deleteValue(MEAS_SOURCE_KEY);
    }

    //! Returns true if user has saved at least one set of measurements.
    function hasStoredMeasurements() as Boolean {
        return Storage.getValue(MEAS_WEIGHT_KEY) != null;
    }

    //! Returns true when at least one measurement source can provide data.
    //! This includes persisted manual data and Garmin weight.
    function hasAnyMeasurements() as Boolean {
        return hasStoredMeasurements() || _garminProfile.hasWeight();
    }

    //! Returns the unix timestamp of last measurement update, or null.
    function lastUpdateTimestamp() {
        var syncTimestamp = Storage.getValue(MEAS_SYNC_TIMESTAMP_KEY);
        if (syncTimestamp != null) {
            return syncTimestamp;
        }
        return Storage.getValue(MEAS_TIMESTAMP_KEY);
    }

    //! Formats the last update time as "dd/mm HH:MM" or null if no data.
    function lastUpdateLabel() as String {
        var ts = lastUpdateTimestamp();
        if (ts == null) {
            return "--";
        }
        var moment = new Time.Moment(ts);
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        var day = info.day.toNumber();
        var month = info.month.toNumber();
        var hour = info.hour.toNumber();
        var min = info.min.toNumber();
        return pad2(day) + "/" + pad2(month) + " " + pad2(hour) + ":" + pad2(min);
    }

    //! Formats the last update date as "dd/mm/yyyy" or null if no data.
    function lastUpdateDateLabel() as String {
        var ts = lastUpdateTimestamp();
        if (ts == null) {
            return "";
        }
        var moment = new Time.Moment(ts);
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        var day = info.day.toNumber();
        var month = info.month.toNumber();
        var year = info.year.toNumber();
        return pad2(day) + "/" + pad2(month) + "/" + year.toString();
    }

    //! Definition of measurement fields for the data entry UI.
    function measurementFields(locale as BodyMetricsLocale) as Array {
        var garmin = _garminProfile.readProfile() as Dictionary;
        var weightReadOnly = garmin[:weightKg] != null;

        return [
            {:key => :weightKg, :label => locale.text("data.weight"), :unit => "kg", :min => 30.0, :max => 250.0, :step => 0.1, :decimals => 1, :readOnly => weightReadOnly, :readOnlyText => locale.text("data.from_garmin"), :badgeText => locale.text("data.badge_garmin")},
            {:key => :fatPct, :label => locale.text("data.fat_pct"), :unit => "%", :min => 3.0, :max => 60.0, :step => 0.1, :decimals => 1},
            {:key => :muscleKg, :label => locale.text("data.muscle_kg"), :unit => "kg", :min => 10.0, :max => 80.0, :step => 0.1, :decimals => 1},
            {:key => :musclePct, :label => locale.text("data.muscle_pct"), :unit => "%", :min => 10.0, :max => 80.0, :step => 0.1, :decimals => 1, :readOnly => true, :readOnlyText => locale.text("data.read_only"), :badgeText => locale.text("data.badge_auto")},
            {:key => :waterPct, :label => locale.text("data.water_pct"), :unit => "%", :min => 25.0, :max => 80.0, :step => 0.1, :decimals => 1},
            {:key => :boneKg, :label => locale.text("data.bone_kg"), :unit => "kg", :min => 1.0, :max => 8.0, :step => 0.1, :decimals => 1},
            {:key => :bmr, :label => locale.text("data.bmr"), :unit => "kcal", :min => 800.0, :max => 4000.0, :step => 10.0, :decimals => 1, :readOnly => true, :readOnlyText => locale.text("data.read_only"), :badgeText => locale.text("data.badge_auto")}
        ];
    }

    function pad2(n as Number) as String {
        if (n < 10) {
            return "0" + n.toString();
        }
        return n.toString();
    }
}
