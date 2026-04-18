import Toybox.Lang;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Time.Gregorian;

const SOURCE_GARMIN = "garmin";
const SOURCE_CALC_GARMIN = "CG";  // calculated from all-Garmin inputs
const SOURCE_CALC_MANUAL = "CM";  // calculated from all-manual inputs

//! Reads user profile data from the Garmin device (UserProfile API).
//! Available on-device: weight, height, gender, birthYear.
//! NOT available: fat%, muscle%, water%, bone mass, BMR.
class BodyMetricsGarminProfile {

    function initialize() {
    }

    //! Read the Garmin user profile and return available data.
    //! Returns a Dictionary with :weight (Float, kg), :heightCm (Number),
    //! :sex (String "male"/"female"), :ageBand (String), or null values.
    function readProfile() as Dictionary {
        var profile = UserProfile.getProfile();
        return {
            :weightKg => _weightKg(profile),
            :heightCm => _heightCm(profile),
            :sex => _sex(profile),
            :ageBand => _ageBand(profile)
        };
    }

    //! Returns true if at least weight is available from Garmin profile.
    function hasWeight() as Boolean {
        var profile = UserProfile.getProfile();
        return profile.weight != null;
    }

    //! Returns true if enough data for auto-profile (height + gender + birthYear).
    function hasProfileData() as Boolean {
        var profile = UserProfile.getProfile();
        return profile.height != null && profile.gender != null && profile.birthYear != null;
    }

    //! Weight in kg (Float) or null. Garmin stores in grams.
    hidden function _weightKg(profile as UserProfile.Profile) {
        if (profile.weight != null) {
            return profile.weight.toFloat() / 1000.0;
        }
        return null;
    }

    //! Height in cm (Number) or null. Garmin stores in cm.
    hidden function _heightCm(profile as UserProfile.Profile) {
        if (profile.height != null) {
            return profile.height.toNumber();
        }
        return null;
    }

    //! Gender as "male" or "female" String, or null.
    hidden function _sex(profile as UserProfile.Profile) {
        if (profile.gender != null) {
            if (profile.gender == UserProfile.GENDER_FEMALE) {
                return "female";
            }
            return "male";
        }
        return null;
    }

    //! Derive ageBand from birthYear: "18_39", "40_59", "60_plus".
    hidden function _ageBand(profile as UserProfile.Profile) {
        if (profile.birthYear == null) {
            return null;
        }
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var currentYear = now.year.toNumber();
        var age = currentYear - profile.birthYear.toNumber();
        if (age < 40) {
            return "18_39";
        }
        if (age < 60) {
            return "40_59";
        }
        return "60_plus";
    }
}
