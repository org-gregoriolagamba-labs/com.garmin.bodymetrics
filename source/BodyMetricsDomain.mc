import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

const ZONE_GREEN = 0;
const ZONE_YELLOW = 1;
const ZONE_ORANGE = 2;
const ZONE_RED = 3;

//! Politiche di classificazione delle metriche:
//! - targetRange: range bidirezionale (basso/alto) con soglie green/yellow/orange/red
//! - lowOnly: solo soglie inferiori (es. massa muscolare, idratazione)
//! - highOnly: solo soglia superiore
//! - referenceOnly: deviazione percentuale da un valore di riferimento (es. BMR)
const POLICY_TARGET_RANGE = "targetRange";
const POLICY_LOW_ONLY = "lowOnly";
const POLICY_REFERENCE_ONLY = "referenceOnly";

const PROFILE_SEX_KEY = "bodyMetrics.profile.sex";
const PROFILE_AGE_BAND_KEY = "bodyMetrics.profile.ageBand";
const PROFILE_BODY_PROFILE_KEY = "bodyMetrics.profile.bodyProfile";
const PROFILE_HEIGHT_KEY = "bodyMetrics.profile.heightCm";

//! Cuore della logica applicativa. Coordina profilo utente, misurazioni,
//! classificazione a zone colorate, soglie cliniche e history.
//! Non dipende dalla UI: tutta la presentazione è delegata a BodyMetricsView.
class BodyMetricsDomain {

    //! DEBUG: Popola la history con dati casuali per 90 giorni
    function populateHistoryDebug() as Void {
        // Passa l'altezza reale del profilo e un BMR di riferimento al generatore,
        // in modo che i valori nel grafico siano coerenti con quelli della view corrente.
        var heightCm = _profile[:heightCm] != null ? (_profile[:heightCm] as Number).toFloat() : 175.0;
        // Calcola BMR di riferimento sul peso iniziale del generatore (78.5 kg)
        var refProfile = {:sex => _profile[:sex], :ageBand => _profile[:ageBand], :heightCm => heightCm.toNumber()};
        if (refProfile[:sex] == null) { refProfile[:sex] = "male"; }
        if (refProfile[:ageBand] == null) { refProfile[:ageBand] = "40_59"; }
        var bmrBase = calculateBmrReference(refProfile, 78.5).toFloat();
        _history.populateHistoryDebug(heightCm, bmrBase);
        // Aggiorna le misurazioni correnti con l'ultimo entry dello storico,
        // marcandole come inserite manualmente alla data odierna.
        var last = _history.lastRawEntry();
        if (last != null) {
            // Format: [ts(0), bmi(1), fat%(2), muscleKg(3), muscle%(4), water%(5), boneKg(6), weightKg(7), bmr(8)]
            // Costruisce _measurements direttamente dall'entry — senza passare per Storage,
            // così il peso Garmin non sovrascrive il valore debug (solo in memoria, non persiste).
            var entry = last as Array;
            _measurements = {
                :weightKg     => entry[7] != null ? (entry[7] as Float).toFloat() : null,
                :fatPct       => entry[2] != null ? (entry[2] as Float).toFloat() : null,
                :musclePct    => entry[4] != null ? (entry[4] as Float).toFloat() : null,
                :waterPct     => entry[5] != null ? (entry[5] as Float).toFloat() : null,
                :boneKg       => entry[6] != null ? (entry[6] as Float).toFloat() : null,
                :bmr          => null,
                :weightSource => SOURCE_MANUAL,
                :bodyCompSource => SOURCE_MANUAL
            };
        }
        rebuildMetrics();
    }

    //! DEBUG: Cancella la history
    function clearHistoryDebug() as Void {
        _history.clearHistory();
        rebuildMetrics();
    }

    function disableDebugMode() as Void {
        _history.disableDebugHistory();
        rebuildMetrics();
    }

    var _metrics as Array = [];
    var _locale;
    var _profile as Dictionary;
    var _measurements as Dictionary;
    var _hasStoredProfile as Boolean;
    var _dataProvider;
    var _garminProfile;
    var _history;
    var _targets;
    var _calculators;

    function initialize() {
        _locale = new BodyMetricsLocale();
        _garminProfile = new BodyMetricsGarminProfile();
        _dataProvider = new BodyMetricsDataProvider(_garminProfile);
        _history = new BodyMetricsHistory();
        _targets = new BodyMetricsTargets();
        _calculators = new BodyMetricsHealthCalculators();
        _hasStoredProfile = false;
        _profile = loadProfile();
        _measurements = _dataProvider.loadMeasurements();
        rebuildMetrics();
        // Record snapshot on startup to capture any Garmin data changes
        if (_dataProvider.hasAnyMeasurements()) {
            _history.recordSnapshot(_metrics as Array);
        }
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
        var storedSex = Storage.getValue(PROFILE_SEX_KEY);
        var storedAgeBand = Storage.getValue(PROFILE_AGE_BAND_KEY);
        var storedBodyProfile = Storage.getValue(PROFILE_BODY_PROFILE_KEY);
        var storedHeightCm = Storage.getValue(PROFILE_HEIGHT_KEY);

        return {
            :sex => garmin[:sex] != null ? garmin[:sex] : storedSex,
            :ageBand => garmin[:ageBand] != null ? garmin[:ageBand] : storedAgeBand,
            :bodyProfile => storedBodyProfile,
            :heightCm => garmin[:heightCm] != null ? garmin[:heightCm] : storedHeightCm
        };
    }

    // --- Data provider access ---

    function hasStoredMeasurements() as Boolean {
        return _dataProvider.hasStoredMeasurements();
    }

    function lastUpdateLabel() as String {
        return _dataProvider.lastUpdateLabel();
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

    function currentMeasurements() as Dictionary {
        var draft = {
            :weightKg => _measurements[:weightKg] != null ? _measurements[:weightKg] : 75.0,
            :fatPct => _measurements[:fatPct] != null ? _measurements[:fatPct] : 25.0,
            :musclePct => _measurements[:musclePct] != null ? _measurements[:musclePct] : 38.0,
            :waterPct => _measurements[:waterPct] != null ? _measurements[:waterPct] : 55.0,
            :boneKg => _measurements[:boneKg] != null ? _measurements[:boneKg] : 3.5,
            :bmr => null
        };
        return refreshDerivedMeasurementFields(draft);
    }

    function cycleMeasurementField(draft as Dictionary, index as Number, delta as Number) as Dictionary {
        var field = measurementFieldDefinition(index);
        if (field.hasKey(:readOnly) && field[:readOnly]) {
            return refreshDerivedMeasurementFields(draft);
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
        draft[key] = round1Global(next);
        return refreshDerivedMeasurementFields(draft);
    }

    function measurementFieldValueLabel(draft as Dictionary, index as Number) as String {
        var field = measurementFieldDefinition(index);
        var key = field[:key];
        if (draft[key] == null) {
            return _locale.text("hint.unavailable");
        }
        var value = draft[key].toFloat();
        return fmt1Global(value) + " " + field[:unit].toString();
    }

    function saveMeasurements(draft as Dictionary) as Void {
        _dataProvider.saveMeasurements(draft);
        _measurements = _dataProvider.loadMeasurements();
        rebuildMetrics();
        _history.recordSnapshot(_metrics as Array);
    }

    // --- Personalized targets ---

    function targetFieldDefinitions() as Array {
        return [
            {:key => :bmi, :metricId => "bmi", :label => _locale.metricLabel("bmi"), :unit => "kg/m2", :min => 15.0, :max => 35.0, :step => 0.1},
            {:key => :fat_pct, :metricId => "fat_pct", :label => _locale.metricLabel("fat_pct"), :unit => "%", :min => 5.0, :max => 45.0, :step => 0.1},
            {:key => :muscle_kg, :metricId => "muscle_kg", :label => _locale.metricLabel("muscle_kg"), :unit => "kg", :min => 15.0, :max => 70.0, :step => 0.1},
            {:key => :muscle_pct, :metricId => "muscle_pct", :label => _locale.metricLabel("muscle_pct"), :unit => "%", :min => 20.0, :max => 65.0, :step => 0.1},
            {:key => :water_pct, :metricId => "water_pct", :label => _locale.metricLabel("water_pct"), :unit => "%", :min => 40.0, :max => 75.0, :step => 0.1},
            {:key => :bone_kg, :metricId => "bone_kg", :label => _locale.metricLabel("bone_kg"), :unit => "kg", :min => 1.0, :max => 6.0, :step => 0.1},
            {:key => :weight, :metricId => "weight", :label => _locale.metricLabel("weight"), :unit => "kg", :min => 40.0, :max => 200.0, :step => 0.1}
        ];
    }

    function targetFieldCount() as Number {
        return targetFieldDefinitions().size();
    }

    function targetFieldDefinition(index as Number) as Dictionary {
        return targetFieldDefinitions()[index] as Dictionary;
    }

    function currentTargets() as Dictionary {
        var draft = {};
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            var metricId = field[:metricId].toString();
            var metric = metricById(metricId);
            if (metric != null) {
                draft[field[:key]] = _targets.getEffectiveTarget(metricId, metric as Dictionary);
            }
        }
        return draft;
    }

    function cycleTargetField(draft as Dictionary, index as Number, delta as Number) as Dictionary {
        var field = targetFieldDefinition(index);
        var key = field[:key];
        var current = draft[key] != null ? draft[key].toFloat() : field[:min].toFloat();
        var step = field[:step].toFloat();
        var next = current + (delta * step);
        if (next < field[:min].toFloat()) {
            next = field[:max].toFloat();
        } else if (next > field[:max].toFloat()) {
            next = field[:min].toFloat();
        }
        draft[key] = round1Global(next);
        return draft;
    }

    function targetFieldValueLabel(draft as Dictionary, index as Number) as String {
        var field = targetFieldDefinition(index);
        var key = field[:key];
        if (draft[key] == null) {
            return _locale.text("hint.unavailable");
        }
        return fmt1Global(draft[key].toFloat()) + " " + field[:unit].toString();
    }

    function saveTargets(draft as Dictionary) as Void {
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            var key = field[:key];
            var metricId = field[:metricId].toString();
            if (draft[key] != null) {
                _targets.setUserTarget(metricId, draft[key].toFloat());
            }
        }
    }

    function resetAllTargets() as Void {
        var fields = targetFieldDefinitions();
        for (var i = 0; i < fields.size(); i += 1) {
            var field = fields[i] as Dictionary;
            _targets.clearUserTarget(field[:metricId].toString());
        }
    }

    function resetAllUserData() as Void {
        // Profile storage
        Storage.deleteValue(PROFILE_SEX_KEY);
        Storage.deleteValue(PROFILE_AGE_BAND_KEY);
        Storage.deleteValue(PROFILE_BODY_PROFILE_KEY);
        Storage.deleteValue(PROFILE_HEIGHT_KEY);

        // Measurement storage
        _dataProvider.clearStoredMeasurements();

        // Targets storage
        resetAllTargets();

        // History storage (also clears debug flags)
        _history.clearHistory();

        // Runtime refresh
        _hasStoredProfile = false;
        _profile = loadProfile();
        _measurements = _dataProvider.loadMeasurements();
        rebuildMetrics();
    }

    function effectiveTargetForMetric(metric as Dictionary) {
        if (metric == null || !metric.hasKey(:id)) {
            return null;
        }
        return _targets.getEffectiveTarget(metric[:id].toString(), metric);
    }

    function getEffectiveTargetForIndex(metricIndex as Number) {
        var metric = metricAt(metricIndex);
        if (!metric[:available]) {
            return null;
        }
        return effectiveTargetForMetric(metric);
    }

    function getDeltaToTargetForIndex(metricIndex as Number) {
        var metric = metricAt(metricIndex);
        if (!metric[:available]) {
            return null;
        }
        if (classificationPolicy(metric).equals(POLICY_REFERENCE_ONLY)) {
            return null;
        }
        var target = effectiveTargetForMetric(metric);
        if (target == null) {
            return null;
        }
        return _targets.deltaToTarget(metric[:value].toFloat(), target.toFloat());
    }

    function getDeltaPctToTargetForIndex(metricIndex as Number) {
        var metric = metricAt(metricIndex);
        if (!metric[:available]) {
            return null;
        }
        if (classificationPolicy(metric).equals(POLICY_REFERENCE_ONLY)) {
            return null;
        }
        var target = effectiveTargetForMetric(metric);
        if (target == null) {
            return null;
        }
        return _targets.deltaPctToTarget(metric[:value].toFloat(), target.toFloat());
    }

    function priorityMetricIndex() as Number {
        var bestIndex = -1;
        var bestScore = 0.0;

        for (var i = 0; i < _metrics.size(); i += 1) {
            var metric = _metrics[i] as Dictionary;
            if (!metric[:available]) {
                continue;
            }
            if (classificationPolicy(metric).equals(POLICY_REFERENCE_ONLY)) {
                continue;
            }

            var zone = classify(metric);
            if (zone == ZONE_GREEN) {
                continue;
            }

            var target = effectiveTargetForMetric(metric);
            if (target == null || target.toFloat() == 0.0) {
                continue;
            }

            var deltaPct = _targets.deltaPctToTarget(metric[:value].toFloat(), target.toFloat());
            var absDeltaPct = 0.0;
            if (deltaPct != null) {
                absDeltaPct = deltaPct.toFloat();
                if (absDeltaPct < 0.0) {
                    absDeltaPct = -absDeltaPct;
                }
            }

            var score = (zone.toFloat() * 100.0) + absDeltaPct;
            if (bestIndex < 0 || score > bestScore) {
                bestIndex = i;
                bestScore = score;
            }
        }

        return bestIndex;
    }

    // --- History / Trend API ---

    function historyBestWindow(metricIndex as Number) as Number {
        return _history.bestWindow(metricIndex);
    }

    function historyValues(metricIndex as Number, windowDays as Number) as Array {
        return _history.valuesForMetric(metricIndex, windowDays);
    }

    function historyTrend(metricIndex as Number, windowDays as Number) as Number {
        return _history.computeTrend(metricIndex, windowDays);
    }

    function refreshDerivedMeasurementFields(draft as Dictionary) as Dictionary {
        draft[:bmr] = derivedBmrValueForDraft(draft);
        return draft;
    }

    function derivedBmrValueForDraft(draft as Dictionary) {
        // Nel wizard i dati inseriti sono sempre manuali: calcola BMR se tutti i campi richiesti sono presenti.
        if (draft[:weightKg] == null || _profile[:heightCm] == null ||
            _profile[:sex] == null || _profile[:ageBand] == null) {
            return null;
        }
        return calculateBmrReference(_profile, draft[:weightKg]).toFloat();
    }

    function loadProfile() as Dictionary {
        var merged = mergedProfileValues();

        // The body profile is manual-only, just like body composition values.
        // Garmin can prefill sex, age band and height, but never this field.
        _hasStoredProfile = Storage.getValue(PROFILE_BODY_PROFILE_KEY) != null;

        return sanitizeProfile(merged);
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

    function currentProfile() as Dictionary {
        var current = sanitizeProfile(_profile);
        if (Storage.getValue(PROFILE_BODY_PROFILE_KEY) == null) {
            current[:bodyProfile] = null;
        }
        return current;
    }

    function hasConfiguredProfile() as Boolean {
        return _hasStoredProfile;
    }

    function saveProfile(profile as Dictionary) as Void {
        _profile = sanitizeProfile(profile);
        Storage.setValue(PROFILE_SEX_KEY, _profile[:sex].toString());
        Storage.setValue(PROFILE_AGE_BAND_KEY, _profile[:ageBand].toString());
        Storage.setValue(PROFILE_BODY_PROFILE_KEY, _profile[:bodyProfile].toString());
        Storage.setValue(PROFILE_HEIGHT_KEY, _profile[:heightCm].toNumber());
        _hasStoredProfile = true;
        rebuildMetrics();
        _history.recordSnapshot(_metrics as Array);
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
        return profileFields().size();
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

    function rebuildMetrics() as Void {
        _metrics = buildMetrics(_profile, _measurements);
    }

    function buildMetrics(profile as Dictionary, measurements as Dictionary) as Array {
        var metrics = [];
        var bmiRange = bmiTargetRange(profile);
        var fatRange = fatPctRange(profile);
        var muscleKgBand = muscleKgRange(profile);
        var musclePctBand = musclePctRange(profile);
        var waterBand = waterPctRange(profile);
        var boneBand = boneKgRange(profile);
        var weightRange = weightTargetRange(profile, bmiRange);

        var weightSrc = measurements[:weightSource];
        var bodySrc = measurements[:bodyCompSource];

        // Source classification helpers
        var garminData = _garminProfile.readProfile() as Dictionary;
        var weightIsGarmin  = weightSrc != null && weightSrc.equals(SOURCE_GARMIN);
        var heightIsGarmin  = garminData[:heightCm] != null;
        var sexIsGarmin     = garminData[:sex] != null;
        var ageBandIsGarmin = garminData[:ageBand] != null;

        // BMI - preferisce sorgenti omogenee (CG/CM); con sorgenti miste usa SOURCE_CALC_MANUAL
        if (measurements[:weightKg] != null && profile[:heightCm] != null) {
            var bmiSrc = (weightIsGarmin && heightIsGarmin) ? SOURCE_CALC_GARMIN : SOURCE_CALC_MANUAL;
            var m = buildTargetMetric(
                "bmi", "BMI", "kg/m2", calculateBmi(measurements[:weightKg], profile[:heightCm]),
                bmiRange[:greenMin], bmiRange[:greenMax],
                bmiRange[:yellowLowMin], bmiRange[:yellowLowMax],
                bmiRange[:yellowHighMin], bmiRange[:yellowHighMax],
                bmiRange[:orangeLowMin], bmiRange[:orangeLowMax],
                bmiRange[:orangeHighMin], bmiRange[:orangeHighMax]
            );
            m[:available] = true;
            m[:source] = bmiSrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("bmi", "BMI", "kg/m2"));
        }

        // Fat% - requires fatPct
        if (measurements[:fatPct] != null) {
            var m = buildTargetMetric(
                "fat_pct", "Grasso %", "%", measurements[:fatPct],
                fatRange[:greenMin], fatRange[:greenMax],
                fatRange[:yellowLowMin], fatRange[:yellowLowMax],
                fatRange[:yellowHighMin], fatRange[:yellowHighMax],
                fatRange[:orangeLowMin], fatRange[:orangeLowMax],
                fatRange[:orangeHighMin], fatRange[:orangeHighMax]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("fat_pct", "Grasso %", "%"));
        }

        // Muscle kg - calcolata da weight * musclePct/100: fonte dipende da entrambe le sorgenti.
        // CG se weight è Garmin e body comp è Garmin; CM se entrambe manuali o miste.
        if (measurements[:weightKg] != null && measurements[:musclePct] != null) {
            var muscleKgSrc = (weightIsGarmin && bodySrc != null && bodySrc.equals(SOURCE_MANUAL))
                ? SOURCE_CALC_MANUAL
                : (weightIsGarmin ? SOURCE_CALC_GARMIN : SOURCE_CALC_MANUAL);
            var m = buildLowOnlyMetric(
                "muscle_kg", "Massa muscolare", "kg", muscleKgFromMeasurements(measurements),
                muscleKgBand[:greenMin], muscleKgBand[:greenMax],
                muscleKgBand[:yellowMin], muscleKgBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = muscleKgSrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("muscle_kg", "Massa muscolare", "kg"));
        }

        // Muscle% - requires musclePct
        if (measurements[:musclePct] != null) {
            var m = buildLowOnlyMetric(
                "muscle_pct", "Muscoli %", "%", measurements[:musclePct],
                musclePctBand[:greenMin], musclePctBand[:greenMax],
                musclePctBand[:yellowMin], musclePctBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("muscle_pct", "Muscoli %", "%"));
        }

        // Water% - requires waterPct
        if (measurements[:waterPct] != null) {
            var m = buildLowOnlyMetric(
                "water_pct", "Idratazione", "%", measurements[:waterPct],
                waterBand[:greenMin], waterBand[:greenMax],
                waterBand[:yellowMin], waterBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("water_pct", "Idratazione", "%"));
        }

        // Bone kg - requires boneKg
        if (measurements[:boneKg] != null) {
            var m = buildLowOnlyMetric(
                "bone_kg", "Massa ossea", "kg", measurements[:boneKg],
                boneBand[:greenMin], boneBand[:greenMax],
                boneBand[:yellowMin], boneBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("bone_kg", "Massa ossea", "kg"));
        }

        // Weight - requires weightKg
        if (measurements[:weightKg] != null) {
            var m = buildTargetMetric(
                "weight", "Peso", "kg", measurements[:weightKg],
                weightRange[:greenMin], weightRange[:greenMax],
                weightRange[:yellowLowMin], weightRange[:yellowLowMax],
                weightRange[:yellowHighMin], weightRange[:yellowHighMax],
                weightRange[:orangeLowMin], weightRange[:orangeLowMax],
                weightRange[:orangeHighMin], weightRange[:orangeHighMax]
            );
            m[:available] = true;
            m[:source] = weightSrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("weight", "Peso", "kg"));
        }

        // BMR - Mifflin-St Jeor: requires weight + height + sex + ageBand.
        // CG se tutti i valori da Garmin; altrimenti CM.
        if (measurements[:weightKg] != null && profile[:heightCm] != null &&
            profile[:sex] != null && profile[:ageBand] != null) {
            var bmrSrc = (weightIsGarmin && heightIsGarmin && sexIsGarmin && ageBandIsGarmin)
                ? SOURCE_CALC_GARMIN : SOURCE_CALC_MANUAL;
            var calculatedBmr = calculateBmrReference(profile, measurements[:weightKg]).toFloat();
            var m = buildReferenceMetric(
                "bmr", "BMR", "kcal", calculatedBmr,
                calculatedBmr, 5.0, 10.0
            );
            m[:available] = true;
            m[:source] = bmrSrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("bmr", "BMR", "kcal"));
        }

        return metrics;
    }

    function unavailableMetric(id as String, label as String, unit as String) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :available => false,
            :value => 0,
            :source => null,
            :policy => POLICY_TARGET_RANGE,
            :greenMin => 0,
            :greenMax => 0
        };
    }

    function buildTargetMetric(id as String, label as String, unit as String, value, greenMin, greenMax,
        yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax,
        orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_TARGET_RANGE,
            :value => value,
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

    function buildLowOnlyMetric(id as String, label as String, unit as String, value, greenMin, greenMax, yellowMin, orangeMin) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_LOW_ONLY,
            :value => value,
            :greenMin => greenMin,
            :greenMax => greenMax,
            :yellowMin => yellowMin,
            :orangeMin => orangeMin
        };
    }

    function buildReferenceMetric(id as String, label as String, unit as String, value, referenceValue, toleranceGoodPct, toleranceMildPct) as Dictionary {
        return {
            :id => id,
            :label => label,
            :unit => unit,
            :policy => POLICY_REFERENCE_ONLY,
            :value => value,
            :referenceValue => referenceValue,
            :toleranceGoodPct => toleranceGoodPct,
            :toleranceMildPct => toleranceMildPct
        };
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
            round1Global(bmiRange[:greenMin].toFloat() * heightSquared),
            round1Global(bmiRange[:greenMax].toFloat() * heightSquared),
            round1Global(bmiRange[:yellowLowMin].toFloat() * heightSquared),
            round1Global(bmiRange[:yellowLowMax].toFloat() * heightSquared),
            round1Global(bmiRange[:yellowHighMin].toFloat() * heightSquared),
            round1Global(bmiRange[:yellowHighMax].toFloat() * heightSquared),
            round1Global(bmiRange[:orangeLowMin].toFloat() * heightSquared),
            round1Global(bmiRange[:orangeLowMax].toFloat() * heightSquared),
            round1Global(bmiRange[:orangeHighMin].toFloat() * heightSquared),
            round1Global(bmiRange[:orangeHighMax].toFloat() * heightSquared)
        );
    }

    function buildTargetThresholds(greenMin as Float, greenMax as Float, lowStepYellow as Float, lowStepOrange as Float, highStepYellow as Float, highStepOrange as Float) as Dictionary {
        return buildTargetMetricThresholds(
            round1Global(greenMin),
            round1Global(greenMax),
            round1Global(greenMin - lowStepYellow),
            round1Global(greenMin),
            round1Global(greenMax),
            round1Global(greenMax + highStepYellow),
            round1Global(greenMin - lowStepOrange),
            round1Global(greenMin - lowStepYellow),
            round1Global(greenMax + highStepYellow),
            round1Global(greenMax + highStepOrange)
        );
    }

    function buildTargetMetricThresholds(greenMin, greenMax, yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax, orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
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
            :greenMin => round1Global(greenMin),
            :greenMax => round1Global(greenMax),
            :yellowMin => round1Global(greenMin - yellowStep),
            :orangeMin => round1Global(greenMin - orangeStep)
        };
    }

    function representativeAge(profile as Dictionary) as Number {
        return _calculators.representativeAge(profile);
    }

    function calculateBmi(weightKg, heightCm) as Float {
        return _calculators.calculateBmi(weightKg, heightCm);
    }

    function calculateBmrReference(profile as Dictionary, weightKg) as Float {
        return _calculators.calculateBmrReference(profile, weightKg);
    }

    function muscleKgFromMeasurements(measurements as Dictionary) as Float {
        return _calculators.muscleKgFromMeasurements(measurements);
    }

    function metricsCount() as Number {
        return _metrics.size();
    }

    function text(key as String) as String {
        return _locale.text(key);
    }

    function currentLanguage() as String {
        return _locale.currentLanguage();
    }

    function setLanguage(language as String) as Void {
        _locale.setLanguage(language);
        rebuildMetrics();
    }

    function supportedLanguages() as Array {
        return _locale.supportedLanguages();
    }

    function languageLabel(language as String) as String {
        return _locale.languageLabel(language);
    }

    function metricAt(index as Number) as Dictionary {
        var metrics = _metrics as Array;
        return metrics[index] as Dictionary;
    }

    function metricLabel(index as Number) as String {
        return _locale.metricLabel(metricAt(index)[:id].toString());
    }

    function metricById(metricId as String) {
        for (var i = 0; i < _metrics.size(); i += 1) {
            var metric = _metrics[i] as Dictionary;
            if (metric[:id].toString().equals(metricId)) {
                return metric;
            }
        }
        return null;
    }

    function metricInfo(index as Number) as Dictionary {
        var metric = metricAt(index) as Dictionary;
        var metricId = metric[:id].toString();
        return {
            :description => _locale.text("info.metric." + metricId + ".desc"),
            :rangeLines => metricInfoRangeLines(metricId, metric[:unit].toString())
        };
    }

    //! Returns an array of {:label, :value} pairs for range info
    function metricInfoRangeLines(metricId as String, unit as String) as Array {
        var infoMetricValue = infoMetricDefinition(metricId);
        if (infoMetricValue == null) {
            return [{:label => "", :value => _locale.text("info.range.unavailable")}];
        }
        var infoMetric = infoMetricValue as Dictionary;
        var lines = [] as Array;

        if ((infoMetric[:policy] as String).equals(POLICY_REFERENCE_ONLY)) {
            lines.add({:label => _locale.text("info.range.reference_prefix"), :value => fmtThreshold(infoMetric[:referenceValue]) + " " + unit});
            lines.add({:label => _locale.text("info.range.good_prefix"), :value => "+/-" + fmtThreshold(infoMetric[:toleranceGoodPct]) + "%"});
            lines.add({:label => _locale.text("info.range.mild_prefix"), :value => "+/-" + fmtThreshold(infoMetric[:toleranceMildPct]) + "%"});
        } else {
            lines.add({:label => _locale.text("info.range.ideal_prefix"), :value => idealRangeText(infoMetric) + " " + unit});
            lines.add({:label => _locale.text("info.range.profile_prefix"), :value => activeProfileSummary()});
        }
        lines.add({:label => _locale.text("info.range.depends_prefix"), :value => metricInfoFactorsText(metricId)});
        return lines;
    }

    //! Returns the metric definition for the given ID from the pre-built metrics array.
    //! Returns null if the metric is unavailable or not found.
    function infoMetricDefinition(metricId as String) {
        for (var i = 0; i < _metrics.size(); i += 1) {
            var m = _metrics[i] as Dictionary;
            if (m[:id].equals(metricId)) {
                if (m.hasKey(:available) && m[:available]) {
                    return m;
                }
                return null;
            }
        }
        return null;
    }

    function activeProfileSummary() as String {
        return profileFieldValueLabel(_profile, 0) + ", " +
            profileFieldValueLabel(_profile, 1) + ", " +
            profileFieldValueLabel(_profile, 3);
    }

    function metricInfoFactorsText(metricId as String) as String {
        if (metricId.equals("bmi") || metricId.equals("weight")) {
            return _locale.text("info.factor.sex") + ", " +
                _locale.text("info.factor.age") + ", " +
                _locale.text("info.factor.training") + ", " +
                _locale.text("info.factor.height");
        }

        if (metricId.equals("fat_pct") || metricId.equals("muscle_kg") || metricId.equals("muscle_pct")) {
            return _locale.text("info.factor.sex") + ", " +
                _locale.text("info.factor.age") + ", " +
                _locale.text("info.factor.training");
        }

        if (metricId.equals("water_pct") || metricId.equals("bone_kg")) {
            return _locale.text("info.factor.sex");
        }

        if (metricId.equals("bmr")) {
            return _locale.text("info.factor.weight") + ", " +
                _locale.text("info.factor.height") + ", " +
                _locale.text("info.factor.sex") + ", " +
                _locale.text("info.factor.age");
        }

        return _locale.text("info.factor.training");
    }

    function classify(metric as Dictionary) {
        if (metric.hasKey(:available) && !metric[:available]) {
            return ZONE_GREEN;
        }
        var value = metric[:value];
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return classifyLowOnly(metric, value);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return classifyReferenceOnly(metric, value);
        }

        return classifyTargetRange(metric, value);
    }

    function classificationPolicy(metric as Dictionary) {
        if (metric.hasKey(:policy)) {
            return metric[:policy];
        }
        return POLICY_TARGET_RANGE;
    }

    function classifyTargetRange(metric as Dictionary, value) {
        var yellowLowMin = thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = thresholdOr(metric, :orangeLowMax, :yellowMin);
        var orangeHighMin = thresholdOr(metric, :orangeHighMin, :yellowMax);
        var orangeHighMax = thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (inRange(value, metric[:greenMin], metric[:greenMax])) {
            return ZONE_GREEN;
        }

        if (inRange(value, yellowLowMin, yellowLowMax) || inRange(value, yellowHighMin, yellowHighMax)) {
            return ZONE_YELLOW;
        }

        if (inRange(value, orangeLowMin, orangeLowMax) || inRange(value, orangeHighMin, orangeHighMax)) {
            return ZONE_ORANGE;
        }

        return ZONE_RED;
    }

    function classifyLowOnly(metric as Dictionary, value) {
        if (value >= metric[:greenMin]) {
            return ZONE_GREEN;
        }

        if (value >= metric[:yellowMin]) {
            return ZONE_YELLOW;
        }

        if (value >= metric[:orangeMin]) {
            return ZONE_ORANGE;
        }

        return ZONE_RED;
    }

    function classifyReferenceOnly(metric as Dictionary, value) {
        var deltaPct = referenceDeltaPct(metric, value);
        if (deltaPct <= metric[:toleranceGoodPct].toFloat()) {
            return ZONE_GREEN;
        }
        if (deltaPct <= metric[:toleranceMildPct].toFloat()) {
            return ZONE_YELLOW;
        }
        return ZONE_ORANGE;
    }

    function referenceDeltaPct(metric as Dictionary, value) as Float {
        var reference = metric[:referenceValue].toFloat();
        if (reference == 0.0) {
            return 0.0;
        }
        var delta = (value.toFloat() - reference) / reference;
        if (delta < 0.0) {
            delta = -delta;
        }
        return delta * 100.0;
    }

    function thresholdOr(metric as Dictionary, key, fallbackKey) {
        if (metric.hasKey(key)) {
            return metric[key];
        }

        if (metric.hasKey(fallbackKey)) {
            return metric[fallbackKey];
        }

        return null;
    }

    function inRange(value, minValue, maxValue) {
        if (minValue == null || maxValue == null) {
            return false;
        }
        return value >= minValue && value <= maxValue;
    }

    function zoneRangeText(metric as Dictionary) as String {
        var value = metric[:value];
        var zone = classify(metric);
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return zoneRangeTextLowOnly(metric, zone);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return zoneRangeTextReferenceOnly(metric);
        }

        return zoneRangeTextTarget(metric, zone, value);
    }

    function idealRangeText(metric as Dictionary) as String {
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_LOW_ONLY)) {
            return fmtThreshold(metric[:greenMin]) + "-" + fmtThreshold(metric[:greenMax]);
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            return zoneRangeTextReferenceOnly(metric);
        }

        var greenMin = thresholdOr(metric, :greenMin, :yellowLowMax);
        var greenMax = thresholdOr(metric, :greenMax, :yellowHighMin);
        return fmtThreshold(greenMin) + "-" + fmtThreshold(greenMax);
    }

    function zoneRangeTextTarget(metric as Dictionary, zone as Number, value) as String {
        var greenMin = thresholdOr(metric, :greenMin, :yellowLowMax);
        var greenMax = thresholdOr(metric, :greenMax, :yellowHighMin);
        var yellowLowMin = thresholdOr(metric, :yellowLowMin, :yellowMin);
        var yellowLowMax = thresholdOr(metric, :yellowLowMax, :greenMin);
        var yellowHighMin = thresholdOr(metric, :yellowHighMin, :greenMax);
        var yellowHighMax = thresholdOr(metric, :yellowHighMax, :yellowMax);
        var orangeLowMin = thresholdOr(metric, :orangeLowMin, :orangeMin);
        var orangeLowMax = thresholdOr(metric, :orangeLowMax, :yellowLowMin);
        var orangeHighMin = thresholdOr(metric, :orangeHighMin, :yellowHighMax);
        var orangeHighMax = thresholdOr(metric, :orangeHighMax, :orangeMax);

        if (zone == ZONE_GREEN) {
            return fmtThreshold(greenMin) + "-" + fmtThreshold(greenMax);
        }

        if (zone == ZONE_YELLOW) {
            if (value < greenMin) {
                return fmtThreshold(yellowLowMin) + "-" + fmtThreshold(yellowLowMax);
            }
            return fmtThreshold(yellowHighMin) + "-" + fmtThreshold(yellowHighMax);
        }

        if (zone == ZONE_ORANGE) {
            if (value < greenMin) {
                return fmtThreshold(orangeLowMin) + "-" + fmtThreshold(orangeLowMax);
            }
            return fmtThreshold(orangeHighMin) + "-" + fmtThreshold(orangeHighMax);
        }

        if (orangeLowMin != null && value < orangeLowMin) {
            return "< " + fmtThreshold(orangeLowMin);
        }
        return "> " + fmtThreshold(orangeHighMax);
    }

    function zoneRangeTextLowOnly(metric as Dictionary, zone as Number) as String {
        if (zone == ZONE_GREEN) {
            return fmtThreshold(metric[:greenMin]) + "-" + fmtThreshold(metric[:greenMax]);
        }

        if (zone == ZONE_YELLOW) {
            return fmtThreshold(metric[:yellowMin]) + "-" + fmtThreshold(metric[:greenMin]);
        }

        if (zone == ZONE_ORANGE) {
            return fmtThreshold(metric[:orangeMin]) + "-" + fmtThreshold(metric[:yellowMin]);
        }

        return "< " + fmtThreshold(metric[:orangeMin]);
    }

    function zoneRangeTextReferenceOnly(metric as Dictionary) as String {
        return _locale.text("reference.prefix") + " " + fmtThreshold(metric[:referenceValue]) + " (+/-" + fmtThreshold(metric[:toleranceGoodPct]) + "%)";
    }

    function fmtThreshold(value) as String {
        if (value == null) {
            return "--";
        }
        return fmt1Global(value.toFloat());
    }

    //! Hint testuale per la zona semantica corrente (usato nella UI summary/detail).
    function semanticZoneHint(metric as Dictionary) as String {
        var zone = classify(metric);
        var policy = classificationPolicy(metric);
        var value = metric[:value];

        if (policy.equals(POLICY_LOW_ONLY)) {
            if (zone == ZONE_GREEN) {
                return _locale.text("hint.low_only.green");
            }
            if (zone == ZONE_YELLOW) {
                return _locale.text("hint.low_only.yellow");
            }
            if (zone == ZONE_ORANGE) {
                return _locale.text("hint.low_only.orange");
            }
            return _locale.text("hint.low_only.red");
        }

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return _locale.text("hint.reference.green");
            }
            if (value.toFloat() < metric[:referenceValue].toFloat()) {
                return _locale.text("hint.reference.below");
            }
            return _locale.text("hint.reference.above");
        }

        if (zone == ZONE_GREEN) {
            return _locale.text("hint.target.green");
        }
        if (zone == ZONE_YELLOW) {
            if (value < metric[:greenMin]) {
                return _locale.text("hint.target.yellow_low");
            }
            return _locale.text("hint.target.yellow_high");
        }
        if (zone == ZONE_ORANGE) {
            return _locale.text("hint.target.orange");
        }
        if (value < metric[:greenMin]) {
            return _locale.text("hint.target.red_low");
        }
        return _locale.text("hint.target.red_high");
    }

    function zoneColor(metric as Dictionary, zone as Number) {
        var policy = classificationPolicy(metric);

        if (policy.equals(POLICY_REFERENCE_ONLY)) {
            if (zone == ZONE_GREEN) {
                return 0x66CCFF;
            }
            if (zone == ZONE_YELLOW) {
                return 0x4D99CC;
            }
            return 0x336699;
        }

        if (zone == ZONE_GREEN) {
            return Graphics.COLOR_GREEN;
        }

        if (zone == ZONE_YELLOW) {
            return Graphics.COLOR_YELLOW;
        }

        if (zone == ZONE_ORANGE) {
            return Graphics.COLOR_ORANGE;
        }

        return Graphics.COLOR_RED;
    }
}

//! Round float to 1 decimal place.
function round1Global(v as Float) as Float {
    return Math.round(v * 10.0).toFloat() / 10.0;
}

//! Format float to 1 decimal place.
function fmt1Global(v as Float) as String {
    var scaled = Math.round(round1Global(v) * 10.0).toNumber();
    var whole = scaled / 10;
    var frac = scaled - whole * 10;
    if (frac < 0) { frac = -frac; }
    return whole.toString() + "." + frac.toString();
}
