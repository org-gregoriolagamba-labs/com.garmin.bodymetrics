import Toybox.Lang;

//! Development-only helper that checks translation completeness.
//! Compares every non-English language against English keys.
class BodyMetricsLocaleValidator {

    var _catalog as BodyMetricsLocaleCatalog;

    function initialize(catalog as BodyMetricsLocaleCatalog) {
        _catalog = catalog;
    }

    function validateAgainstEnglish() as Dictionary {
        var counts = {};
        var missingByLanguage = {};
        var totalMissing = 0;

        var languages = ["it", "fr", "es"];
        for (var i = 0; i < languages.size(); i += 1) {
            var language = languages[i] as String;
            var missing = _catalog.missingKeysComparedToEnglish(language);
            counts[language] = missing.size();
            missingByLanguage[language] = missing;
            totalMissing += missing.size();
        }

        return {
            :totalMissing => totalMissing,
            :counts => counts,
            :missingByLanguage => missingByLanguage
        };
    }
}
