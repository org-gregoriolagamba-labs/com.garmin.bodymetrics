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
        _trendUseCase.populateHistoryDebug(heightCm, bmrBase);
        // Aggiorna le misurazioni correnti con l'ultimo entry dello storico,
        // marcandole come inserite manualmente alla data odierna.
        var last = _trendUseCase.lastRawEntry();
        if (last != null) {
            // Format: [ts(0), bmi(1), fat%(2), muscleKg(3), muscle%(4), water%(5), boneKg(6), weightKg(7), bmr(8), potenza(9)]
            // Costruisce _measurements direttamente dall'entry — senza passare per Storage,
            // così il peso Garmin non sovrascrive il valore debug (solo in memoria, non persiste).
            var entry = last as Array;
            _measurements = {
                :weightKg     => entry[7] != null ? (entry[7] as Float).toFloat() : null,
                :fatPct       => entry[2] != null ? (entry[2] as Float).toFloat() : null,
                :muscleKg     => entry[3] != null ? (entry[3] as Float).toFloat() : null,
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
        _trendUseCase.clearHistoryDebug();
        _reloadMeasurementsAndRebuildMetrics();
    }

    function hasHistoryEntries() as Boolean {
        return _trendUseCase.hasHistoryEntries();
    }

    function removeLastHistoryEntry() as Void {
        _trendUseCase.removeLastHistoryEntry();
    }

    function disableDebugMode() as Void {
        _trendUseCase.disableDebugMode();
        _reloadMeasurementsAndRebuildMetrics();
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
    var _thresholdFactory;
    var _classificationPolicy;
    var _profileUseCase;
    var _measurementsUseCase;
    var _targetsUseCase;
    var _trendUseCase;
    var _resetUserDataUseCase;

    function initialize() {
        _locale = new BodyMetricsLocale();
        _garminProfile = new BodyMetricsGarminProfile();
        _dataProvider = new BodyMetricsDataProvider(_garminProfile);
        _history = new BodyMetricsHistory();
        _targets = new BodyMetricsTargets();
        _calculators = new BodyMetricsHealthCalculators();
        _thresholdFactory = new BodyMetricsThresholdFactory();
        _classificationPolicy = new BodyMetricsClassificationPolicy(_locale);
        _profileUseCase = new BodyMetricsProfileUseCase(_locale, _garminProfile);
        _measurementsUseCase = new BodyMetricsMeasurementsUseCase(_locale, _dataProvider, _calculators);
        _targetsUseCase = new BodyMetricsTargetsUseCase(_locale, _targets);
        _trendUseCase = new BodyMetricsTrendUseCase(_history);
        _resetUserDataUseCase = new BodyMetricsResetUserDataUseCase(_profileUseCase, _dataProvider, _targetsUseCase, _history);
        _hasStoredProfile = false;
        _profile = loadProfile();
        _measurements = _dataProvider.loadMeasurements();
        rebuildMetrics();
        // Record snapshot on startup to capture any Garmin data changes
        if (_dataProvider.hasAnyMeasurements()) {
            _trendUseCase.recordSnapshot(_metrics as Array);
        }
    }

    // --- Data provider access ---

    function lastUpdateDateLabel() as String {
        return _measurementsUseCase.lastUpdateDateLabel();
    }

    function measurementFields() as Array {
        return _measurementsUseCase.measurementFields();
    }

    function measurementFieldCount() as Number {
        return _measurementsUseCase.measurementFieldCount();
    }

    function measurementFieldDefinition(index as Number) as Dictionary {
        return _measurementsUseCase.measurementFieldDefinition(index);
    }

    function currentMeasurements() as Dictionary {
        return _measurementsUseCase.currentMeasurements(_measurements, _profile);
    }

    function cycleMeasurementField(draft as Dictionary, index as Number, delta as Number) as Dictionary {
        return _measurementsUseCase.cycleMeasurementField(draft, index, delta, _profile);
    }

    function measurementFieldValueLabel(draft as Dictionary, index as Number) as String {
        return _measurementsUseCase.measurementFieldValueLabel(draft, index);
    }

    function saveMeasurements(draft as Dictionary) as Void {
        _measurements = _measurementsUseCase.saveMeasurements(draft);
        rebuildMetrics();
        _trendUseCase.recordSnapshot(_metrics as Array);
    }

    // --- Personalized targets ---

    function targetFieldDefinitions() as Array {
        return _targetsUseCase.targetFieldDefinitions();
    }

    function targetFieldCount() as Number {
        return _targetsUseCase.targetFieldCount();
    }

    function targetFieldDefinition(index as Number) as Dictionary {
        return _targetsUseCase.targetFieldDefinition(index);
    }

    function currentTargets() as Dictionary {
        return _targetsUseCase.currentTargets(_metrics as Array);
    }

    function cycleTargetField(draft as Dictionary, index as Number, delta as Number) as Dictionary {
        return _targetsUseCase.cycleTargetField(draft, index, delta);
    }

    function targetFieldValueLabel(draft as Dictionary, index as Number) as String {
        return _targetsUseCase.targetFieldValueLabel(draft, index);
    }

    function saveTargets(draft as Dictionary) as Void {
        _targetsUseCase.saveTargets(draft);
    }

    function clearMeasurements() as Void {
        _dataProvider.clearStoredMeasurements();
        _reloadMeasurementsAndRebuildMetrics();
    }

    function clearMeasurementField(fieldIndex as Number) as Void {
        var field = _measurementsUseCase.measurementFieldDefinition(fieldIndex) as Dictionary<Symbol, Object>;
        if (field.get(:readOnly) as Boolean? == true) {
            return;
        }
        _dataProvider.clearMeasurementFieldByKey(field.get(:key) as Symbol?);
        _reloadMeasurementsAndRebuildMetrics();
    }

    function isMeasurementFieldReadOnly(fieldIndex as Number) as Boolean {
        var field = _measurementsUseCase.measurementFieldDefinition(fieldIndex) as Dictionary<Symbol, Object>;
        return (field.get(:readOnly) as Boolean?) == true;
    }

    function clearTargetField(fieldIndex as Number) as Void {
        _targetsUseCase.clearTargetField(fieldIndex);
    }

    function resetAllTargets() as Void {
        _targetsUseCase.resetAllTargets();
    }

    function resetAllUserData() as Void {
        var resetState = _resetUserDataUseCase.resetAllUserData() as Dictionary<Symbol, Object>;
        _hasStoredProfile = resetState.get(:hasStoredProfile) as Boolean?;
        _profile = resetState.get(:profile) as Dictionary?;
        _measurements = resetState.get(:measurements) as Dictionary?;
        rebuildMetrics();
    }

    function effectiveTargetForMetric(metric as Dictionary) {
        return _targetsUseCase.effectiveTargetForMetric(metric);
    }

    function getEffectiveTargetForIndex(metricIndex as Number) {
        return _targetsUseCase.getEffectiveTargetForMetric(metricAt(metricIndex));
    }

    function getDeltaToTargetForIndex(metricIndex as Number) {
        var metric = metricAt(metricIndex);
        return _targetsUseCase.getDeltaToTargetForMetric(metric, classificationPolicy(metric).toString());
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

    function historyValues(metricIndex as Number, windowDays as Number) as Array {
        return _trendUseCase.historyValues(metricIndex, windowDays);
    }

    function refreshDerivedMeasurementFields(draft as Dictionary) as Dictionary {
        return _measurementsUseCase.refreshDerivedMeasurementFields(draft, _profile);
    }

    function derivedBmrValueForDraft(draft as Dictionary) {
        return _measurementsUseCase.derivedBmrValueForDraft(draft, _profile);
    }

    function loadProfile() as Dictionary {
        var loaded = _profileUseCase.loadProfile() as Dictionary<Symbol, Object>;
        _hasStoredProfile = loaded.get(:hasStoredProfile) as Boolean?;
        return loaded.get(:profile) as Dictionary?;
    }

    function sanitizeProfile(profile as Dictionary) as Dictionary {
        return _profileUseCase.sanitizeProfile(profile);
    }

    function currentProfile() as Dictionary {
        return _profileUseCase.currentProfile(_profile);
    }

    function hasConfiguredProfile() as Boolean {
        return _profileUseCase.hasConfiguredProfile();
    }

    function saveProfile(profile as Dictionary) as Void {
        _profile = _profileUseCase.saveProfile(profile);
        _hasStoredProfile = true;
        rebuildMetrics();
        _trendUseCase.recordSnapshot(_metrics as Array);
    }

    function profileFields() as Array {
        return _profileUseCase.profileFields();
    }

    function profileFieldCount() as Number {
        return _profileUseCase.profileFieldCount();
    }

    function profileFieldDefinition(index as Number) as Dictionary {
        return _profileUseCase.profileFieldDefinition(index);
    }

    function cycleProfileField(profile as Dictionary, index as Number, delta as Number) as Dictionary {
        return _profileUseCase.cycleProfileField(profile, index, delta);
    }

    function profileFieldValueLabel(profile as Dictionary, index as Number) as String {
        return _profileUseCase.profileFieldValueLabel(profile, index);
    }

    hidden function _reloadMeasurementsAndRebuildMetrics() as Void {
        _measurements = _dataProvider.loadMeasurements();
        rebuildMetrics();
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

        // Muscle kg - entered directly by user (Garmin Index Smart Scale provides kg).
        // Source is manual body comp input.
        if (measurements[:muscleKg] != null) {
            var m = buildLowOnlyMetric(
                "muscle_kg", "Massa muscolare", "kg", measurements[:muscleKg],
                muscleKgBand[:greenMin], muscleKgBand[:greenMax],
                muscleKgBand[:yellowMin], muscleKgBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("muscle_kg", "Massa muscolare", "kg"));
        }

        // Muscle% - derived from muscle_kg / weight_kg (no longer entered manually).
        if (measurements[:musclePct] != null) {
            var m = buildLowOnlyMetric(
                "muscle_pct", "Muscoli %", "%", measurements[:musclePct],
                musclePctBand[:greenMin], musclePctBand[:greenMax],
                musclePctBand[:yellowMin], musclePctBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = SOURCE_CALC_MANUAL;
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

        // Potenza muscolare stimata (W) = muscle_kg × 35.
        // Basata sulla potenza specifica del muscolo scheletrico misto (~35 W/kg)
        // (McArdle, Katch & Katch, Exercise Physiology, 8th ed.; Fitts & Widrick, 1996).
        var potenzaBand = potenzaRange(profile);
        if (measurements[:muscleKg] != null) {
            var m = buildLowOnlyMetric(
                "potenza", "Potenza musc.", "W", calculatePotenza(measurements[:muscleKg].toFloat()),
                potenzaBand[:greenMin], potenzaBand[:greenMax],
                potenzaBand[:yellowMin], potenzaBand[:orangeMin]
            );
            m[:available] = true;
            m[:source] = bodySrc;
            metrics.add(m);
        } else {
            metrics.add(unavailableMetric("potenza", "Potenza musc.", "W"));
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
        return _thresholdFactory.bmiTargetRange(profile);
    }

    function fatPctRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.fatPctRange(profile);
    }

    function muscleKgRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.muscleKgRange(profile);
    }

    function musclePctRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.musclePctRange(profile);
    }

    function waterPctRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.waterPctRange(profile);
    }

    function boneKgRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.boneKgRange(profile);
    }

    function weightTargetRange(profile as Dictionary, bmiRange as Dictionary) as Dictionary {
        return _thresholdFactory.weightTargetRange(profile, bmiRange);
    }

    function buildTargetThresholds(greenMin as Float, greenMax as Float, lowStepYellow as Float, lowStepOrange as Float, highStepYellow as Float, highStepOrange as Float) as Dictionary {
        return _thresholdFactory.buildTargetThresholds(greenMin, greenMax, lowStepYellow, lowStepOrange, highStepYellow, highStepOrange);
    }

    function buildTargetMetricThresholds(greenMin, greenMax, yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax, orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax) as Dictionary {
        return _thresholdFactory.buildTargetMetricThresholds(greenMin, greenMax, yellowLowMin, yellowLowMax, yellowHighMin, yellowHighMax, orangeLowMin, orangeLowMax, orangeHighMin, orangeHighMax);
    }

    function buildLowThresholds(greenMin as Float, greenMax as Float, yellowStep as Float, orangeStep as Float) as Dictionary {
        return _thresholdFactory.buildLowThresholds(greenMin, greenMax, yellowStep, orangeStep);
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

    function calculatePotenza(muscleKg as Float) as Float {
        return _calculators.calculatePotenza(muscleKg);
    }

    function potenzaRange(profile as Dictionary) as Dictionary {
        return _thresholdFactory.potenzaRange(profile);
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

    //! Development helper: returns i18n missing-key report vs English.
    function validateLocaleCatalogDebug() as Dictionary {
        return _locale.validateCatalogMissingKeys();
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

        if (metricId.equals("fat_pct") || metricId.equals("muscle_kg") || metricId.equals("muscle_pct") || metricId.equals("potenza")) {
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
        return _classificationPolicy.classify(metric);
    }

    function classificationPolicy(metric as Dictionary) {
        return _classificationPolicy.classificationPolicy(metric);
    }

    function classifyTargetRange(metric as Dictionary, value) {
        return _classificationPolicy.classifyTargetRange(metric, value);
    }

    function classifyLowOnly(metric as Dictionary, value) {
        return _classificationPolicy.classifyLowOnly(metric, value);
    }

    function classifyReferenceOnly(metric as Dictionary, value) {
        return _classificationPolicy.classifyReferenceOnly(metric, value);
    }

    function referenceDeltaPct(metric as Dictionary, value) as Float {
        return _classificationPolicy.referenceDeltaPct(metric, value);
    }

    function thresholdOr(metric as Dictionary, key, fallbackKey) {
        return _classificationPolicy._thresholdOr(metric, key, fallbackKey);
    }

    function inRange(value, minValue, maxValue) {
        return _classificationPolicy._inRange(value, minValue, maxValue);
    }

    function zoneRangeText(metric as Dictionary) as String {
        return _classificationPolicy.zoneRangeText(metric);
    }

    function idealRangeText(metric as Dictionary) as String {
        return _classificationPolicy.idealRangeText(metric);
    }

    function zoneRangeTextTarget(metric as Dictionary, zone as Number, value) as String {
        return _classificationPolicy.zoneRangeTextTarget(metric, zone, value);
    }

    function zoneRangeTextLowOnly(metric as Dictionary, zone as Number) as String {
        return _classificationPolicy.zoneRangeTextLowOnly(metric, zone);
    }

    function zoneRangeTextReferenceOnly(metric as Dictionary) as String {
        return _classificationPolicy.zoneRangeTextReferenceOnly(metric);
    }

    function fmtThreshold(value) as String {
        return _classificationPolicy._fmtThreshold(value);
    }

    //! Hint testuale per la zona semantica corrente (usato nella UI summary/detail).
    function semanticZoneHint(metric as Dictionary) as String {
        return _classificationPolicy.semanticZoneHint(metric);
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
