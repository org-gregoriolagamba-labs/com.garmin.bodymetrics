import Toybox.Application.Storage;
import Toybox.Lang;

const LANGUAGE_KEY = "bodyMetrics.language";

class BodyMetricsLocale {

    var _cachedLanguage as String;

    function initialize() {
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
        if (language.equals("en")) {
            return textEn(key);
        }
        if (language.equals("fr")) {
            return textFr(key);
        }
        if (language.equals("es")) {
            return textEs(key);
        }
        return textIt(key);
    }

    function textIt(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Profilo"; }
        if (key.equals("menu.language")) { return "Lingua"; }
        if (key.equals("menu.data")) { return "Inserisci dati"; }
        if (key.equals("data.title")) { return "Dati corporei"; }
        if (key.equals("data.select_save")) { return "SELECT  salva"; }
        if (key.equals("data.select_next")) { return "SELECT  avanti"; }
        if (key.equals("data.read_only")) { return "Valore calcolato"; }
        if (key.equals("data.from_garmin")) { return "Da Garmin"; }
        if (key.equals("data.badge_auto")) { return "C"; }
        if (key.equals("data.badge_garmin")) { return "G"; }
        if (key.equals("data.weight")) { return "Peso"; }
        if (key.equals("data.fat_pct")) { return "Grasso %"; }
        if (key.equals("data.muscle_pct")) { return "Muscoli %"; }
        if (key.equals("data.water_pct")) { return "Idratazione %"; }
        if (key.equals("data.bone_kg")) { return "Massa ossea"; }
        if (key.equals("data.bmr")) { return "BMR"; }
        if (key.equals("language.it")) { return "Italiano"; }
        if (key.equals("language.en")) { return "English"; }
        if (key.equals("language.fr")) { return "Francais"; }
        if (key.equals("language.es")) { return "Espanol"; }
        if (key.equals("setup.edit_profile")) { return "Modifica profilo"; }
        if (key.equals("setup.configure_profile")) { return "Configura profilo"; }
        if (key.equals("setup.select_save")) { return "SELECT  salva"; }
        if (key.equals("setup.select_next")) { return "SELECT  avanti"; }
        if (key.equals("detail.ideal")) { return "Ideale: "; }
        if (key.equals("field.sex")) { return "Sesso"; }
        if (key.equals("field.age_band")) { return "Fascia eta"; }
        if (key.equals("field.height")) { return "Altezza"; }
        if (key.equals("field.profile")) { return "Profilo allenamento"; }
        if (key.equals("option.sex.male")) { return "Uomo"; }
        if (key.equals("option.sex.female")) { return "Donna"; }
        if (key.equals("option.profile.general")) { return "Standard"; }
        if (key.equals("option.profile.endurance")) { return "Resistenza"; }
        if (key.equals("option.profile.strength")) { return "Forza"; }
        if (key.equals("metric.bmi")) { return "BMI"; }
        if (key.equals("metric.fat_pct")) { return "Grasso %"; }
        if (key.equals("metric.muscle_kg")) { return "Massa muscolare"; }
        if (key.equals("metric.muscle_pct")) { return "Muscoli %"; }
        if (key.equals("metric.water_pct")) { return "Idratazione"; }
        if (key.equals("metric.bone_kg")) { return "Massa ossea"; }
        if (key.equals("metric.weight")) { return "Peso"; }
        if (key.equals("metric.bmr")) { return "BMR"; }
        if (key.equals("reference.prefix")) { return "Rif"; }
        if (key.equals("hint.low_only.green")) { return "Livello adeguato"; }
        if (key.equals("hint.low_only.yellow")) { return "Da consolidare"; }
        if (key.equals("hint.low_only.orange")) { return "Sotto soglia"; }
        if (key.equals("hint.low_only.red")) { return "Recupero prioritario"; }
        if (key.equals("hint.high_only.green")) { return "Valore gestito"; }
        if (key.equals("hint.high_only.yellow")) { return "Attenzione"; }
        if (key.equals("hint.high_only.orange")) { return "Oltre soglia"; }
        if (key.equals("hint.high_only.red")) { return "Ridurre presto"; }
        if (key.equals("hint.reference.green")) { return "Coerente col profilo"; }
        if (key.equals("hint.reference.below")) { return "Sotto il riferimento"; }
        if (key.equals("hint.reference.above")) { return "Sopra il riferimento"; }
        if (key.equals("hint.target.green")) { return "Nel range"; }
        if (key.equals("hint.target.yellow_low")) { return "Poco basso"; }
        if (key.equals("hint.target.yellow_high")) { return "Poco alto"; }
        if (key.equals("hint.target.orange")) { return "Fuori range"; }
        if (key.equals("hint.target.red_low")) { return "Deficit marcato"; }
        if (key.equals("hint.target.red_high")) { return "Eccesso marcato"; }
        if (key.equals("label.low_only.green")) { return "Adeguato"; }
        if (key.equals("label.low_only.yellow")) { return "Al limite"; }
        if (key.equals("label.low_only.orange")) { return "Basso"; }
        if (key.equals("label.low_only.red")) { return "Molto basso"; }
        if (key.equals("label.high_only.green")) { return "Adeguato"; }
        if (key.equals("label.high_only.yellow")) { return "Da monitorare"; }
        if (key.equals("label.high_only.orange")) { return "Alto"; }
        if (key.equals("label.high_only.red")) { return "Molto alto"; }
        if (key.equals("label.reference.green")) { return "In linea"; }
        if (key.equals("label.reference.below")) { return "Sotto rif."; }
        if (key.equals("label.reference.above")) { return "Sopra rif."; }
        if (key.equals("label.target.green")) { return "Ottimale"; }
        if (key.equals("label.target.yellow_low")) { return "Legg. basso"; }
        if (key.equals("label.target.yellow_high")) { return "Legg. alto"; }
        if (key.equals("label.target.orange_low")) { return "Basso"; }
        if (key.equals("label.target.orange_high")) { return "Alto"; }
        if (key.equals("label.target.red_low")) { return "Molto basso"; }
        if (key.equals("label.target.red_high")) { return "Molto alto"; }
        if (key.equals("hint.unavailable")) { return "Non disponibile"; }
        if (key.equals("trend.up")) { return "In aumento"; }
        if (key.equals("trend.down")) { return "In calo"; }
        if (key.equals("trend.flat")) { return "Stabile"; }
        if (key.equals("trend.no_data")) { return "Dati insufficienti"; }
        if (key.equals("trend.last_prefix")) { return "ultimi"; }
        if (key.equals("trend.last_suffix")) { return "giorni"; }
        if (key.equals("trend.last_suffix_short")) { return "g"; }
        return key;
    }

    function textEn(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Profile"; }
        if (key.equals("menu.language")) { return "Language"; }
        if (key.equals("menu.data")) { return "Enter data"; }
        if (key.equals("data.title")) { return "Body data"; }
        if (key.equals("data.select_save")) { return "SELECT  save"; }
        if (key.equals("data.select_next")) { return "SELECT  next"; }
        if (key.equals("data.read_only")) { return "Calculated"; }
        if (key.equals("data.from_garmin")) { return "From Garmin"; }
        if (key.equals("data.badge_auto")) { return "C"; }
        if (key.equals("data.badge_garmin")) { return "G"; }
        if (key.equals("data.weight")) { return "Weight"; }
        if (key.equals("data.fat_pct")) { return "Body fat %"; }
        if (key.equals("data.muscle_pct")) { return "Muscle %"; }
        if (key.equals("data.water_pct")) { return "Hydration %"; }
        if (key.equals("data.bone_kg")) { return "Bone mass"; }
        if (key.equals("data.bmr")) { return "BMR"; }
        if (key.equals("language.it")) { return "Italiano"; }
        if (key.equals("language.en")) { return "English"; }
        if (key.equals("language.fr")) { return "Francais"; }
        if (key.equals("language.es")) { return "Espanol"; }
        if (key.equals("setup.edit_profile")) { return "Edit profile"; }
        if (key.equals("setup.configure_profile")) { return "Set up profile"; }
        if (key.equals("setup.select_save")) { return "SELECT  save"; }
        if (key.equals("setup.select_next")) { return "SELECT  next"; }
        if (key.equals("detail.ideal")) { return "Ideal: "; }
        if (key.equals("field.sex")) { return "Sex"; }
        if (key.equals("field.age_band")) { return "Age band"; }
        if (key.equals("field.height")) { return "Height"; }
        if (key.equals("field.profile")) { return "Training profile"; }
        if (key.equals("option.sex.male")) { return "Male"; }
        if (key.equals("option.sex.female")) { return "Female"; }
        if (key.equals("option.profile.general")) { return "Standard"; }
        if (key.equals("option.profile.endurance")) { return "Endurance"; }
        if (key.equals("option.profile.strength")) { return "Strength"; }
        if (key.equals("metric.bmi")) { return "BMI"; }
        if (key.equals("metric.fat_pct")) { return "Body fat %"; }
        if (key.equals("metric.muscle_kg")) { return "Muscle mass"; }
        if (key.equals("metric.muscle_pct")) { return "Muscle %"; }
        if (key.equals("metric.water_pct")) { return "Hydration"; }
        if (key.equals("metric.bone_kg")) { return "Bone mass"; }
        if (key.equals("metric.weight")) { return "Weight"; }
        if (key.equals("metric.bmr")) { return "BMR"; }
        if (key.equals("reference.prefix")) { return "Ref"; }
        if (key.equals("hint.low_only.green")) { return "Adequate"; }
        if (key.equals("hint.low_only.yellow")) { return "Build up"; }
        if (key.equals("hint.low_only.orange")) { return "Below thr."; }
        if (key.equals("hint.low_only.red")) { return "Priority"; }
        if (key.equals("hint.high_only.green")) { return "Managed"; }
        if (key.equals("hint.high_only.yellow")) { return "Attention"; }
        if (key.equals("hint.high_only.orange")) { return "Over thr."; }
        if (key.equals("hint.high_only.red")) { return "Reduce"; }
        if (key.equals("hint.reference.green")) { return "Aligned"; }
        if (key.equals("hint.reference.below")) { return "Below ref."; }
        if (key.equals("hint.reference.above")) { return "Above ref."; }
        if (key.equals("hint.target.green")) { return "In range"; }
        if (key.equals("hint.target.yellow_low")) { return "Slightly low"; }
        if (key.equals("hint.target.yellow_high")) { return "Slightly high"; }
        if (key.equals("hint.target.orange")) { return "Out of range"; }
        if (key.equals("hint.target.red_low")) { return "Deficit"; }
        if (key.equals("hint.target.red_high")) { return "Excess"; }
        if (key.equals("label.low_only.green")) { return "Adequate"; }
        if (key.equals("label.low_only.yellow")) { return "Borderline"; }
        if (key.equals("label.low_only.orange")) { return "Low"; }
        if (key.equals("label.low_only.red")) { return "Very low"; }
        if (key.equals("label.high_only.green")) { return "Adequate"; }
        if (key.equals("label.high_only.yellow")) { return "Watch"; }
        if (key.equals("label.high_only.orange")) { return "High"; }
        if (key.equals("label.high_only.red")) { return "Very high"; }
        if (key.equals("label.reference.green")) { return "Aligned"; }
        if (key.equals("label.reference.below")) { return "Below ref."; }
        if (key.equals("label.reference.above")) { return "Above ref."; }
        if (key.equals("label.target.green")) { return "Optimal"; }
        if (key.equals("label.target.yellow_low")) { return "Slightly low"; }
        if (key.equals("label.target.yellow_high")) { return "Slightly high"; }
        if (key.equals("label.target.orange_low")) { return "Low"; }
        if (key.equals("label.target.orange_high")) { return "High"; }
        if (key.equals("label.target.red_low")) { return "Very low"; }
        if (key.equals("label.target.red_high")) { return "Very high"; }
        if (key.equals("hint.unavailable")) { return "Not available"; }
        if (key.equals("trend.up")) { return "Rising"; }
        if (key.equals("trend.down")) { return "Declining"; }
        if (key.equals("trend.flat")) { return "Stable"; }
        if (key.equals("trend.no_data")) { return "Not enough data"; }
        if (key.equals("trend.last_prefix")) { return "last"; }
        if (key.equals("trend.last_suffix")) { return "days"; }
        if (key.equals("trend.last_suffix_short")) { return "d"; }
        return textIt(key);
    }

    function textFr(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Profil"; }
        if (key.equals("menu.language")) { return "Langue"; }
        if (key.equals("menu.data")) { return "Saisir donnees"; }
        if (key.equals("data.title")) { return "Donnees corp."; }
        if (key.equals("data.select_save")) { return "SELECT  sauv."; }
        if (key.equals("data.select_next")) { return "SELECT  suite"; }
        if (key.equals("data.read_only")) { return "Valeur calculee"; }
        if (key.equals("data.from_garmin")) { return "Depuis Garmin"; }
        if (key.equals("data.badge_auto")) { return "C"; }
        if (key.equals("data.badge_garmin")) { return "G"; }
        if (key.equals("data.weight")) { return "Poids"; }
        if (key.equals("data.fat_pct")) { return "Graisse %"; }
        if (key.equals("data.muscle_pct")) { return "Muscles %"; }
        if (key.equals("data.water_pct")) { return "Hydratation %"; }
        if (key.equals("data.bone_kg")) { return "Masse osseuse"; }
        if (key.equals("data.bmr")) { return "BMR"; }
        if (key.equals("language.it")) { return "Italiano"; }
        if (key.equals("language.en")) { return "English"; }
        if (key.equals("language.fr")) { return "Francais"; }
        if (key.equals("language.es")) { return "Espanol"; }
        if (key.equals("setup.edit_profile")) { return "Modifier profil"; }
        if (key.equals("setup.configure_profile")) { return "Configurer profil"; }
        if (key.equals("setup.select_save")) { return "SELECT  sauv."; }
        if (key.equals("setup.select_next")) { return "SELECT  suite"; }
        if (key.equals("detail.ideal")) { return "Cible: "; }
        if (key.equals("field.sex")) { return "Sexe"; }
        if (key.equals("field.age_band")) { return "Age"; }
        if (key.equals("field.height")) { return "Taille"; }
        if (key.equals("field.profile")) { return "Profil d'entrainement"; }
        if (key.equals("option.sex.male")) { return "Homme"; }
        if (key.equals("option.sex.female")) { return "Femme"; }
        if (key.equals("option.profile.general")) { return "Standard"; }
        if (key.equals("option.profile.endurance")) { return "Endurance"; }
        if (key.equals("option.profile.strength")) { return "Force"; }
        if (key.equals("metric.bmi")) { return "IMC"; }
        if (key.equals("metric.fat_pct")) { return "Graisse %"; }
        if (key.equals("metric.muscle_kg")) { return "Masse muscl."; }
        if (key.equals("metric.muscle_pct")) { return "Muscles %"; }
        if (key.equals("metric.water_pct")) { return "Hydratation"; }
        if (key.equals("metric.bone_kg")) { return "Masse osseuse"; }
        if (key.equals("metric.weight")) { return "Poids"; }
        if (key.equals("metric.bmr")) { return "BMR"; }
        if (key.equals("reference.prefix")) { return "Ref"; }
        if (key.equals("hint.low_only.green")) { return "Adequat"; }
        if (key.equals("hint.low_only.yellow")) { return "A renforcer"; }
        if (key.equals("hint.low_only.orange")) { return "Sous seuil"; }
        if (key.equals("hint.low_only.red")) { return "Prioritaire"; }
        if (key.equals("hint.high_only.green")) { return "Maitrise"; }
        if (key.equals("hint.high_only.yellow")) { return "Attention"; }
        if (key.equals("hint.high_only.orange")) { return "Au-dessus"; }
        if (key.equals("hint.high_only.red")) { return "A reduire"; }
        if (key.equals("hint.reference.green")) { return "Coherent"; }
        if (key.equals("hint.reference.below")) { return "Sous ref."; }
        if (key.equals("hint.reference.above")) { return "Au-dessus ref."; }
        if (key.equals("hint.target.green")) { return "Dans la cible"; }
        if (key.equals("hint.target.yellow_low")) { return "Legerement bas"; }
        if (key.equals("hint.target.yellow_high")) { return "Legerement haut"; }
        if (key.equals("hint.target.orange")) { return "Hors plage"; }
        if (key.equals("hint.target.red_low")) { return "Deficit net"; }
        if (key.equals("hint.target.red_high")) { return "Exces net"; }
        if (key.equals("label.low_only.green")) { return "Adequat"; }
        if (key.equals("label.low_only.yellow")) { return "Limite"; }
        if (key.equals("label.low_only.orange")) { return "Bas"; }
        if (key.equals("label.low_only.red")) { return "Tres bas"; }
        if (key.equals("label.high_only.green")) { return "Adequat"; }
        if (key.equals("label.high_only.yellow")) { return "A suivre"; }
        if (key.equals("label.high_only.orange")) { return "Haut"; }
        if (key.equals("label.high_only.red")) { return "Tres haut"; }
        if (key.equals("label.reference.green")) { return "Conforme"; }
        if (key.equals("label.reference.below")) { return "Sous ref."; }
        if (key.equals("label.reference.above")) { return "Sur ref."; }
        if (key.equals("label.target.green")) { return "Optimal"; }
        if (key.equals("label.target.yellow_low")) { return "Leger bas"; }
        if (key.equals("label.target.yellow_high")) { return "Leger haut"; }
        if (key.equals("label.target.orange_low")) { return "Bas"; }
        if (key.equals("label.target.orange_high")) { return "Haut"; }
        if (key.equals("label.target.red_low")) { return "Tres bas"; }
        if (key.equals("label.target.red_high")) { return "Tres haut"; }
        if (key.equals("hint.unavailable")) { return "Non disponible"; }
        if (key.equals("trend.up")) { return "En hausse"; }
        if (key.equals("trend.down")) { return "En baisse"; }
        if (key.equals("trend.flat")) { return "Stable"; }
        if (key.equals("trend.no_data")) { return "Donnees insuff."; }
        if (key.equals("trend.last_prefix")) { return "derniers"; }
        if (key.equals("trend.last_suffix")) { return "jours"; }
        if (key.equals("trend.last_suffix_short")) { return "j"; }
        return textIt(key);
    }

    function textEs(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Perfil"; }
        if (key.equals("menu.language")) { return "Idioma"; }
        if (key.equals("menu.data")) { return "Ingresar datos"; }
        if (key.equals("data.title")) { return "Datos corporales"; }
        if (key.equals("data.select_save")) { return "SELECT  guardar"; }
        if (key.equals("data.select_next")) { return "SELECT  seguir"; }
        if (key.equals("data.read_only")) { return "Valor calculado"; }
        if (key.equals("data.from_garmin")) { return "Desde Garmin"; }
        if (key.equals("data.badge_auto")) { return "C"; }
        if (key.equals("data.badge_garmin")) { return "G"; }
        if (key.equals("data.weight")) { return "Peso"; }
        if (key.equals("data.fat_pct")) { return "Grasa %"; }
        if (key.equals("data.muscle_pct")) { return "Musculos %"; }
        if (key.equals("data.water_pct")) { return "Hidratacion %"; }
        if (key.equals("data.bone_kg")) { return "Masa osea"; }
        if (key.equals("data.bmr")) { return "BMR"; }
        if (key.equals("language.it")) { return "Italiano"; }
        if (key.equals("language.en")) { return "English"; }
        if (key.equals("language.fr")) { return "Francais"; }
        if (key.equals("language.es")) { return "Espanol"; }
        if (key.equals("setup.edit_profile")) { return "Editar perfil"; }
        if (key.equals("setup.configure_profile")) { return "Configurar perfil"; }
        if (key.equals("setup.select_save")) { return "SELECT  guardar"; }
        if (key.equals("setup.select_next")) { return "SELECT  seguir"; }
        if (key.equals("detail.ideal")) { return "Ideal: "; }
        if (key.equals("field.sex")) { return "Sexo"; }
        if (key.equals("field.age_band")) { return "Edad"; }
        if (key.equals("field.height")) { return "Altura"; }
        if (key.equals("field.profile")) { return "Perfil de entrenamiento"; }
        if (key.equals("option.sex.male")) { return "Hombre"; }
        if (key.equals("option.sex.female")) { return "Mujer"; }
        if (key.equals("option.profile.general")) { return "Estandar"; }
        if (key.equals("option.profile.endurance")) { return "Resistencia"; }
        if (key.equals("option.profile.strength")) { return "Fuerza"; }
        if (key.equals("metric.bmi")) { return "IMC"; }
        if (key.equals("metric.fat_pct")) { return "Grasa %"; }
        if (key.equals("metric.muscle_kg")) { return "Masa musc."; }
        if (key.equals("metric.muscle_pct")) { return "Musculos %"; }
        if (key.equals("metric.water_pct")) { return "Hidratacion"; }
        if (key.equals("metric.bone_kg")) { return "Masa osea"; }
        if (key.equals("metric.weight")) { return "Peso"; }
        if (key.equals("metric.bmr")) { return "BMR"; }
        if (key.equals("reference.prefix")) { return "Ref"; }
        if (key.equals("hint.low_only.green")) { return "Nivel adecuado"; }
        if (key.equals("hint.low_only.yellow")) { return "Por reforzar"; }
        if (key.equals("hint.low_only.orange")) { return "Bajo umbral"; }
        if (key.equals("hint.low_only.red")) { return "Muy priorit."; }
        if (key.equals("hint.high_only.green")) { return "Controlado"; }
        if (key.equals("hint.high_only.yellow")) { return "Atencion"; }
        if (key.equals("hint.high_only.orange")) { return "Por encima"; }
        if (key.equals("hint.high_only.red")) { return "Reducir ya"; }
        if (key.equals("hint.reference.green")) { return "Coherente"; }
        if (key.equals("hint.reference.below")) { return "Bajo ref."; }
        if (key.equals("hint.reference.above")) { return "Sobre la ref."; }
        if (key.equals("hint.target.green")) { return "En rango"; }
        if (key.equals("hint.target.yellow_low")) { return "Ligeram. bajo"; }
        if (key.equals("hint.target.yellow_high")) { return "Ligeram. alto"; }
        if (key.equals("hint.target.orange")) { return "Fuera de rango"; }
        if (key.equals("hint.target.red_low")) { return "Deficit claro"; }
        if (key.equals("hint.target.red_high")) { return "Exceso claro"; }
        if (key.equals("label.low_only.green")) { return "Adecuado"; }
        if (key.equals("label.low_only.yellow")) { return "Al limite"; }
        if (key.equals("label.low_only.orange")) { return "Bajo"; }
        if (key.equals("label.low_only.red")) { return "Muy bajo"; }
        if (key.equals("label.high_only.green")) { return "Adecuado"; }
        if (key.equals("label.high_only.yellow")) { return "Controlar"; }
        if (key.equals("label.high_only.orange")) { return "Alto"; }
        if (key.equals("label.high_only.red")) { return "Muy alto"; }
        if (key.equals("label.reference.green")) { return "Correcto"; }
        if (key.equals("label.reference.below")) { return "Bajo ref."; }
        if (key.equals("label.reference.above")) { return "Sobre ref."; }
        if (key.equals("label.target.green")) { return "Optimo"; }
        if (key.equals("label.target.yellow_low")) { return "Algo bajo"; }
        if (key.equals("label.target.yellow_high")) { return "Algo alto"; }
        if (key.equals("label.target.orange_low")) { return "Bajo"; }
        if (key.equals("label.target.orange_high")) { return "Alto"; }
        if (key.equals("label.target.red_low")) { return "Muy bajo"; }
        if (key.equals("label.target.red_high")) { return "Muy alto"; }
        if (key.equals("hint.unavailable")) { return "No disponible"; }
        if (key.equals("trend.up")) { return "En aumento"; }
        if (key.equals("trend.down")) { return "En descenso"; }
        if (key.equals("trend.flat")) { return "Estable"; }
        if (key.equals("trend.no_data")) { return "Datos insuf."; }
        if (key.equals("trend.last_prefix")) { return "ultimos"; }
        if (key.equals("trend.last_suffix")) { return "dias"; }
        if (key.equals("trend.last_suffix_short")) { return "d"; }
        return textIt(key);
    }
}