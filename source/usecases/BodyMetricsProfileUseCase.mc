import Toybox.Application.Storage;
import Toybox.Lang;

const PROFILE_SEX_STORAGE_KEY = "bodyMetrics.profile.sex";
const PROFILE_AGE_BAND_STORAGE_KEY = "bodyMetrics.profile.ageBand";
const PROFILE_BODY_PROFILE_STORAGE_KEY = "bodyMetrics.profile.bodyProfile";
const PROFILE_HEIGHT_STORAGE_KEY = "bodyMetrics.profile.heightCm";

//! Orchestrates profile persistence and setup-screen field behavior.
class BodyMetricsProfileUseCase {

    var _locale;
    var _garminProfile;

    function initialize(locale, garminProfile) {
        _locale = locale;
        _garminProfile = garminProfile;
    }

    function defaultProfile() as Dictionary {
        var garmin = _garminProfile.readProfile() as Dictionary;
        return {
            :sex => garmin[:sex] != null ? garmin[:sex] : "male",
            :ageBand => garmin[:ageBand] != null ? garmin[:ageBand] : "40_59",
            :bodyProfile => "general",
            :heightCm => garmin[:heightCm] != null ? garmin[:heightCm] : 178
        };
    }

    function mergedProfileValues() as Dictionary {
        var garmin = _garminProfile.readProfile() as Dictionary;
        var storedSex = Storage.getValue(PROFILE_SEX_STORAGE_KEY);
        var storedAgeBand = Storage.getValue(PROFILE_AGE_BAND_STORAGE_KEY);
        var storedBodyProfile = Storage.getValue(PROFILE_BODY_PROFILE_STORAGE_KEY);
        var storedHeightCm = Storage.getValue(PROFILE_HEIGHT_STORAGE_KEY);

        return {
            :sex => garmin[:sex] != null ? garmin[:sex] : storedSex,
            :ageBand => garmin[:ageBand] != null ? garmin[:ageBand] : storedAgeBand,
            :bodyProfile => storedBodyProfile,
            :heightCm => garmin[:heightCm] != null ? garmin[:heightCm] : storedHeightCm
        };
    }

    function loadProfile() as Dictionary {
        return {
            :profile => sanitizeProfile(mergedProfileValues()),
            :hasStoredProfile => Storage.getValue(PROFILE_BODY_PROFILE_STORAGE_KEY) != null
        };
    }

    function sanitizeProfile(profile as Dictionary) as Dictionary {
        var defaults = defaultProfile();
        return {
            :sex => (profile.hasKey(:sex) && profile[:sex] != null) ? profile[:sex] : defaults[:sex],
            :ageBand => (profile.hasKey(:ageBand) && profile[:ageBand] != null) ? profile[:ageBand] : defaults[:ageBand],
            :bodyProfile => (profile.hasKey(:bodyProfile) && profile[:bodyProfile] != null) ? profile[:bodyProfile] : defaults[:bodyProfile],
            :heightCm => (profile.hasKey(:heightCm) && profile[:heightCm] != null) ? profile[:heightCm] : defaults[:heightCm]
        };
    }

    function currentProfile(profile as Dictionary) as Dictionary {
        var current = sanitizeProfile(profile);
        if (Storage.getValue(PROFILE_BODY_PROFILE_STORAGE_KEY) == null) {
            current[:bodyProfile] = null;
        }
        return current;
    }

    function hasConfiguredProfile() as Boolean {
        return Storage.getValue(PROFILE_BODY_PROFILE_STORAGE_KEY) != null;
    }

    function saveProfile(profile as Dictionary) as Dictionary {
        var sanitized = sanitizeProfile(profile);
        Storage.setValue(PROFILE_SEX_STORAGE_KEY, sanitized[:sex].toString());
        Storage.setValue(PROFILE_AGE_BAND_STORAGE_KEY, sanitized[:ageBand].toString());
        Storage.setValue(PROFILE_BODY_PROFILE_STORAGE_KEY, sanitized[:bodyProfile].toString());
        Storage.setValue(PROFILE_HEIGHT_STORAGE_KEY, sanitized[:heightCm].toNumber());
        return sanitized;
    }

    function clearStoredProfile() as Void {
        Storage.deleteValue(PROFILE_SEX_STORAGE_KEY);
        Storage.deleteValue(PROFILE_AGE_BAND_STORAGE_KEY);
        Storage.deleteValue(PROFILE_BODY_PROFILE_STORAGE_KEY);
        Storage.deleteValue(PROFILE_HEIGHT_STORAGE_KEY);
    }

    function profileFields() as Array {
        var garmin = _garminProfile.readProfile() as Dictionary;
        return [
            {
                :key => :sex,
                :label => _locale.text("field.sex"),
                :type => "option",
                :values => ["male", "female"],
                :labels => [_locale.text("option.sex.male"), _locale.text("option.sex.female")],
                :readOnly => garmin[:sex] != null,
                :readOnlyText => _locale.text("data.from_garmin"),
                :badgeText => _locale.text("data.badge_garmin")
            },
            {
                :key => :ageBand,
                :label => _locale.text("field.age_band"),
                :type => "option",
                :values => ["18_39", "40_59", "60_plus"],
                :labels => ["18-39", "40-59", "60+"],
                :readOnly => garmin[:ageBand] != null,
                :readOnlyText => _locale.text("data.from_garmin"),
                :badgeText => _locale.text("data.badge_garmin")
            },
            {
                :key => :heightCm,
                :label => _locale.text("field.height"),
                :type => "number",
                :min => 150,
                :max => 210,
                :step => 1,
                :readOnly => garmin[:heightCm] != null,
                :readOnlyText => _locale.text("data.from_garmin"),
                :badgeText => _locale.text("data.badge_garmin")
            },
            {
                :key => :bodyProfile,
                :label => _locale.text("field.profile"),
                :type => "option",
                :values => ["general", "endurance", "strength"],
                :labels => [_locale.text("option.profile.general"), _locale.text("option.profile.endurance"), _locale.text("option.profile.strength")]
            }
        ];
    }

    function profileFieldCount() as Number {
        return 4; // sex, ageBand, heightCm, bodyProfile — fixed structure
    }

    function profileFieldDefinition(index as Number) as Dictionary {
        return profileFields()[index] as Dictionary;
    }

    function cycleProfileField(profile as Dictionary, index as Number, delta as Number) as Dictionary {
        var nextProfile = sanitizeProfile(profile);
        var field = profileFieldDefinition(index);
        if (field.hasKey(:readOnly) && field[:readOnly]) {
            return nextProfile;
        }

        var key = field[:key];
        if (key == :bodyProfile && (!profile.hasKey(:bodyProfile) || profile[:bodyProfile] == null)) {
            nextProfile[:bodyProfile] = null;
        }

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
        var currentIndex = (key == :bodyProfile && nextProfile[key] == null) ? -1 : 0;
        for (var i = 0; i < values.size(); i += 1) {
            if (nextProfile[key] != null && values[i].equals(nextProfile[key])) {
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

        if (key == :bodyProfile && (!profile.hasKey(:bodyProfile) || profile[:bodyProfile] == null)) {
            return "N/A";
        }

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
}