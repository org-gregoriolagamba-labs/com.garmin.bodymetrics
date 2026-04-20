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
        if (key.equals("menu.info")) { return "Info metrica"; }
        if (key.equals("menu.language")) { return "Lingua"; }
        if (key.equals("menu.data")) { return "Inserisci dati"; }
        if (key.equals("menu.badge_info")) { return "Badge info"; }
        if (key.equals("menu.system_info")) { return "Info sistema"; }
        if (key.equals("menu.cat.data")) { return "Dati"; }
        if (key.equals("menu.cat.options")) { return "Opzioni"; }
        if (key.equals("menu.cat.info")) { return "Informazioni"; }
        if (key.equals("sysinfo.title")) { return "Info sistema"; }
        if (key.equals("sysinfo.app")) { return "App"; }
        if (key.equals("sysinfo.version")) { return "Versione"; }
        if (key.equals("sysinfo.release")) { return "Release"; }
        if (key.equals("sysinfo.author")) { return "Autore"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Popola storico"; }
        if (key.equals("debug.menu.clear_history")) { return "Cancella storico"; }
        if (key.equals("debug.menu.disable")) { return "Disabilita debug"; }
        if (key.equals("debug.menu.enable")) { return "Abilita debug"; }
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
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  dettaglio"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  trend"; }
        if (key.equals("info.section.metric")) { return "Metrica"; }
        if (key.equals("info.section.ranges")) { return "Fasce e riferimenti"; }
        if (key.equals("info.section.badges")) { return "Legenda badge"; }
        if (key.equals("info.range.ideal_prefix")) { return "Fascia ideale"; }
        if (key.equals("info.range.profile_prefix")) { return "Profilo attivo"; }
        if (key.equals("info.range.depends_prefix")) { return "Dipende da"; }
        if (key.equals("info.range.reference_prefix")) { return "Rif. attivo"; }
        if (key.equals("info.range.good_prefix")) { return "in linea entro"; }
        if (key.equals("info.range.mild_prefix")) { return "da monitorare entro"; }
        if (key.equals("info.range.unavailable")) { return "Servono piu dati per calcolare la fascia attiva o il riferimento."; }
        if (key.equals("info.badges.current_prefix")) { return "Badge attuale"; }
        if (key.equals("info.badges.none")) { return "nessuno"; }
        if (key.equals("info.badges.section_metrics")) { return "Metriche"; }
        if (key.equals("info.badges.G")) { return "sincronizzato da Garmin"; }
        if (key.equals("info.badges.M")) { return "inserito manualmente"; }
        if (key.equals("info.badges.CG")) { return "calcolato da dati Garmin"; }
        if (key.equals("info.badges.CM")) { return "calcolato da dati manuali"; }
        if (key.equals("info.badges.section_inputs")) { return "Input"; }
        if (key.equals("info.badges.input_G")) { return "sincronizzato da Garmin"; }
        if (key.equals("info.badges.input_C")) { return "calcolato automaticamente"; }
        if (key.equals("info.factor.sex")) { return "sesso"; }
        if (key.equals("info.factor.age")) { return "eta"; }
        if (key.equals("info.factor.training")) { return "profilo allenamento"; }
        if (key.equals("info.factor.height")) { return "altezza"; }
        if (key.equals("info.factor.weight")) { return "peso"; }
        if (key.equals("info.metric.bmi.desc")) { return "Indice peso-altezza usato per stimare l'equilibrio corporeo generale."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Quota di massa grassa sul totale corporeo, utile per stimare riserva energetica e composizione."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "Massa muscolare stimata in chilogrammi: aiuta a leggere struttura e capacita di carico."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "Percentuale di muscolo sul peso totale: evidenzia quanto del corpo e tessuto contrattile."; }
        if (key.equals("info.metric.water_pct.desc")) { return "Percentuale di acqua corporea: segnala stato di idratazione e qualita della composizione."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "Stima della massa ossea: va letta come indicazione di struttura, non come dato clinico."; }
        if (key.equals("info.metric.weight.desc")) { return "Peso totale corrente: va interpretato insieme a BMI e composizione, non da solo."; }
        if (key.equals("info.metric.bmr.desc")) { return "Dispendio energetico basale stimato a riposo, usato come riferimento metabolico personale."; }
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
        if (key.equals("trend.title")) { return "Andamento"; }
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
        if (key.equals("menu.info")) { return "Metric info"; }
        if (key.equals("menu.language")) { return "Language"; }
        if (key.equals("menu.data")) { return "Enter data"; }
        if (key.equals("menu.badge_info")) { return "Badge info"; }
        if (key.equals("menu.system_info")) { return "System info"; }
        if (key.equals("menu.cat.data")) { return "Data"; }
        if (key.equals("menu.cat.options")) { return "Options"; }
        if (key.equals("menu.cat.info")) { return "Information"; }
        if (key.equals("sysinfo.title")) { return "System info"; }
        if (key.equals("sysinfo.app")) { return "App"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Release"; }
        if (key.equals("sysinfo.author")) { return "Author"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Populate history"; }
        if (key.equals("debug.menu.clear_history")) { return "Clear history"; }
        if (key.equals("debug.menu.disable")) { return "Disable debug"; }
        if (key.equals("debug.menu.enable")) { return "Enable debug"; }
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
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  detail"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  trend"; }
        if (key.equals("info.section.metric")) { return "Metric"; }
        if (key.equals("info.section.ranges")) { return "Ranges and ref."; }
        if (key.equals("info.section.badges")) { return "Badge legend"; }
        if (key.equals("info.range.ideal_prefix")) { return "Ideal range"; }
        if (key.equals("info.range.profile_prefix")) { return "Active profile"; }
        if (key.equals("info.range.depends_prefix")) { return "Depends on"; }
        if (key.equals("info.range.reference_prefix")) { return "Active ref."; }
        if (key.equals("info.range.good_prefix")) { return "aligned within"; }
        if (key.equals("info.range.mild_prefix")) { return "monitor within"; }
        if (key.equals("info.range.unavailable")) { return "More data is required to calculate the active range or reference."; }
        if (key.equals("info.badges.current_prefix")) { return "Current badge"; }
        if (key.equals("info.badges.none")) { return "none"; }
        if (key.equals("info.badges.section_metrics")) { return "Metrics"; }
        if (key.equals("info.badges.G")) { return "synced from Garmin"; }
        if (key.equals("info.badges.M")) { return "manually entered"; }
        if (key.equals("info.badges.CG")) { return "calculated from Garmin data"; }
        if (key.equals("info.badges.CM")) { return "calculated from manual data"; }
        if (key.equals("info.badges.section_inputs")) { return "Inputs"; }
        if (key.equals("info.badges.input_G")) { return "synced from Garmin"; }
        if (key.equals("info.badges.input_C")) { return "auto-calculated"; }
        if (key.equals("info.factor.sex")) { return "sex"; }
        if (key.equals("info.factor.age")) { return "age"; }
        if (key.equals("info.factor.training")) { return "training profile"; }
        if (key.equals("info.factor.height")) { return "height"; }
        if (key.equals("info.factor.weight")) { return "weight"; }
        if (key.equals("info.metric.bmi.desc")) { return "Weight-to-height index used to estimate overall body balance."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Share of body fat on total mass, useful to read energy reserve and body composition."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "Estimated muscle mass in kilograms, useful to read structure and load capacity."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "Muscle percentage on total weight, showing how much of the body is contractile tissue."; }
        if (key.equals("info.metric.water_pct.desc")) { return "Body water percentage, useful to read hydration status and composition quality."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "Estimated bone mass: a structural indicator, not a clinical measurement."; }
        if (key.equals("info.metric.weight.desc")) { return "Current total weight, best interpreted together with BMI and composition rather than alone."; }
        if (key.equals("info.metric.bmr.desc")) { return "Estimated basal energy expenditure at rest, used as a personal metabolic reference."; }
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
        if (key.equals("trend.title")) { return "Trend"; }
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
        if (key.equals("menu.info")) { return "Info metrique"; }
        if (key.equals("menu.language")) { return "Langue"; }
        if (key.equals("menu.data")) { return "Saisir donnees"; }
        if (key.equals("menu.badge_info")) { return "Badge info"; }
        if (key.equals("menu.system_info")) { return "Info systeme"; }
        if (key.equals("menu.cat.data")) { return "Donnees"; }
        if (key.equals("menu.cat.options")) { return "Options"; }
        if (key.equals("menu.cat.info")) { return "Informations"; }
        if (key.equals("sysinfo.title")) { return "Info systeme"; }
        if (key.equals("sysinfo.app")) { return "App"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Release"; }
        if (key.equals("sysinfo.author")) { return "Auteur"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Remplir historique"; }
        if (key.equals("debug.menu.clear_history")) { return "Effacer historique"; }
        if (key.equals("debug.menu.disable")) { return "Desactiver debug"; }
        if (key.equals("debug.menu.enable")) { return "Activer debug"; }
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
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  detail"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  tendance"; }
        if (key.equals("info.section.metric")) { return "Metrique"; }
        if (key.equals("info.section.ranges")) { return "Plages et ref."; }
        if (key.equals("info.section.badges")) { return "Legende badges"; }
        if (key.equals("info.range.ideal_prefix")) { return "Plage ideale"; }
        if (key.equals("info.range.profile_prefix")) { return "Profil actif"; }
        if (key.equals("info.range.depends_prefix")) { return "Depend de"; }
        if (key.equals("info.range.reference_prefix")) { return "Ref. active"; }
        if (key.equals("info.range.good_prefix")) { return "aligne dans"; }
        if (key.equals("info.range.mild_prefix")) { return "a suivre dans"; }
        if (key.equals("info.range.unavailable")) { return "Des donnees supplementaires sont necessaires pour calculer la plage active ou la reference."; }
        if (key.equals("info.badges.current_prefix")) { return "Badge actuel"; }
        if (key.equals("info.badges.none")) { return "aucun"; }
        if (key.equals("info.badges.section_metrics")) { return "Metriques"; }
        if (key.equals("info.badges.G")) { return "synchronise depuis Garmin"; }
        if (key.equals("info.badges.M")) { return "entree manuellement"; }
        if (key.equals("info.badges.CG")) { return "calcule a partir des donnees Garmin"; }
        if (key.equals("info.badges.CM")) { return "calcule a partir des donnees manuelles"; }
        if (key.equals("info.badges.section_inputs")) { return "Saisie"; }
        if (key.equals("info.badges.input_G")) { return "synchronise depuis Garmin"; }
        if (key.equals("info.badges.input_C")) { return "calcule automatiquement"; }
        if (key.equals("info.factor.sex")) { return "sexe"; }
        if (key.equals("info.factor.age")) { return "age"; }
        if (key.equals("info.factor.training")) { return "profil d'entrainement"; }
        if (key.equals("info.factor.height")) { return "taille"; }
        if (key.equals("info.factor.weight")) { return "poids"; }
        if (key.equals("info.metric.bmi.desc")) { return "Indice poids-taille utilise pour estimer l'equilibre corporel global."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Part de graisse sur la masse totale, utile pour lire reserve energetique et composition."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "Masse musculaire estimee en kilogrammes, utile pour lire structure et capacite de charge."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "Pourcentage de muscle sur le poids total, montrant la part de tissu contractile."; }
        if (key.equals("info.metric.water_pct.desc")) { return "Pourcentage d'eau corporelle, utile pour lire hydratation et qualite de composition."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "Estimation de masse osseuse: indicateur structurel, pas une mesure clinique."; }
        if (key.equals("info.metric.weight.desc")) { return "Poids total actuel, a interpreter avec l'IMC et la composition plutot qu'isole."; }
        if (key.equals("info.metric.bmr.desc")) { return "Depense energetique basale estimee au repos, utilisee comme reference metabolique personnelle."; }
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
        if (key.equals("trend.title")) { return "Tendance"; }
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
        if (key.equals("menu.info")) { return "Info metrica"; }
        if (key.equals("menu.language")) { return "Idioma"; }
        if (key.equals("menu.data")) { return "Ingresar datos"; }
        if (key.equals("menu.badge_info")) { return "Badge info"; }
        if (key.equals("menu.system_info")) { return "Info sistema"; }
        if (key.equals("menu.cat.data")) { return "Datos"; }
        if (key.equals("menu.cat.options")) { return "Opciones"; }
        if (key.equals("menu.cat.info")) { return "Informacion"; }
        if (key.equals("sysinfo.title")) { return "Info sistema"; }
        if (key.equals("sysinfo.app")) { return "App"; }
        if (key.equals("sysinfo.version")) { return "Version"; }
        if (key.equals("sysinfo.release")) { return "Release"; }
        if (key.equals("sysinfo.author")) { return "Autor"; }
        if (key.equals("debug.menu.title")) { return "Debug"; }
        if (key.equals("debug.menu.populate_history")) { return "Poblar historial"; }
        if (key.equals("debug.menu.clear_history")) { return "Borrar historial"; }
        if (key.equals("debug.menu.disable")) { return "Desactivar debug"; }
        if (key.equals("debug.menu.enable")) { return "Activar debug"; }
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
        if (key.equals("cta.summary_info")) { return "SELECT  info"; }
        if (key.equals("cta.info_detail")) { return "SELECT  detalle"; }
        if (key.equals("cta.detail_trend")) { return "SELECT  tendencia"; }
        if (key.equals("info.section.metric")) { return "Metrica"; }
        if (key.equals("info.section.ranges")) { return "Rangos y ref."; }
        if (key.equals("info.section.badges")) { return "Leyenda badges"; }
        if (key.equals("info.range.ideal_prefix")) { return "Rango ideal"; }
        if (key.equals("info.range.profile_prefix")) { return "Perfil activo"; }
        if (key.equals("info.range.depends_prefix")) { return "Depende de"; }
        if (key.equals("info.range.reference_prefix")) { return "Ref. activa"; }
        if (key.equals("info.range.good_prefix")) { return "alineado dentro de"; }
        if (key.equals("info.range.mild_prefix")) { return "vigilar dentro de"; }
        if (key.equals("info.range.unavailable")) { return "Se necesitan mas datos para calcular el rango activo o la referencia."; }
        if (key.equals("info.badges.current_prefix")) { return "Badge actual"; }
        if (key.equals("info.badges.none")) { return "ninguno"; }
        if (key.equals("info.badges.section_metrics")) { return "Metricas"; }
        if (key.equals("info.badges.G")) { return "sincronizado desde Garmin"; }
        if (key.equals("info.badges.M")) { return "ingresado manualmente"; }
        if (key.equals("info.badges.CG")) { return "calculado a partir de datos Garmin"; }
        if (key.equals("info.badges.CM")) { return "calculado a partir de datos manuales"; }
        if (key.equals("info.badges.section_inputs")) { return "Entrada"; }
        if (key.equals("info.badges.input_G")) { return "sincronizado desde Garmin"; }
        if (key.equals("info.badges.input_C")) { return "calculado automaticamente"; }
        if (key.equals("info.factor.sex")) { return "sexo"; }
        if (key.equals("info.factor.age")) { return "edad"; }
        if (key.equals("info.factor.training")) { return "perfil de entrenamiento"; }
        if (key.equals("info.factor.height")) { return "altura"; }
        if (key.equals("info.factor.weight")) { return "peso"; }
        if (key.equals("info.metric.bmi.desc")) { return "Indice peso-altura usado para estimar el equilibrio corporal general."; }
        if (key.equals("info.metric.fat_pct.desc")) { return "Proporcion de grasa sobre la masa total, util para leer reserva energetica y composicion."; }
        if (key.equals("info.metric.muscle_kg.desc")) { return "Masa muscular estimada en kilogramos, util para leer estructura y capacidad de carga."; }
        if (key.equals("info.metric.muscle_pct.desc")) { return "Porcentaje muscular sobre el peso total, mostrando cuanto del cuerpo es tejido contractil."; }
        if (key.equals("info.metric.water_pct.desc")) { return "Porcentaje de agua corporal, util para leer hidratacion y calidad de composicion."; }
        if (key.equals("info.metric.bone_kg.desc")) { return "Estimacion de masa osea: indicador estructural, no una medicion clinica."; }
        if (key.equals("info.metric.weight.desc")) { return "Peso total actual, mejor interpretado junto con IMC y composicion en vez de aislado."; }
        if (key.equals("info.metric.bmr.desc")) { return "Gasto energetico basal estimado en reposo, usado como referencia metabolica personal."; }
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
        if (key.equals("trend.title")) { return "Tendencia"; }
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