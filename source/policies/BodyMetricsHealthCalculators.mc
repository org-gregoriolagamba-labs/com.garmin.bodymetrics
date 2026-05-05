import Toybox.Lang;
import Toybox.Math;

//! Extracted pure calculations for BMI/BMR/muscle estimates.
//! Keeping this logic outside BodyMetricsDomain reduces coupling
//! and makes future unit-level verification easier.
class BodyMetricsHealthCalculators {

    function initialize() {
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
        return _round1(weightKg.toFloat() / (heightM * heightM));
    }

    function calculateBmrReference(profile as Dictionary, weightKg) as Float {
        var age = representativeAge(profile);
        var height = profile[:heightCm].toFloat();
        var base = (10.0 * weightKg.toFloat()) + (6.25 * height) - (5.0 * age.toFloat());
        if (profile[:sex].equals("female")) {
            return _round1(base - 161.0);
        }
        return _round1(base + 5.0);
    }

    function muscleKgFromMeasurements(measurements as Dictionary) as Float {
        return _round1(measurements[:weightKg].toFloat() * (measurements[:musclePct].toFloat() / 100.0));
    }

    //! Derive muscle % from directly entered muscle mass (kg) and weight (kg).
    //! muscle_pct = muscle_kg / weight_kg * 100
    function calculateMusclePct(muscleKg as Float, weightKg as Float) as Float {
        if (weightKg <= 0.0) { return 0.0; }
        return _round1(muscleKg / weightKg * 100.0);
    }

    //! Estimated muscle power output in watts.
    //! Formula: Potenza (W) = muscle_kg × 35
    //! Based on specific power of mixed skeletal muscle (~35 W/kg) referenced in
    //! exercise physiology literature (McArdle, Katch & Katch, Exercise Physiology, 8th ed.;
    //! Fitts & Widrick, 1996, "Muscle mechanics: adaptations with exercise-training").
    function calculatePotenza(muscleKg as Float) as Float {
        return _round1(muscleKg * 35.0);
    }

    hidden function _round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }
}
