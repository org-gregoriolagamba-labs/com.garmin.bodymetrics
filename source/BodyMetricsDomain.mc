import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

const ZONE_GREEN = 0;
const ZONE_YELLOW = 1;
const ZONE_ORANGE = 2;
const ZONE_RED = 3;

const POLICY_TARGET_RANGE = "targetRange";
const POLICY_LOW_ONLY = "lowOnly";
const POLICY_HIGH_ONLY = "highOnly";
const POLICY_REFERENCE_ONLY = "referenceOnly";

const PROFILE_SEX_KEY = "bodyMetrics.profile.sex";
const PROFILE_AGE_BAND_KEY = "bodyMetrics.profile.ageBand";
const PROFILE_BODY_PROFILE_KEY = "bodyMetrics.profile.bodyProfile";
const PROFILE_HEIGHT_KEY = "bodyMetrics.profile.heightCm";

class BodyMetricsDomain {

    var _metrics;
    var _profile as Dictionary;
    var _measurements as Dictionary;
    var _hasStoredProfile as Boolean;

    function initialize() {
        _hasStoredProfile = false;
        _profile = loadProfile();
        _measurements = defaultMeasurements();
        rebuildMetrics();
    }

    function defaultProfile() as Dictionary {
        return {
            :sex => "male",
            :ageBand => "40_59",
            :bodyProfile => "general",
            :heightCm => 178
        };
    }

    function defaultMeasurements() as Dictionary {
        return {
            :weightKg => 89.6,
            :fatPct => 29.2,
            :musclePct => 38.61,
            :waterPct => 51.7,
            :boneKg => 4.7,
            :bmr => 1796.0
        };
    }

    function loadProfile() as Dictionary {
        var sex = Storage.getValue(PROFILE_SEX_KEY);
        var ageBand = Storage.getValue(PROFILE_AGE_BAND_KEY);
        var bodyProfile = Storage.getValue(PROFILE_BODY_PROFILE_KEY);
        var heightCm = Storage.getValue(PROFILE_HEIGHT_KEY);

        if (sex != null && ageBand != null && bodyProfile != null && heightCm != null) {
            _hasStoredProfile = true;
            return sanitizeProfile({
                :sex => sex,
                :ageBand => ageBand,
                :bodyProfile => bodyProfile,
                :heightCm => heightCm
            });
        }
        return defaultProfile();
    }

    function sanitizeProfile(profile as Dictionary) as Dictionary {
        var defaults = defaultProfile();
        return {
            :sex => profile.hasKey(:sex) ? profile[:sex] : defaults[:sex],
            :ageBand => profile.hasKey(:ageBand) ? profile[:ageBand] : defaults[:ageBand],
            :bodyProfile => profile.hasKey(:bodyProfile) ? profile[:bodyProfile] : defaults[:bodyProfile],
            :heightCm => profile.hasKey(:heightCm) ? profile[:heightCm] : defaults[:heightCm]
        };
    }

    function currentProfile() as Dictionary {
        return sanitizeProfile(_profile);
    }

    function hasConfiguredProfile() as Boolean {
        return _hasStoredProfile;
    }

    function saveProfile(profile as Dictionary) as Void {
        _profile = sanitizeProfile(profile);
        Storage.setValue(PROFILE_SEX_KEY, _profile[:sex].toString());
        Storage.setValue(PROFILE_AGE_BAND_KEY, _profile[:ageBand].toString());
        Storage.setValue(PROFILE_BODY_PROFILE_KEY, _profile[:bodyProfile].toString());
        Storage.setValue(PROFILE_HEIGHT_KEY, _profile[:heightCm].toNumber());
        _hasStoredProfile = true;
        rebuildMetrics();
    }

    function profileFields() as Array {
        return [
            {
                :key => :sex,
                :label => "Sesso",
                :type => "option",
                :values => ["male", "female"],
                :labels => ["Uomo", "Donna"]
            },
            {
                :key => :ageBand,
                :label => "Fascia eta",
                :type => "option",
                :values => ["18_39", "40_59", "60_plus"],
                :labels => ["18-39", "40-59", "60+"]
            },
            {
                :key => :heightCm,
                :label => "Altezza",
                :type => "number",
                :min => 150,
                :max => 210,
                :step => 1
            },
            {
                :key => :bodyProfile,
                :label => "Profilo",
                :type => "option",
                :values => ["general", "endurance", "strength"],
                :labels => ["Generale", "Endurance", "Strength"]
            }
        ];
    }

    function profileFieldCount() as Number {
        return profileFields().size();
    }

    function profileFieldDefinition(index as Number) as Dictionary {
        return profileFields()[index] as Dictionary;
    }

    function cycleProfileField(profile as Dictionary, index as Number, delta as Number) as Dictionary {
        var nextProfile = sanitizeProfile(profile);
        var field = profileFieldDefinition(index);
        var key = field[:key];

        if (field[:type].equals("number")) {
            var nextValue = nextProfile[:heightCm].toNumber() + (delta * field[:step].toNumber());
            if (nextValue < field[:min]) {
                nextValue = field[:max];
            } else if (nextValue > field[:max]) {
                nextValue = field[:min];
            }
            nextProfile[:heightCm] = nextValue;
            return nextProfile;
        }

        var values = field[:values] as Array;
        var currentIndex = 0;
        for (var i = 0; i < values.size(); i += 1) {
            if (values[i].equals(nextProfile[key])) {
                currentIndex = i;
                break;
            }
        }

        currentIndex = (currentIndex + delta + values.size()) % values.size();
        if (key == :sex) {
            nextProfile[:sex] = values[currentIndex];
        } else if (key == :ageBand) {
            nextProfile[:ageBand] = values[currentIndex];
        } else if (key == :bodyProfile) {
            nextProfile[:bodyProfile] = values[currentIndex];
        }
        return nextProfile;
    }

    function profileFieldValueLabel(profile as Dictionary, index as Number) as String {
        var safeProfile = sanitizeProfile(profile);
        var field = profileFieldDefinition(index);
        var key = field[:key];

        if (field[:type].equals("number")) {
            return safeProfile[key].toString() + " cm";
        }

        var values = field[:values] as Array;
        var labels = field[:labels] as Array;
        for (var i = 0; i < values.size(); i += 1) {
            if (values[i].equals(safeProfile[key])) {
                return labels[i].toString();
            }
        }

        return safeProfile[key].toString();
    }

    function rebuildMetrics() as Void {
        _metrics = buildMetrics(_profile, _measurements);
    }

    function buildMetrics(profile as Dictionary, measurements as Dictionary) as Array {
        var metrics = [];
        var bmiRange = bmiTargetRange(profile);
        var fatRange = fatPctRange(profile);
        var muscleKgBand = muscleKgRange(profile);
        var musclePctBand = musclePctRange(profile);
        var waterBand = waterPctRange(profile);
        var boneBand = boneKgRange(profile);
        var weightRange = weightTargetRange(profile, bmiRange);

        metrics.add(buildTargetMetric(
            "bmi", "BMI", "kg/m2", calculateBmi(measurements[:weightKg], profile[:heightCm]),
            bmiRange[:greenMin], bmiRange[:greenMax],
            bmiRange[:yellowLowMin], bmiRange[:yellowLowMax],
            bmiRange[:yellowHighMin], bmiRange[:yellowHighMax],
            bmiRange[:orangeLowMin], bmiRange[:orangeLowMax],
            bmiRange[:orangeHighMin], bmiRange[:orangeHighMax]
        ));

        metrics.add(buildTargetMetric(
            "fat_pct", "Grasso %", "%", measurements[:fatPct],
            fatRange[:greenMin], fatRange[:greenMax],
            fatRange[:yellowLowMin], fatRange[:yellowLowMax],
            fatRange[:yellowHighMin], fatRange[:yellowHighMax],
            fatRange[:orangeLowMin], fatRange[:orangeLowMax],
            fatRange[:orangeHighMin], fatRange[:orangeHighMax]
        ));

        metrics.add(buildLowOnlyMetric(
            "muscle_kg", "Massa muscolare", "kg", muscleKgFromMeasurements(measurements),
            muscleKgBand[:greenMin], muscleKgBand[:greenMax],
            muscleKgBand[:yellowMin], muscleKgBand[:orangeMin]
        ));

        metrics.add(buildLowOnlyMetric(
            "muscle_pct", "Muscoli %", "%", measurements[:musclePct],
            musclePctBand[:greenMin], musclePctBand[:greenMax],
            musclePctBand[:yellowMin], musclePctBand[:orangeMin]
        ));

        metrics.add(buildLowOnlyMetric(
            "water_pct", "Idratazione", "%", measurements[:waterPct],
            waterBand[:greenMin], waterBand[:greenMax],
            waterBand[:yellowMin], waterBand[:orangeMin]
        ));

        metrics.add(buildLowOnlyMetric(
            "bone_kg", "Massa ossea", "kg", measurements[:boneKg],
            boneBand[:greenMin], boneBand[:greenMax],
            boneBand[:yellowMin], boneBand[:orangeMin]
        ));

        metrics.add(buildTargetMetric(
            "weight", "Peso", "kg", measurements[:weightKg],
            weightRange[:greenMin], weightRange[:greenMax],
            weightRange[:yellowLowMin], weightRange[:yellowLowMax],
            weightRange[:yellowHighMin], weightRange[:yellowHighMax],
            weightRange[:orangeLowMin], weightRange[:orangeLowMax],
            weightRange[:orangeHighMin], weightRange[:orangeHighMax]
        ));

        metrics.add(buildReferenceMetric(
            "bmr", "BMR", "kcal", measurements[:bmr],
            calculateBmrReference(profile, measurements[:weightKg]), 5.0, 10.0
        ));

        return metrics;
    }

    function buildTargetMetric(id as String, label as String, unit as String, value, greenMin, greenMax,
        yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax,
        orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_TARGET_RANGE,
            :value => value,
            :greenMin => greenMin,
            :greenMax => greenMax,
            :yellowLowMin => yellowLowMin,
            :yellowLowMax => yellowLowMax,
            :yellowHighMin => yellowHighMin,
            :yellowHighMax => yellowHighMax,
            :orangeLowMin => orangeLowMin,
            :orangeLowMax => orangeLowMax,
            :orangeHighMin => orangeHighMin,
            :orangeHighMax => orangeHighMax
        };
    }

    function buildLowOnlyMetric(id as String, label as String, unit as String, value, greenMin, greenMax, yellowMin, orangeMin) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_LOW_ONLY,
            :value => value,
            :greenMin => greenMin,
            :greenMax => greenMax,
            :yellowMin => yellowMin,
            :orangeMin => orangeMin
        };
    }

    function buildReferenceMetric(id as String, label as String, unit as String, value, referenceValue, toleranceGoodPct, toleranceMildPct) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_REFERENCE_ONLY,
            :value => value,
            :referenceValue => referenceValue,
            :toleranceGoodPct => toleranceGoodPct,
            :toleranceMildPct => toleranceMildPct
        };
    }

    function bmiTargetRange(profile as Dictionary) as Dictionary {
        var sex = profile[:sex].toString();
        var bodyProfile = profile[:bodyProfile].toString();
        var greenMin = 20.0;
        var greenMax = 24.9;

        if (sex.equals("female")) {
            greenMin = 19.0;
            greenMax = 24.4;
        }

        if (bodyProfile.equals("endurance")) {
            greenMin = sex.equals("female") ? 18.5 : 19.0;
            greenMax = sex.equals("female") ? 23.5 : 23.9;
        } else if (bodyProfile.equals("strength")) {
            greenMin = sex.equals("female") ? 20.0 : 21.0;
            greenMax = sex.equals("female") ? 26.0 : 27.0;
        }

        if (profile[:ageBand].equals("40_59")) {
            greenMax += 0.5;
        } else if (profile[:ageBand].equals("60_plus")) {
            greenMax += 1.0;
        }

        return buildTargetThresholds(greenMin, greenMax, 1.5, 3.0, 2.0, 4.5);
    }

    function fatPctRange(profile as Dictionary) as Dictionary {
        var sex = profile[:sex].toString();
        var ageBand = profile[:ageBand].toString();
        var bodyProfile = profile[:bodyProfile].toString();
        var greenMin;
        var greenMax;

        if (sex.equals("female")) {
            if (ageBand.equals("18_39")) {
                greenMin = 20.0;
                greenMax = 31.0;
            } else if (ageBand.equals("40_59")) {
                greenMin = 21.0;
                greenMax = 33.0;
            } else {
                greenMin = 22.0;
                greenMax = 35.0;
            }
        } else {
            if (ageBand.equals("18_39")) {
                greenMin = 10.0;
                greenMax = 20.0;
            } else if (ageBand.equals("40_59")) {
                greenMin = 11.0;
                greenMax = 22.0;
            } else {
                greenMin = 13.0;
                greenMax = 25.0;
            }
        }

        if (bodyProfile.equals("endurance")) {
            greenMin -= 2.0;
            greenMax -= 2.0;
        }

        return buildTargetThresholds(greenMin, greenMax, 2.0, 4.0, 3.0, 8.0);
    }

    function muscleKgRange(profile as Dictionary) as Dictionary {
        var sex = profile[:sex].toString();
        var bodyProfile = profile[:bodyProfile].toString();
        var greenMin;
        var greenMax;

        if (sex.equals("female")) {
            if (bodyProfile.equals("endurance")) {
                greenMin = 26.0;
                greenMax = 34.0;
            } else if (bodyProfile.equals("strength")) {
                greenMin = 29.0;
                greenMax = 40.0;
            } else {
                greenMin = 27.0;
                greenMax = 36.0;
            }
        } else {
            if (bodyProfile.equals("endurance")) {
                greenMin = 33.0;
                greenMax = 44.0;
            } else if (bodyProfile.equals("strength")) {
                greenMin = 38.0;
                greenMax = 52.0;
            } else {
                greenMin = 35.0;
                greenMax = 46.0;
            }
        }

        if (profile[:ageBand].equals("60_plus")) {
            greenMin -= 2.0;
            greenMax -= 2.0;
        }

        return buildLowThresholds(greenMin, greenMax, 3.0, 7.0);
    }

    function musclePctRange(profile as Dictionary) as Dictionary {
        var sex = profile[:sex].toString();
        var bodyProfile = profile[:bodyProfile].toString();
        var greenMin;
        var greenMax;

        if (sex.equals("female")) {
            if (bodyProfile.equals("endurance")) {
                greenMin = 33.0;
                greenMax = 43.0;
            } else if (bodyProfile.equals("strength")) {
                greenMin = 36.0;
                greenMax = 46.0;
            } else {
                greenMin = 34.0;
                greenMax = 44.0;
            }
        } else {
            if (bodyProfile.equals("endurance")) {
                greenMin = 39.0;
                greenMax = 49.0;
            } else if (bodyProfile.equals("strength")) {
                greenMin = 42.0;
                greenMax = 53.0;
            } else {
                greenMin = 40.0;
                greenMax = 50.0;
            }
        }

        if (profile[:ageBand].equals("60_plus")) {
            greenMin -= 2.0;
            greenMax -= 2.0;
        }

        return buildLowThresholds(greenMin, greenMax, 3.0, 6.0);
    }

    function waterPctRange(profile as Dictionary) as Dictionary {
        var greenMin = profile[:sex].equals("female") ? 50.0 : 55.0;
        var greenMax = profile[:sex].equals("female") ? 60.0 : 65.0;
        return buildLowThresholds(greenMin, greenMax, 3.0, 6.0);
    }

    function boneKgRange(profile as Dictionary) as Dictionary {
        var greenMin = profile[:sex].equals("female") ? 2.6 : 3.3;
        var greenMax = profile[:sex].equals("female") ? 3.4 : 4.2;
        return buildLowThresholds(greenMin, greenMax, 0.3, 0.7);
    }

    function weightTargetRange(profile as Dictionary, bmiRange as Dictionary) as Dictionary {
        var heightM = profile[:heightCm].toFloat() / 100.0;
        var heightSquared = heightM * heightM;

        return buildTargetMetricThresholds(
            roundToOneDecimal(bmiRange[:greenMin].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:greenMax].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:yellowLowMin].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:yellowLowMax].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:yellowHighMin].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:yellowHighMax].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:orangeLowMin].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:orangeLowMax].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:orangeHighMin].toFloat() * heightSquared),
            roundToOneDecimal(bmiRange[:orangeHighMax].toFloat() * heightSquared)
        );
    }

    function buildTargetThresholds(greenMin as Float, greenMax as Float, lowStepYellow as Float, lowStepOrange as Float, highStepYellow as Float, highStepOrange as Float) as Dictionary {
        return buildTargetMetricThresholds(
            roundToOneDecimal(greenMin),
            roundToOneDecimal(greenMax),
            roundToOneDecimal(greenMin - lowStepYellow),
            roundToOneDecimal(greenMin),
            roundToOneDecimal(greenMax),
            roundToOneDecimal(greenMax + highStepYellow),
            roundToOneDecimal(greenMin - lowStepOrange),
            roundToOneDecimal(greenMin - lowStepYellow),
            roundToOneDecimal(greenMax + highStepYellow),
            roundToOneDecimal(greenMax + highStepOrange)
        );
    }

    function buildTargetMetricThresholds(greenMin, greenMax, yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax, orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
        return {
            :greenMin => greenMin,
            :greenMax => greenMax,
            :yellowLowMin => yellowLowMin,
            :yellowLowMax => yellowLowMax,
            :yellowHighMin => yellowHighMin,
            :yellowHighMax => yellowHighMax,
            :orangeLowMin => orangeLowMin,
            :orangeLowMax => orangeLowMax,
            :orangeHighMin => orangeHighMin,
            :orangeHighMax => orangeHighMax
        };
    }

    function buildLowThresholds(greenMin as Float, greenMax as Float, yellowStep as Float, orangeStep as Float) as Dictionary {
        return {
            :greenMin => roundToOneDecimal(greenMin),
            :greenMax => roundToOneDecimal(greenMax),
            :yellowMin => roundToOneDecimal(greenMin - yellowStep),
            :orangeMin => roundToOneDecimal(greenMin - orangeStep)
        };
    }

    function representativeAge(profile as Dictionary) as Number {
        if (profile[:ageBand].equals("18_39")) {
            return 30;
        }
        if (profile[:ageBand].equals("40_59")) {
            return 50;
        }
        return 65;
    }

    function calculateBmi(weightKg, heightCm) as Float {
        var heightM = heightCm.toFloat() / 100.0;
        return roundToOneDecimal(weightKg.toFloat() / (heightM * heightM));
    }

    function calculateBmrReference(profile as Dictionary, weightKg) as Number {
        var age = representativeAge(profile);
        var height = profile[:heightCm].toFloat();
        var base = (10.0 * weightKg.toFloat()) + (6.25 * height) - (5.0 * age.toFloat());
        if (profile[:sex].equals("female")) {
            return Math.round(base - 161.0).toNumber();
        }
        return Math.round(base + 5.0).toNumber();
    }

    function muscleKgFromMeasurements(measurements as Dictionary) as Float {
        return roundToOneDecimal(measurements[:weightKg].toFloat() * (measurements[:musclePct].toFloat() / 100.0));
    }

    function roundToOneDecimal(value as Float) as Float {
        return Math.round(value * 10.0).toFloat() / 10.0;
    }

    function metricsCount() as Number {
        return _metrics.size();
    }

    function metricAt(index as Number) as Dictionary {
        var metrics = _metrics as Array;
        return metrics[index] as Dictionary;
    }

    function metricLabel(index as Number) as String {
        return metricAt(index)[:label].toString();
    }

    function classify(metric as Dictionary) {
        var value = metric[:value];
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return classifyLowOnly(metric, value);
        }

        if (policy.equals(POLICY_HIGH_ONLY)) {
            return classifyHighOnly(metric, value);
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
        var yellowLowMin = thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = thresholdOr(metric, :orangeLowMax, :yellowMin);
        var orangeHighMin = thresholdOr(metric, :orangeHighMin, :yellowMax);
        var orangeHighMax = thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (inRange(value, metric[:greenMin], metric[:greenMax])) {
            return ZONE_GREEN;
        }

        if (inRange(value, yellowLowMin, yellowLowMax) || inRange(value, yellowHighMin, yellowHighMax)) {
            return ZONE_YELLOW;
        }

        if (inRange(value, orangeLowMin, orangeLowMax) || inRange(value, orangeHighMin, orangeHighMax)) {
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

    function classifyHighOnly(metric as Dictionary, value) {
        if (value <= metric[:greenMax]) {
            return ZONE_GREEN;
        }

        if (value <= metric[:yellowHighMax]) {
            return ZONE_YELLOW;
        }

        if (value <= metric[:orangeHighMax]) {
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

    function thresholdOr(metric as Dictionary, key, fallbackKey) {
        if (metric.hasKey(key)) {
            return metric[key];
        }

        if (metric.hasKey(fallbackKey)) {
            return metric[fallbackKey];
        }

        return null;
    }

    function inRange(value, minValue, maxValue) {
        if (minValue == null || maxValue == null) {
            return false;
        }
        return value >= minValue && value <= maxValue;
    }

    function zoneRangeText(metric as Dictionary) as String {
        var value = metric[:value];
        var zone = classify(metric);
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return zoneRangeTextLowOnly(metric, zone);
        }

        if (policy.equals(POLICY_HIGH_ONLY)) {
            return zoneRangeTextHighOnly(metric, zone);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return zoneRangeTextReferenceOnly(metric);
        }

        return zoneRangeTextTarget(metric, zone, value);
    }

    function zoneRangeTextTarget(metric as Dictionary, zone as Number, value) as String {
        var greenMin = thresholdOr(metric, :greenMin, :yellowLowMax);
        var greenMax = thresholdOr(metric, :greenMax, :yellowHighMin);
        var yellowLowMin = thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = thresholdOr(metric, :orangeLowMax, :yellowLowMin);
        var orangeHighMin = thresholdOr(metric, :orangeHighMin, :yellowHighMax);
        var orangeHighMax = thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (zone == ZONE_GREEN) {
            return fmtThreshold(greenMin) + "-" + fmtThreshold(greenMax);
        }

        if (zone == ZONE_YELLOW) {
            if (value < greenMin) {
                return fmtThreshold(yellowLowMin) + "-" + fmtThreshold(yellowLowMax);
            }
            return fmtThreshold(yellowHighMin) + "-" + fmtThreshold(yellowHighMax);
        }

        if (zone == ZONE_ORANGE) {
            if (value < greenMin) {
                return fmtThreshold(orangeLowMin) + "-" + fmtThreshold(orangeLowMax);
            }
            return fmtThreshold(orangeHighMin) + "-" + fmtThreshold(orangeHighMax);
        }

        if (orangeLowMin != null && value < orangeLowMin) {
            return "< " + fmtThreshold(orangeLowMin);
        }
        return "> " + fmtThreshold(orangeHighMax);
    }

    function zoneRangeTextLowOnly(metric as Dictionary, zone as Number) as String {
        if (zone == ZONE_GREEN) {
            return fmtThreshold(metric[:greenMin]) + "-" + fmtThreshold(metric[:greenMax]);
        }

        if (zone == ZONE_YELLOW) {
            return fmtThreshold(metric[:yellowMin]) + "-" + fmtThreshold(metric[:greenMin]);
        }

        if (zone == ZONE_ORANGE) {
            return fmtThreshold(metric[:orangeMin]) + "-" + fmtThreshold(metric[:yellowMin]);
        }

        return "< " + fmtThreshold(metric[:orangeMin]);
    }

    function zoneRangeTextHighOnly(metric as Dictionary, zone as Number) as String {
        if (zone == ZONE_GREEN) {
            return "<= " + fmtThreshold(metric[:greenMax]);
        }

        if (zone == ZONE_YELLOW) {
            return fmtThreshold(metric[:greenMax]) + "-" + fmtThreshold(metric[:yellowHighMax]);
        }

        if (zone == ZONE_ORANGE) {
            return fmtThreshold(metric[:yellowHighMax]) + "-" + fmtThreshold(metric[:orangeHighMax]);
        }

        return "> " + fmtThreshold(metric[:orangeHighMax]);
    }

    function zoneRangeTextReferenceOnly(metric as Dictionary) as String {
        return "Rif " + fmtThreshold(metric[:referenceValue]) + " (+/-" + metric[:toleranceGoodPct].toString() + "%)";
    }

    function fmtThreshold(value) as String {
        if (value == null) {
            return "--";
        }

        var f = value.toFloat();
        var scaled = Math.round(f * 100.0).toNumber();
        var whole = scaled / 100;
        var decimals = scaled - (whole * 100);

        if (decimals < 10) {
            return whole.toString() + ".0" + decimals.toString();
        }

        return whole.toString() + "." + decimals.toString();
    }

    function semanticZoneLabel(metric as Dictionary) as String {
        var zone = classify(metric);
        var policy = classificationPolicy(metric);
        var value = metric[:value];

        if (policy.equals(POLICY_LOW_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "Adeguato";
            }
            if (zone == ZONE_YELLOW) {
                return "Al limite";
            }
            if (zone == ZONE_ORANGE) {
                return "Basso";
            }
            return "Molto basso";
        }

        if (policy.equals(POLICY_HIGH_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "Adeguato";
            }
            if (zone == ZONE_YELLOW) {
                return "Da monitorare";
            }
            if (zone == ZONE_ORANGE) {
                return "Alto";
            }
            return "Molto alto";
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "In linea";
            }
            if (value.toFloat() < metric[:referenceValue].toFloat()) {
                return "Sotto rif.";
            }
            return "Sopra rif.";
        }

        if (zone == ZONE_GREEN) {
            return "Ottimale";
        }
        if (zone == ZONE_YELLOW) {
            if (value < metric[:greenMin]) {
                return "Legg. basso";
            }
            return "Legg. alto";
        }
        if (zone == ZONE_ORANGE) {
            if (value < metric[:greenMin]) {
                return "Basso";
            }
            return "Alto";
        }
        if (value < metric[:greenMin]) {
            return "Molto basso";
        }
        return "Molto alto";
    }

    function semanticZoneHint(metric as Dictionary) as String {
        var zone = classify(metric);
        var policy = classificationPolicy(metric);
        var value = metric[:value];

        if (policy.equals(POLICY_LOW_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "Livello adeguato";
            }
            if (zone == ZONE_YELLOW) {
                return "Da consolidare";
            }
            if (zone == ZONE_ORANGE) {
                return "Sotto soglia";
            }
            return "Recupero prioritario";
        }

        if (policy.equals(POLICY_HIGH_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "Valore gestito";
            }
            if (zone == ZONE_YELLOW) {
                return "Attenzione";
            }
            if (zone == ZONE_ORANGE) {
                return "Oltre soglia";
            }
            return "Ridurre presto";
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return "Coerente col profilo";
            }
            if (value.toFloat() < metric[:referenceValue].toFloat()) {
                return "Sotto il riferimento";
            }
            return "Sopra il riferimento";
        }

        if (zone == ZONE_GREEN) {
            return "Nel range";
        }
        if (zone == ZONE_YELLOW) {
            if (value < metric[:greenMin]) {
                return "Poco basso";
            }
            return "Poco alto";
        }
        if (zone == ZONE_ORANGE) {
            return "Fuori range";
        }
        if (value < metric[:greenMin]) {
            return "Deficit marcato";
        }
        return "Eccesso marcato";
    }

    function zoneColor(metric as Dictionary, zone as Number) {
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return 0x66CCFF;
            }
            if (zone == ZONE_YELLOW) {
                return 0x4D99CC;
            }
            return 0x336699;
        }

        if (zone == ZONE_GREEN) {
            return Graphics.COLOR_GREEN;
        }

        if (zone == ZONE_YELLOW) {
            return Graphics.COLOR_YELLOW;
        }

        if (zone == ZONE_ORANGE) {
            return Graphics.COLOR_ORANGE;
        }

        return Graphics.COLOR_RED;
    }
}
