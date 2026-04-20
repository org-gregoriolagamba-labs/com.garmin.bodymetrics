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
        if (key.equals("menu.info")) { return "Info"; }
        if (key.equals("menu.language")) { return "Lingua"; }
        if (key.equals("menu.data")) { return "Rilevazioni"; }
        if (key.equals("menu.badge_info")) { return "Origine Dati"; }
        if (key.equals("menu.system_info")) { return "App"; }
        if (key.equals("menu.cat.data")) { return "Dati utente"; }
        if (key.equals("menu.cat.options")) { return "Preferenze"; }
        if (key.equals("menu.cat.info")) { return "Info"; }
        if (key.equals("sysinfo.title")) { return "App"; }
        if (key.equals("sysinfo.app")) { return "Nome"; }
        if (key.equals("sysinfo.version")) { return "Versione"; }
        if (key.equals("sysinfo.release")) { return "Rilascio"; }
        if (key.equals("sysinfo.author")) { return "Team"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Genera storico"; }
        if (key.equals("debug.menu.clear_history")) { return "Azzera storico"; }
        if (key.equals("debug.menu.disable")) { return "Disattiva debug"; }
        if (key.equals("debug.menu.enable")) { return "Attiva debug"; }
        if (key.equals("data.title")) { return "Dati corpo"; }
        if (key.equals("data.select_save")) { return "SELECT  conferma"; }
        if (key.equals("data.select_next")) { return "SELECT  continua"; }
        if (key.equals("data.read_only")) { return "Valore derivato"; }
        if (key.equals("data.from_garmin")) { return "Rilevato da Garmin"; }
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
        if (key.equals("setup.edit_profile")) { return "Profilo"; }
        if (key.equals("setup.configure_profile")) { return "Nuovo profilo"; }
        if (key.equals("setup.select_save")) { return "SELECT  conferma"; }
        if (key.equals("setup.select_next")) { return "SELECT  continua"; }
        if (key.equals("detail.ideal")) { return "Zona ideale: "; }
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  dettagli"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  andamento"; }
        if (key.equals("info.section.metric")) { return "Lettura metrica"; }
        if (key.equals("info.section.ranges")) { return "Zone di equilibrio"; }
        if (key.equals("info.section.badges")) { return "Origine del dato"; }
        if (key.equals("info.range.ideal_prefix")) { return "Area ideale"; }
        if (key.equals("info.range.profile_prefix")) { return "Profilo di riferimento"; }
        if (key.equals("info.range.depends_prefix")) { return "Personalizzato su"; }
        if (key.equals("info.range.reference_prefix")) { return "Valore guida"; }
        if (key.equals("info.range.good_prefix")) { return "in armonia entro"; }
        if (key.equals("info.range.mild_prefix")) { return "da accompagnare entro"; }
        if (key.equals("info.range.unavailable")) { return "Servono piu dati per definire la tua zona di equilibrio o il valore guida della metrica."; }
        if (key.equals("info.badges.current_prefix")) { return "Origine attuale"; }
        if (key.equals("info.badges.none")) { return "non disponibile"; }
        if (key.equals("info.badges.section_metrics")) { return "Metriche derivate"; }
        if (key.equals("info.badges.G")) { return "rilevato da Garmin"; }
        if (key.equals("info.badges.M")) { return "inserito da te"; }
        if (key.equals("info.badges.CG")) { return "elaborato da dati Garmin"; }
        if (key.equals("info.badges.CM")) { return "elaborato da dati inseriti"; }
        if (key.equals("info.badges.section_inputs")) { return "Fonti di base"; }
        if (key.equals("info.badges.input_G")) { return "rilevato da Garmin"; }
        if (key.equals("info.badges.input_C")) { return "elaborato automaticamente"; }
        if (key.equals("info.factor.sex")) { return "sesso"; }
        if (key.equals("info.factor.age")) { return "eta"; }
        if (key.equals("info.factor.training")) { return "profilo allenamento"; }
        if (key.equals("info.factor.height")) { return "altezza"; }
        if (key.equals("info.factor.weight")) { return "peso"; }
        if (key.equals("info.metric.bmi.desc")) { return "Il BMI offre una lettura immediata della relazione tra peso e altezza, aiutandoti a contestualizzare il tuo equilibrio corporeo con uno sguardo semplice ma autorevole."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "La percentuale di grasso corporeo racconta come il corpo gestisce riserva energetica e composizione, offrendo una visione piu completa della sola bilancia."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "La massa muscolare espressa in chilogrammi valorizza il patrimonio contrattile del corpo e aiuta a leggere presenza, sostegno e capacita funzionale."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "La quota percentuale di muscolo sul peso totale mette in luce quanto il tuo profilo corporeo sia orientato verso tessuto attivo, tono e efficienza."; }
        if (key.equals("info.metric.water_pct.desc")) { return "L'acqua corporea totale e un indicatore chiave di idratazione e vitalita metabolica, utile per leggere quanto la composizione risulti fluida e ben bilanciata."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "La massa ossea stimata offre un riferimento strutturale della corporatura e contribuisce a restituire una lettura piu completa dell'assetto corporeo."; }
        if (key.equals("info.metric.weight.desc")) { return "Il peso corporeo e il punto di partenza della lettura wellness: acquista vero significato quando viene interpretato insieme a composizione, proporzioni e continuita nel tempo."; }
        if (key.equals("info.metric.bmr.desc")) { return "Il metabolismo basale stimato descrive quanta energia il corpo richiede a riposo, offrendo un riferimento personale per capire ritmo fisiologico e fabbisogno di base."; }
        if (key.equals("field.sex")) { return "Sesso"; }
        if (key.equals("field.age_band")) { return "Fascia anagrafica"; }
        if (key.equals("field.height")) { return "Altezza"; }
        if (key.equals("field.profile")) { return "Profilo allenamento"; }
        if (key.equals("option.sex.male")) { return "Uomo"; }
        if (key.equals("option.sex.female")) { return "Donna"; }
        if (key.equals("option.profile.general")) { return "Dati utente"; }
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
        if (key.equals("reference.prefix")) { return "Guida"; }
        if (key.equals("hint.low_only.green")) { return "Base solida"; }
        if (key.equals("hint.low_only.yellow")) { return "Da sostenere"; }
        if (key.equals("hint.low_only.orange")) { return "Sotto la zona ideale"; }
        if (key.equals("hint.low_only.red")) { return "Richiede attenzione"; }
        if (key.equals("hint.reference.green")) { return "In sintonia col profilo"; }
        if (key.equals("hint.reference.below")) { return "Sotto il valore guida"; }
        if (key.equals("hint.reference.above")) { return "Oltre il valore guida"; }
        if (key.equals("hint.target.green")) { return "In zona ideale"; }
        if (key.equals("hint.target.yellow_low")) { return "Lievemente sotto"; }
        if (key.equals("hint.target.yellow_high")) { return "Lievemente sopra"; }
        if (key.equals("hint.target.orange")) { return "Fuori dalla zona ideale"; }
        if (key.equals("hint.target.red_low")) { return "Scostamento marcato in difetto"; }
        if (key.equals("hint.target.red_high")) { return "Scostamento marcato in eccesso"; }
        if (key.equals("label.low_only.green")) { return "Solido"; }
        if (key.equals("label.low_only.yellow")) { return "Da curare"; }
        if (key.equals("label.low_only.orange")) { return "Sotto tono"; }
        if (key.equals("label.low_only.red")) { return "Molto basso"; }
        if (key.equals("label.reference.green")) { return "In sintonia"; }
        if (key.equals("label.reference.below")) { return "Sotto guida"; }
        if (key.equals("label.reference.above")) { return "Oltre guida"; }
        if (key.equals("label.target.green")) { return "Ottimale"; }
        if (key.equals("label.target.yellow_low")) { return "Un po' sotto"; }
        if (key.equals("label.target.yellow_high")) { return "Un po' sopra"; }
        if (key.equals("label.target.orange_low")) { return "Sotto zona"; }
        if (key.equals("label.target.orange_high")) { return "Sopra zona"; }
        if (key.equals("label.target.red_low")) { return "Molto basso"; }
        if (key.equals("label.target.red_high")) { return "Molto alto"; }
        if (key.equals("hint.unavailable")) { return "In attesa di dati"; }
        if (key.equals("trend.up")) { return "Tendenza in crescita"; }
        if (key.equals("trend.down")) { return "Tendenza in calo"; }
        if (key.equals("trend.flat")) { return "Andamento stabile"; }
        if (key.equals("trend.no_data")) { return "Dati insufficienti"; }
        if (key.equals("trend.last_prefix")) { return "ultimi"; }
        if (key.equals("trend.last_suffix")) { return "giorni"; }
        if (key.equals("trend.last_suffix_short")) { return "g"; }
        return key;
    }

    function textEn(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Profile"; }
        if (key.equals("menu.info")) { return "Info"; }
        if (key.equals("menu.language")) { return "Language"; }
        if (key.equals("menu.data")) { return "Check-ins"; }
        if (key.equals("menu.badge_info")) { return "Data Origin"; }
        if (key.equals("menu.system_info")) { return "App"; }
        if (key.equals("menu.cat.data")) { return "User data"; }
        if (key.equals("menu.cat.options")) { return "Preferences"; }
        if (key.equals("menu.cat.info")) { return "Info"; }
        if (key.equals("sysinfo.title")) { return "App"; }
        if (key.equals("sysinfo.app")) { return "Name"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Release"; }
        if (key.equals("sysinfo.author")) { return "Team"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Create history"; }
        if (key.equals("debug.menu.clear_history")) { return "Reset history"; }
        if (key.equals("debug.menu.disable")) { return "Turn debug off"; }
        if (key.equals("debug.menu.enable")) { return "Turn debug on"; }
        if (key.equals("data.title")) { return "Body data"; }
        if (key.equals("data.select_save")) { return "SELECT  confirm"; }
        if (key.equals("data.select_next")) { return "SELECT  continue"; }
        if (key.equals("data.read_only")) { return "Derived value"; }
        if (key.equals("data.from_garmin")) { return "Captured from Garmin"; }
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
        if (key.equals("setup.edit_profile")) { return "Profile"; }
        if (key.equals("setup.configure_profile")) { return "Create profile"; }
        if (key.equals("setup.select_save")) { return "SELECT  confirm"; }
        if (key.equals("setup.select_next")) { return "SELECT  continue"; }
        if (key.equals("detail.ideal")) { return "Ideal zone: "; }
        if (key.equals("cta.summary_info")) { return "SELECT  explore"; }
        if (key.equals("cta.info_detail")) { return "SELECT  details"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  trends"; }
        if (key.equals("info.section.metric")) { return "Metric insight"; }
        if (key.equals("info.section.ranges")) { return "Balance zones"; }
        if (key.equals("info.section.badges")) { return "Data origin"; }
        if (key.equals("info.range.ideal_prefix")) { return "Ideal zone"; }
        if (key.equals("info.range.profile_prefix")) { return "Reference profile"; }
        if (key.equals("info.range.depends_prefix")) { return "Personalized from"; }
        if (key.equals("info.range.reference_prefix")) { return "Guide value"; }
        if (key.equals("info.range.good_prefix")) { return "well aligned within"; }
        if (key.equals("info.range.mild_prefix")) { return "worth supporting within"; }
        if (key.equals("info.range.unavailable")) { return "More data is needed to define your balance zone or this metric's guide value."; }
        if (key.equals("info.badges.current_prefix")) { return "Current origin"; }
        if (key.equals("info.badges.none")) { return "not available"; }
        if (key.equals("info.badges.section_metrics")) { return "Derived metrics"; }
        if (key.equals("info.badges.G")) { return "captured from Garmin"; }
        if (key.equals("info.badges.M")) { return "entered by you"; }
        if (key.equals("info.badges.CG")) { return "derived from Garmin data"; }
        if (key.equals("info.badges.CM")) { return "derived from entered data"; }
        if (key.equals("info.badges.section_inputs")) { return "Core sources"; }
        if (key.equals("info.badges.input_G")) { return "captured from Garmin"; }
        if (key.equals("info.badges.input_C")) { return "derived automatically"; }
        if (key.equals("info.factor.sex")) { return "sex"; }
        if (key.equals("info.factor.age")) { return "age"; }
        if (key.equals("info.factor.training")) { return "training profile"; }
        if (key.equals("info.factor.height")) { return "height"; }
        if (key.equals("info.factor.weight")) { return "weight"; }
        if (key.equals("info.metric.bmi.desc")) { return "BMI offers an immediate view of how weight and height relate, helping you frame body balance through a simple, trusted wellness indicator."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Body fat percentage reveals how your body stores energy and shapes composition, giving depth and context beyond body weight alone."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "Muscle mass in kilograms highlights your body's contractile reserve, adding perspective on support, presence and overall functional potential."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "Muscle percentage shows how much of your body profile is built around active tissue, offering a clear read on tone and body efficiency."; }
        if (key.equals("info.metric.water_pct.desc")) { return "Total body water is a key marker of hydration and metabolic vitality, helping you understand how balanced and responsive your composition feels."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "Estimated bone mass provides a structural reference within your body profile and contributes to a fuller picture of overall composition."; }
        if (key.equals("info.metric.weight.desc")) { return "Body weight is the starting point of every wellness reading, yet it becomes truly meaningful when viewed alongside composition, proportion and trend over time."; }
        if (key.equals("info.metric.bmr.desc")) { return "Estimated basal metabolism describes how much energy your body uses at rest, offering a personal reference for daily rhythm and foundational energy needs."; }
        if (key.equals("field.sex")) { return "Sex"; }
        if (key.equals("field.age_band")) { return "Age range"; }
        if (key.equals("field.height")) { return "Height"; }
        if (key.equals("field.profile")) { return "Training profile"; }
        if (key.equals("option.sex.male")) { return "Male"; }
        if (key.equals("option.sex.female")) { return "Female"; }
        if (key.equals("option.profile.general")) { return "User data"; }
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
        if (key.equals("reference.prefix")) { return "Guide"; }
        if (key.equals("hint.low_only.green")) { return "Strong foundation"; }
        if (key.equals("hint.low_only.yellow")) { return "Worth supporting"; }
        if (key.equals("hint.low_only.orange")) { return "Below the ideal zone"; }
        if (key.equals("hint.low_only.red")) { return "Needs attention"; }
        if (key.equals("hint.reference.green")) { return "Aligned with your profile"; }
        if (key.equals("hint.reference.below")) { return "Below the guide value"; }
        if (key.equals("hint.reference.above")) { return "Above the guide value"; }
        if (key.equals("hint.target.green")) { return "Inside the ideal zone"; }
        if (key.equals("hint.target.yellow_low")) { return "Slightly below"; }
        if (key.equals("hint.target.yellow_high")) { return "Slightly above"; }
        if (key.equals("hint.target.orange")) { return "Outside the ideal zone"; }
        if (key.equals("hint.target.red_low")) { return "Markedly below target"; }
        if (key.equals("hint.target.red_high")) { return "Markedly above target"; }
        if (key.equals("label.low_only.green")) { return "Strong"; }
        if (key.equals("label.low_only.yellow")) { return "To support"; }
        if (key.equals("label.low_only.orange")) { return "Below tone"; }
        if (key.equals("label.low_only.red")) { return "Very low"; }
        if (key.equals("label.reference.green")) { return "In sync"; }
        if (key.equals("label.reference.below")) { return "Below guide"; }
        if (key.equals("label.reference.above")) { return "Above guide"; }
        if (key.equals("label.target.green")) { return "Optimal"; }
        if (key.equals("label.target.yellow_low")) { return "A little below"; }
        if (key.equals("label.target.yellow_high")) { return "A little above"; }
        if (key.equals("label.target.orange_low")) { return "Below zone"; }
        if (key.equals("label.target.orange_high")) { return "Above zone"; }
        if (key.equals("label.target.red_low")) { return "Very low"; }
        if (key.equals("label.target.red_high")) { return "Very high"; }
        if (key.equals("hint.unavailable")) { return "Waiting for data"; }
        if (key.equals("trend.up")) { return "Trending upward"; }
        if (key.equals("trend.down")) { return "Trending downward"; }
        if (key.equals("trend.flat")) { return "Holding steady"; }
        if (key.equals("trend.no_data")) { return "Insufficient data"; }
        if (key.equals("trend.last_prefix")) { return "last"; }
        if (key.equals("trend.last_suffix")) { return "days"; }
        if (key.equals("trend.last_suffix_short")) { return "d"; }
        return textIt(key);
    }

    function textFr(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Profil"; }
        if (key.equals("menu.info")) { return "Info"; }
        if (key.equals("menu.language")) { return "Langue"; }
        if (key.equals("menu.data")) { return "Mesures"; }
        if (key.equals("menu.badge_info")) { return "Origine Données"; }
        if (key.equals("menu.system_info")) { return "App"; }
        if (key.equals("menu.cat.data")) { return "Donnees utilisateur"; }
        if (key.equals("menu.cat.options")) { return "Preferences"; }
        if (key.equals("menu.cat.info")) { return "Info"; }
        if (key.equals("sysinfo.title")) { return "App"; }
        if (key.equals("sysinfo.app")) { return "Nom"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Edition"; }
        if (key.equals("sysinfo.author")) { return "Equipe"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Creer historique"; }
        if (key.equals("debug.menu.clear_history")) { return "Reinitialiser historique"; }
        if (key.equals("debug.menu.disable")) { return "Couper debug"; }
        if (key.equals("debug.menu.enable")) { return "Activer debug"; }
        if (key.equals("data.title")) { return "Corps"; }
        if (key.equals("data.select_save")) { return "SELECT  valider"; }
        if (key.equals("data.select_next")) { return "SELECT  continuer"; }
        if (key.equals("data.read_only")) { return "Valeur derivee"; }
        if (key.equals("data.from_garmin")) { return "Releve via Garmin"; }
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
        if (key.equals("setup.edit_profile")) { return "Profil"; }
        if (key.equals("setup.configure_profile")) { return "Creer profil"; }
        if (key.equals("setup.select_save")) { return "SELECT  valider"; }
        if (key.equals("setup.select_next")) { return "SELECT  continuer"; }
        if (key.equals("detail.ideal")) { return "Zone ideale: "; }
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  details"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  tendance"; }
        if (key.equals("info.section.metric")) { return "Lecture metrique"; }
        if (key.equals("info.section.ranges")) { return "Zones d'equilibre"; }
        if (key.equals("info.section.badges")) { return "Origine des donnees"; }
        if (key.equals("info.range.ideal_prefix")) { return "Zone ideale"; }
        if (key.equals("info.range.profile_prefix")) { return "Profil de reference"; }
        if (key.equals("info.range.depends_prefix")) { return "Personnalise selon"; }
        if (key.equals("info.range.reference_prefix")) { return "Valeur guide"; }
        if (key.equals("info.range.good_prefix")) { return "en harmonie dans"; }
        if (key.equals("info.range.mild_prefix")) { return "a accompagner dans"; }
        if (key.equals("info.range.unavailable")) { return "Des donnees supplementaires sont necessaires pour definir votre zone d'equilibre ou la valeur guide de cette metrique."; }
        if (key.equals("info.badges.current_prefix")) { return "Origine actuelle"; }
        if (key.equals("info.badges.none")) { return "non disponible"; }
        if (key.equals("info.badges.section_metrics")) { return "Metriques derivees"; }
        if (key.equals("info.badges.G")) { return "releve via Garmin"; }
        if (key.equals("info.badges.M")) { return "saisi par vous"; }
        if (key.equals("info.badges.CG")) { return "derive des donnees Garmin"; }
        if (key.equals("info.badges.CM")) { return "derive des donnees saisies"; }
        if (key.equals("info.badges.section_inputs")) { return "Sources essentielles"; }
        if (key.equals("info.badges.input_G")) { return "releve via Garmin"; }
        if (key.equals("info.badges.input_C")) { return "derive automatiquement"; }
        if (key.equals("info.factor.sex")) { return "sexe"; }
        if (key.equals("info.factor.age")) { return "age"; }
        if (key.equals("info.factor.training")) { return "profil d'entrainement"; }
        if (key.equals("info.factor.height")) { return "taille"; }
        if (key.equals("info.factor.weight")) { return "poids"; }
        if (key.equals("info.metric.bmi.desc")) { return "L'IMC offre une lecture immediate du rapport entre poids et taille, pour situer simplement l'equilibre corporel avec un repere wellness fiable."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Le pourcentage de masse grasse montre comment le corps gere ses reserves et sa composition, apportant une lecture plus riche que le poids seul."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "La masse musculaire en kilogrammes met en valeur le capital contractile du corps et eclaire sa presence fonctionnelle au quotidien."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "La part de muscle dans le poids corporel aide a comprendre a quel point votre profil privilegie tissu actif, tonicite et efficacite."; }
        if (key.equals("info.metric.water_pct.desc")) { return "L'eau corporelle totale est un repere cle d'hydratation et de vitalite metabolique, utile pour lire l'harmonie globale de la composition."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "La masse osseuse estimee apporte un repere structurel a votre profil corporel et enrichit la lecture d'ensemble de la composition."; }
        if (key.equals("info.metric.weight.desc")) { return "Le poids corporel constitue la base de la lecture wellness, mais prend toute sa valeur lorsqu'il est relie a la composition, aux proportions et a leur evolution."; }
        if (key.equals("info.metric.bmr.desc")) { return "Le metabolisme basal estime decrit l'energie utilisee par le corps au repos et offre un repere personnel sur le rythme physiologique quotidien."; }
        if (key.equals("field.sex")) { return "Sexe"; }
        if (key.equals("field.age_band")) { return "Tranche d'age"; }
        if (key.equals("field.height")) { return "Taille"; }
        if (key.equals("field.profile")) { return "Profil d'entrainement"; }
        if (key.equals("option.sex.male")) { return "Homme"; }
        if (key.equals("option.sex.female")) { return "Femme"; }
        if (key.equals("option.profile.general")) { return "Donnees utilisateur"; }
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
        if (key.equals("reference.prefix")) { return "Guide"; }
        if (key.equals("hint.low_only.green")) { return "Base solide"; }
        if (key.equals("hint.low_only.yellow")) { return "A soutenir"; }
        if (key.equals("hint.low_only.orange")) { return "Sous la zone ideale"; }
        if (key.equals("hint.low_only.red")) { return "Demande attention"; }
        if (key.equals("hint.reference.green")) { return "En harmonie avec le profil"; }
        if (key.equals("hint.reference.below")) { return "Sous la valeur guide"; }
        if (key.equals("hint.reference.above")) { return "Au-dessus de la valeur guide"; }
        if (key.equals("hint.target.green")) { return "Dans la zone ideale"; }
        if (key.equals("hint.target.yellow_low")) { return "Legerement en dessous"; }
        if (key.equals("hint.target.yellow_high")) { return "Legerement au-dessus"; }
        if (key.equals("hint.target.orange")) { return "Hors de la zone ideale"; }
        if (key.equals("hint.target.red_low")) { return "Ecart marque vers le bas"; }
        if (key.equals("hint.target.red_high")) { return "Ecart marque vers le haut"; }
        if (key.equals("label.low_only.green")) { return "Solide"; }
        if (key.equals("label.low_only.yellow")) { return "A soutenir"; }
        if (key.equals("label.low_only.orange")) { return "Sous tonus"; }
        if (key.equals("label.low_only.red")) { return "Tres bas"; }
        if (key.equals("label.reference.green")) { return "En harmonie"; }
        if (key.equals("label.reference.below")) { return "Sous guide"; }
        if (key.equals("label.reference.above")) { return "Au-dessus guide"; }
        if (key.equals("label.target.green")) { return "Optimal"; }
        if (key.equals("label.target.yellow_low")) { return "Un peu en dessous"; }
        if (key.equals("label.target.yellow_high")) { return "Un peu au-dessus"; }
        if (key.equals("label.target.orange_low")) { return "Sous zone"; }
        if (key.equals("label.target.orange_high")) { return "Au-dessus zone"; }
        if (key.equals("label.target.red_low")) { return "Tres bas"; }
        if (key.equals("label.target.red_high")) { return "Tres haut"; }
        if (key.equals("hint.unavailable")) { return "En attente de donnees"; }
        if (key.equals("trend.up")) { return "Tendance en hausse"; }
        if (key.equals("trend.down")) { return "Tendance en baisse"; }
        if (key.equals("trend.flat")) { return "Rythme stable"; }
        if (key.equals("trend.no_data")) { return "Donnees insuffisantes"; }
        if (key.equals("trend.last_prefix")) { return "derniers"; }
        if (key.equals("trend.last_suffix")) { return "jours"; }
        if (key.equals("trend.last_suffix_short")) { return "j"; }
        return textIt(key);
    }

    function textEs(key as String) as String {
        if (key.equals("menu.title")) { return "Menu"; }
        if (key.equals("menu.profile")) { return "Perfil"; }
        if (key.equals("menu.info")) { return "Info"; }
        if (key.equals("menu.language")) { return "Idioma"; }
        if (key.equals("menu.data")) { return "Registros"; }
        if (key.equals("menu.badge_info")) { return "Origen Datos"; }
        if (key.equals("menu.system_info")) { return "App"; }
        if (key.equals("menu.cat.data")) { return "Datos usuario"; }
        if (key.equals("menu.cat.options")) { return "Preferencias"; }
        if (key.equals("menu.cat.info")) { return "Info"; }
        if (key.equals("sysinfo.title")) { return "App"; }
        if (key.equals("sysinfo.app")) { return "Nombre"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Lanzamiento"; }
        if (key.equals("sysinfo.author")) { return "Equipo"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Crear historial"; }
        if (key.equals("debug.menu.clear_history")) { return "Reiniciar historial"; }
        if (key.equals("debug.menu.disable")) { return "Apagar debug"; }
        if (key.equals("debug.menu.enable")) { return "Activar debug"; }
        if (key.equals("data.title")) { return "Datos cuerpo"; }
        if (key.equals("data.select_save")) { return "SELECT  confirmar"; }
        if (key.equals("data.select_next")) { return "SELECT  continuar"; }
        if (key.equals("data.read_only")) { return "Valor derivado"; }
        if (key.equals("data.from_garmin")) { return "Registrado desde Garmin"; }
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
        if (key.equals("setup.edit_profile")) { return "Perfil"; }
        if (key.equals("setup.configure_profile")) { return "Crear perfil"; }
        if (key.equals("setup.select_save")) { return "SELECT  confirmar"; }
        if (key.equals("setup.select_next")) { return "SELECT  continuar"; }
        if (key.equals("detail.ideal")) { return "Zona ideal: "; }
        if (key.equals("cta.summary_info")) { return "SELECT  explora"; }
        if (key.equals("cta.info_detail")) { return "SELECT  detalles"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  tendencia"; }
        if (key.equals("info.section.metric")) { return "Lectura metrica"; }
        if (key.equals("info.section.ranges")) { return "Zonas de equilibrio"; }
        if (key.equals("info.section.badges")) { return "Origen del dato"; }
        if (key.equals("info.range.ideal_prefix")) { return "Zona ideal"; }
        if (key.equals("info.range.profile_prefix")) { return "Perfil de referencia"; }
        if (key.equals("info.range.depends_prefix")) { return "Personalizado segun"; }
        if (key.equals("info.range.reference_prefix")) { return "Valor guia"; }
        if (key.equals("info.range.good_prefix")) { return "en equilibrio dentro de"; }
        if (key.equals("info.range.mild_prefix")) { return "conviene acompanar dentro de"; }
        if (key.equals("info.range.unavailable")) { return "Se necesitan mas datos para definir tu zona de equilibrio o el valor guia de esta metrica."; }
        if (key.equals("info.badges.current_prefix")) { return "Origen actual"; }
        if (key.equals("info.badges.none")) { return "no disponible"; }
        if (key.equals("info.badges.section_metrics")) { return "Metricas derivadas"; }
        if (key.equals("info.badges.G")) { return "registrado desde Garmin"; }
        if (key.equals("info.badges.M")) { return "ingresado por ti"; }
        if (key.equals("info.badges.CG")) { return "derivado de datos Garmin"; }
        if (key.equals("info.badges.CM")) { return "derivado de datos ingresados"; }
        if (key.equals("info.badges.section_inputs")) { return "Fuentes clave"; }
        if (key.equals("info.badges.input_G")) { return "registrado desde Garmin"; }
        if (key.equals("info.badges.input_C")) { return "derivado automaticamente"; }
        if (key.equals("info.factor.sex")) { return "sexo"; }
        if (key.equals("info.factor.age")) { return "edad"; }
        if (key.equals("info.factor.training")) { return "perfil de entrenamiento"; }
        if (key.equals("info.factor.height")) { return "altura"; }
        if (key.equals("info.factor.weight")) { return "peso"; }
        if (key.equals("info.metric.bmi.desc")) { return "El IMC ofrece una lectura inmediata de la relacion entre peso y altura, ayudandote a situar el equilibrio corporal con una referencia wellness clara y confiable."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "El porcentaje de grasa corporal revela como el cuerpo organiza su reserva energetica y su composicion, aportando contexto mas alla del peso total."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "La masa muscular en kilogramos destaca el capital contractil del cuerpo y ayuda a interpretar soporte, presencia y capacidad funcional."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "La proporcion de musculo sobre el peso corporal muestra cuanto de tu perfil esta orientado a tejido activo, tono y eficiencia."; }
        if (key.equals("info.metric.water_pct.desc")) { return "El agua corporal total es una referencia clave de hidratacion y vitalidad metabolica, util para leer una composicion mas equilibrada y fluida."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "La masa osea estimada aporta una referencia estructural dentro del perfil corporal y completa la vision global de la composicion."; }
        if (key.equals("info.metric.weight.desc")) { return "El peso corporal es el punto de partida de toda lectura wellness, aunque cobra verdadero valor cuando se interpreta junto con composicion, proporcion y evolucion."; }
        if (key.equals("info.metric.bmr.desc")) { return "El metabolismo basal estimado describe cuanta energia utiliza tu cuerpo en reposo y ofrece una referencia personal sobre ritmo fisiologico y necesidad energetica de base."; }
        if (key.equals("field.sex")) { return "Sexo"; }
        if (key.equals("field.age_band")) { return "Rango de edad"; }
        if (key.equals("field.height")) { return "Altura"; }
        if (key.equals("field.profile")) { return "Perfil de entrenamiento"; }
        if (key.equals("option.sex.male")) { return "Hombre"; }
        if (key.equals("option.sex.female")) { return "Mujer"; }
        if (key.equals("option.profile.general")) { return "Datos usuario"; }
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
        if (key.equals("reference.prefix")) { return "Guia"; }
        if (key.equals("hint.low_only.green")) { return "Base solida"; }
        if (key.equals("hint.low_only.yellow")) { return "Conviene reforzarlo"; }
        if (key.equals("hint.low_only.orange")) { return "Por debajo de la zona ideal"; }
        if (key.equals("hint.low_only.red")) { return "Requiere atencion"; }
        if (key.equals("hint.reference.green")) { return "En sintonia con tu perfil"; }
        if (key.equals("hint.reference.below")) { return "Por debajo del valor guia"; }
        if (key.equals("hint.reference.above")) { return "Por encima del valor guia"; }
        if (key.equals("hint.target.green")) { return "Dentro de la zona ideal"; }
        if (key.equals("hint.target.yellow_low")) { return "Ligeramente por debajo"; }
        if (key.equals("hint.target.yellow_high")) { return "Ligeramente por encima"; }
        if (key.equals("hint.target.orange")) { return "Fuera de la zona ideal"; }
        if (key.equals("hint.target.red_low")) { return "Desvio marcado a la baja"; }
        if (key.equals("hint.target.red_high")) { return "Desvio marcado al alza"; }
        if (key.equals("label.low_only.green")) { return "Solido"; }
        if (key.equals("label.low_only.yellow")) { return "A reforzar"; }
        if (key.equals("label.low_only.orange")) { return "Bajo tono"; }
        if (key.equals("label.low_only.red")) { return "Muy bajo"; }
        if (key.equals("label.reference.green")) { return "En sintonia"; }
        if (key.equals("label.reference.below")) { return "Bajo guia"; }
        if (key.equals("label.reference.above")) { return "Sobre guia"; }
        if (key.equals("label.target.green")) { return "Optimo"; }
        if (key.equals("label.target.yellow_low")) { return "Un poco por debajo"; }
        if (key.equals("label.target.yellow_high")) { return "Un poco por encima"; }
        if (key.equals("label.target.orange_low")) { return "Bajo zona"; }
        if (key.equals("label.target.orange_high")) { return "Sobre zona"; }
        if (key.equals("label.target.red_low")) { return "Muy bajo"; }
        if (key.equals("label.target.red_high")) { return "Muy alto"; }
        if (key.equals("hint.unavailable")) { return "A la espera de datos"; }
        if (key.equals("trend.up")) { return "Tendencia al alza"; }
        if (key.equals("trend.down")) { return "Tendencia a la baja"; }
        if (key.equals("trend.flat")) { return "Ritmo estable"; }
        if (key.equals("trend.no_data")) { return "Datos insuficientes"; }
        if (key.equals("trend.last_prefix")) { return "ultimos"; }
        if (key.equals("trend.last_suffix")) { return "dias"; }
        if (key.equals("trend.last_suffix_short")) { return "d"; }
        return textIt(key);
    }
}