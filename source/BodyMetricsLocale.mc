import Toybox.Application.Storage;
import Toybox.Lang;

const LANGUAGE_KEY = "bodyMetrics.language";

class BodyMetricsLocale {

    var _cachedLanguage as String;
    var _catalog as BodyMetricsLocaleCatalog;

    function initialize() {
        _catalog = new BodyMetricsLocaleCatalog();
        _cachedLanguage = _resolveLanguage();
    }

    function currentLanguage() as String {
        return _cachedLanguage;
    }

    //! Resolves language from Storage, falling back to Italian.
    hidden function _resolveLanguage() as String {
        var language = Storage.getValue(LANGUAGE_KEY);
        if (language != null) {
            var code = language.toString();
            if (isSupported(code)) {
                return code;
            }
        }
        return "it";
    }

    function setLanguage(language as String) as Void {
        var code = isSupported(language) ? language : "it";
        Storage.setValue(LANGUAGE_KEY, code);
        _cachedLanguage = code;
    }

    function supportedLanguages() as Array {
        return ["it", "en", "fr", "es"];
    }

    function isSupported(language as String) as Boolean {
        return language.equals("it") || language.equals("en") || language.equals("fr") || language.equals("es");
    }

    function languageLabel(language as String) as String {
        if (language.equals("en")) {
            return text("language.en");
        }
        if (language.equals("fr")) {
            return text("language.fr");
        }
        if (language.equals("es")) {
            return text("language.es");
        }
        return text("language.it");
    }

    function metricLabel(metricId as String) as String {
        return text("metric." + metricId);
    }

    function text(key as String) as String {
        var language = currentLanguage();
        var mapped = _catalog.text(language, key);
        if (mapped != null) {
            return mapped as String;
        }

        var english = _catalog.text("en", key);
        if (english != null) {
            return english as String;
        }

        return key;
    }

    //! Development helper: returns missing-key report against English.
    function validateCatalogMissingKeys() as Dictionary {
        var validator = new BodyMetricsLocaleValidator(_catalog);
        return validator.validateAgainstEnglish();
    }
}
