import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

//! Storage keys for persisted measurements
const MEAS_WEIGHT_KEY = "bodyMetrics.meas.weightKg";
const MEAS_FAT_KEY = "bodyMetrics.meas.fatPct";
const MEAS_MUSCLE_KEY = "bodyMetrics.meas.musclePct";
const MEAS_WATER_KEY = "bodyMetrics.meas.waterPct";
const MEAS_BONE_KEY = "bodyMetrics.meas.boneKg";
const MEAS_BMR_KEY = "bodyMetrics.meas.bmr";
const MEAS_TIMESTAMP_KEY = "bodyMetrics.meas.timestamp";
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
        var weightKg = null;
        var weightSource = null;
        if (garminWeight != null) {
            weightKg = garminWeight.toFloat();
            weightSource = SOURCE_GARMIN;
        } else if (storageWeight != null) {
            weightKg = storageWeight.toFloat();
            weightSource = SOURCE_MANUAL;
        }

        // Body composition: only from manual entry (Storage)
        var fatVal = Storage.getValue(MEAS_FAT_KEY);
        var muscleVal = Storage.getValue(MEAS_MUSCLE_KEY);
        var waterVal = Storage.getValue(MEAS_WATER_KEY);
        var boneVal = Storage.getValue(MEAS_BONE_KEY);

        return {
            :weightKg => weightKg,
            :fatPct => fatVal != null ? fatVal.toFloat() : null,
            :musclePct => muscleVal != null ? muscleVal.toFloat() : null,
            :waterPct => waterVal != null ? waterVal.toFloat() : null,
            :boneKg => boneVal != null ? boneVal.toFloat() : null,
            :bmr => null,
            :weightSource => weightSource,
            :bodyCompSource => fatVal != null ? SOURCE_MANUAL : null
        };
    }

    //! Save manual measurements to persistent storage.
    function saveMeasurements(measurements as Dictionary) as Void {
        Storage.setValue(MEAS_WEIGHT_KEY, measurements[:weightKg].toFloat());
        Storage.setValue(MEAS_FAT_KEY, measurements[:fatPct].toFloat());
        Storage.setValue(MEAS_MUSCLE_KEY, measurements[:musclePct].toFloat());
        Storage.setValue(MEAS_WATER_KEY, measurements[:waterPct].toFloat());
        Storage.setValue(MEAS_BONE_KEY, measurements[:boneKg].toFloat());
        Storage.setValue(MEAS_TIMESTAMP_KEY, Time.now().value());
        Storage.setValue(MEAS_SOURCE_KEY, SOURCE_MANUAL);
    }

    //! Returns true if user has saved at least one set of measurements.
    function hasStoredMeasurements() as Boolean {
        return Storage.getValue(MEAS_WEIGHT_KEY) != null;
    }

    //! Returns the unix timestamp of last measurement update, or null.
    function lastUpdateTimestamp() {
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
            {:key => :musclePct, :label => locale.text("data.muscle_pct"), :unit => "%", :min => 15.0, :max => 70.0, :step => 0.1, :decimals => 2},
            {:key => :waterPct, :label => locale.text("data.water_pct"), :unit => "%", :min => 25.0, :max => 80.0, :step => 0.1, :decimals => 1},
            {:key => :boneKg, :label => locale.text("data.bone_kg"), :unit => "kg", :min => 1.0, :max => 8.0, :step => 0.1, :decimals => 1},
            {:key => :bmr, :label => locale.text("data.bmr"), :unit => "kcal", :min => 800.0, :max => 4000.0, :step => 10.0, :decimals => 0, :readOnly => true, :readOnlyText => locale.text("data.read_only"), :badgeText => locale.text("data.badge_auto")}
        ];
    }

    function pad2(n as Number) as String {
        if (n < 10) {
            return "0" + n.toString();
        }
        return n.toString();
    }
}
