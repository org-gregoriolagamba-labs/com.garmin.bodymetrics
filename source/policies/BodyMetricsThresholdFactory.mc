import Toybox.Lang;
import Toybox.Math;

//! Pure threshold/range policy for body metric target bands.
//! Keeps profile-driven range logic outside BodyMetricsDomain.
class BodyMetricsThresholdFactory {

    function initialize() {
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
            _round1(bmiRange[:greenMin].toFloat() * heightSquared),
            _round1(bmiRange[:greenMax].toFloat() * heightSquared),
            _round1(bmiRange[:yellowLowMin].toFloat() * heightSquared),
            _round1(bmiRange[:yellowLowMax].toFloat() * heightSquared),
            _round1(bmiRange[:yellowHighMin].toFloat() * heightSquared),
            _round1(bmiRange[:yellowHighMax].toFloat() * heightSquared),
            _round1(bmiRange[:orangeLowMin].toFloat() * heightSquared),
            _round1(bmiRange[:orangeLowMax].toFloat() * heightSquared),
            _round1(bmiRange[:orangeHighMin].toFloat() * heightSquared),
            _round1(bmiRange[:orangeHighMax].toFloat() * heightSquared)
        );
    }

    function buildTargetThresholds(greenMin as Float, greenMax as Float,
        lowStepYellow as Float, lowStepOrange as Float, highStepYellow as Float, highStepOrange as Float) as Dictionary {
        return buildTargetMetricThresholds(
            _round1(greenMin),
            _round1(greenMax),
            _round1(greenMin - lowStepYellow),
            _round1(greenMin),
            _round1(greenMax),
            _round1(greenMax + highStepYellow),
            _round1(greenMin - lowStepOrange),
            _round1(greenMin - lowStepYellow),
            _round1(greenMax + highStepYellow),
            _round1(greenMax + highStepOrange)
        );
    }

    function buildTargetMetricThresholds(greenMin, greenMax, yellowLowMin, yellowLowMax,
        yellowHighMin, yellowHighMax, orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
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
            :greenMin => _round1(greenMin),
            :greenMax => _round1(greenMax),
            :yellowMin => _round1(greenMin - yellowStep),
            :orangeMin => _round1(greenMin - orangeStep)
        };
    }

    hidden function _round1(v as Float) as Float {
        return Math.round(v * 10.0).toFloat() / 10.0;
    }
}