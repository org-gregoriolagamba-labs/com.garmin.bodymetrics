import Toybox.Lang;

//! Orchestrates measurement persistence and data-entry field behavior.
class BodyMetricsMeasurementsUseCase {

    var _locale;
    var _dataProvider;
    var _calculators;

    function initialize(locale, dataProvider, calculators) {
        _locale = locale;
        _dataProvider = dataProvider;
        _calculators = calculators;
    }

    function lastUpdateDateLabel() as String {
        return _dataProvider.lastUpdateDateLabel();
    }

    function measurementFields() as Array {
        return _dataProvider.measurementFields(_locale);
    }

    function measurementFieldCount() as Number {
        return measurementFields().size();
    }

    function measurementFieldDefinition(index as Number) as Dictionary {
        return measurementFields()[index] as Dictionary;
    }

    function currentMeasurements(measurements as Dictionary, profile as Dictionary) as Dictionary {
        var draft = {
            :weightKg => measurements[:weightKg] != null ? measurements[:weightKg] : 75.0,
            :fatPct => measurements[:fatPct] != null ? measurements[:fatPct] : 25.0,
            :muscleKg => measurements[:muscleKg] != null ? measurements[:muscleKg] : 30.0,
            :musclePct => null,
            :waterPct => measurements[:waterPct] != null ? measurements[:waterPct] : 55.0,
            :boneKg => measurements[:boneKg] != null ? measurements[:boneKg] : 3.5,
            :bmr => null
        };
        return refreshDerivedMeasurementFields(draft, profile);
    }

    function cycleMeasurementField(draft as Dictionary, index as Number, delta as Number, profile as Dictionary) as Dictionary {
        var field = measurementFieldDefinition(index);
        if (field.hasKey(:readOnly) && field[:readOnly]) {
            return refreshDerivedMeasurementFields(draft, profile);
        }

        var key = field[:key];
        var current = draft[key].toFloat();
        var step = field[:step].toFloat();
        var next = current + (delta * step);
        if (next < field[:min].toFloat()) {
            next = field[:max].toFloat();
        } else if (next > field[:max].toFloat()) {
            next = field[:min].toFloat();
        }
        draft[key] = _round1(next);
        return refreshDerivedMeasurementFields(draft, profile);
    }

    function measurementFieldValueLabel(draft as Dictionary, index as Number) as String {
        var field = measurementFieldDefinition(index);
        var key = field[:key];
        if (draft[key] == null) {
            return _locale.text("hint.unavailable");
        }

        var value = draft[key].toFloat();
        return _fmt1(value) + " " + field[:unit].toString();
    }

    function saveMeasurements(draft as Dictionary) as Dictionary {
        _dataProvider.saveMeasurements(draft);
        return _dataProvider.loadMeasurements();
    }

    function refreshDerivedMeasurementFields(draft as Dictionary, profile as Dictionary) as Dictionary {
        draft[:bmr] = derivedBmrValueForDraft(draft, profile);
        draft[:musclePct] = derivedMusclePctForDraft(draft);
        return draft;
    }

    function derivedMusclePctForDraft(draft as Dictionary) {
        var muscleKg = draft[:muscleKg];
        var weightKg = draft[:weightKg];
        if (muscleKg == null || weightKg == null || weightKg.toFloat() <= 0.0) {
            return null;
        }
        return _round1(muscleKg.toFloat() / weightKg.toFloat() * 100.0);
    }

    function derivedBmrValueForDraft(draft as Dictionary, profile as Dictionary) {
        if (draft[:weightKg] == null || profile[:heightCm] == null ||
            profile[:sex] == null || profile[:ageBand] == null) {
            return null;
        }
        return _calculators.calculateBmrReference(profile, draft[:weightKg]).toFloat();
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
}