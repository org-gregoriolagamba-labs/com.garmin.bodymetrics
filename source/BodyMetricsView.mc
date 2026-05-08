import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

class BodyMetricsView extends WatchUi.View {

    const TREND_WINDOWS = [7, 30, 90];

    //! DEBUG: Popola la history con dati casuali per test
    function populateHistoryDebug() as Void {
        _domain.populateHistoryDebug();
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("debug.history_populated"), 2000);
        WatchUi.requestUpdate();
    }

    //! DEBUG: Cancella la history
    function clearHistoryDebug() as Void {
        _domain.clearHistoryDebug();
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("debug.history_cleared"), 2000);
        WatchUi.requestUpdate();
    }

    //! DEBUG: Validate locale completeness against English keys.
    function validateLocaleDebug() as Void {
        var report = _domain.validateLocaleCatalogDebug() as Dictionary;
        var totalMissing = report[:totalMissing].toNumber();
        var counts = report[:counts] as Dictionary;

        var itMissing = counts["it"].toNumber();
        var frMissing = counts["fr"].toNumber();
        var esMissing = counts["es"].toNumber();

        System.println("[BodyMetrics][i18n] Missing keys vs en: total="
            + totalMissing.toString()
            + " (it=" + itMissing.toString()
            + ", fr=" + frMissing.toString()
            + ", es=" + esMissing.toString() + ")");

        if (totalMissing == 0) {
            showFeedbackBadge("Locale OK", 2200);
        } else {
            showFeedbackBadge("Locale -" + totalMissing.toString(), 2600);
        }
    }

    //! DEBUG: Toggle debug mode on/off
    function toggleDebugMode() as Boolean {
        if (_debugEnabled) {
            _domain.disableDebugMode();
            _invalidateTrendCache();
            _cacheTrendData();
            WatchUi.requestUpdate();
        }
        _debugEnabled = !_debugEnabled;
        return _debugEnabled;
    }

    function isDebugEnabled() as Boolean {
        return _debugEnabled;
    }

    const MODE_SUMMARY = 0;
    const MODE_INFO = 1;
    const MODE_DETAIL = 2;
    const MODE_SETUP = 3;
    const MODE_DATA = 4;
    const MODE_TREND = 5;
    const MODE_TARGET = 6;
    const MODE_TARGET_DELTA = 7;

    var _mode;
    var _selectedMetric;
    var _domain;
    var _animPhase;
    var _animTimer;
    var _setupIndex;
    var _profileDraft;
    var _pendingMenuAction;
    var _dataIndex;
    var _dataDraft;
    var _targetIndex;
    var _targetDraft;
    var _trendWindow;
    var _trendDirection;
    var _trendValues;
    var _trendCacheService;
    var _trendRenderer;
    var _wizardRenderer;
    var _summaryDetailRenderer;
    var _infoTargetDeltaRenderer;
    var _infoScrollY;           // Scroll offset for info screen
    var _infoContentH;           // Total content height for info screen
    var _infoIconCx;             // (i) icon center X for tap detection
    var _infoIconCy;             // (i) icon center Y for tap detection
    var _infoIconR;              // (i) icon radius for tap detection
    var _debugEnabled = false;  // Debug menu: impostare a true solo durante lo sviluppo
    var _reopenDataMenuAfterExit = false; // Dopo azione Data submenu, riapri il submenu
    var _feedbackBadgeText as String;
    var _feedbackBadgeUntil as Number;
    function initialize() {
        View.initialize();
        _mode = MODE_SUMMARY;
        _selectedMetric = 0;
        _domain = new BodyMetricsDomain();
        _animPhase = 0;
        _animTimer = null;
        _setupIndex = 0;
        _profileDraft = _domain.currentProfile();
        _pendingMenuAction = null;
        _reopenDataMenuAfterExit = false;
        _dataIndex = 0;
        _dataDraft = _domain.currentMeasurements();
        _targetIndex = 0;
        _targetDraft = _domain.currentTargets();
        _trendWindow = 0;
        _trendDirection = TREND_FLAT;
        _trendValues = [];
        _trendCacheService = new BodyMetricsTrendCacheService(TREND_WINDOWS);
        _trendRenderer = new BodyMetricsTrendRenderer();
        _wizardRenderer = new BodyMetricsWizardRenderer();
        _summaryDetailRenderer = new BodyMetricsSummaryDetailRenderer();
        _infoTargetDeltaRenderer = new BodyMetricsInfoTargetDeltaRenderer();
        _infoScrollY = 0;
        _infoContentH = 0;
        _infoIconCx = -100;
        _infoIconCy = -100;
        _infoIconR = 0;
        _feedbackBadgeText = "";
        _feedbackBadgeUntil = 0;

        if (!_domain.hasConfiguredProfile()) {
            enterSetupMode();
        }
    }

    function onShow() as Void {
        if (_animTimer != null) {
            _animTimer.stop();
        }
        _animTimer = new Timer.Timer();
        _animTimer.start(method(:onAnimTick), 1500, true);

        if (_pendingMenuAction != null) {
            var pendingAction = _pendingMenuAction;
            _pendingMenuAction = null;
            if (pendingAction == :openLanguageMenu) {
                openLanguageMenu();
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (_mode == MODE_SETUP) {
            drawSetup(dc);
        } else if (_mode == MODE_DATA) {
            drawDataEntry(dc);
        } else if (_mode == MODE_TARGET) {
            drawTargetEditor(dc);
        } else if (_mode == MODE_TARGET_DELTA) {
            drawTargetDelta(dc);
        } else if (_mode == MODE_INFO) {
            drawInfo(dc);
        } else if (_mode == MODE_SUMMARY) {
            drawSummary(dc);
        } else if (_mode == MODE_TREND) {
            drawTrend(dc);
        } else {
            drawDetail(dc);
        }

        drawFeedbackBadge(dc);
    }

    function onHide() as Void {
        if (_animTimer != null) {
            _animTimer.stop();
            _animTimer = null;
        }
    }

    function onAnimTick() as Void {
        _animPhase = (_animPhase + 1) % 2;
        WatchUi.requestUpdate();
    }

    // --- Navigation ---

    function enterSetupMode() as Void {
        _profileDraft = _domain.currentProfile();
        _setupIndex = 0;
        _mode = MODE_SETUP;
    }

    function openProfileSetup() as Void {
        enterSetupMode();
        WatchUi.requestUpdate();
    }

    function openDataEntry() as Void {
        _dataDraft = _domain.currentMeasurements();
        _dataIndex = 0;
        _mode = MODE_DATA;
        WatchUi.requestUpdate();
    }

    function openTargetEditor() as Void {
        _targetDraft = _domain.currentTargets();
        _targetIndex = 0;
        _mode = MODE_TARGET;
        WatchUi.requestUpdate();
    }

    function openMetricInfo() as Void {
        _infoScrollY = 0;
        _infoContentH = 0;
        _mode = MODE_INFO;
        WatchUi.requestUpdate();
    }

    function isSummaryMode() as Boolean {
        return _mode == MODE_SUMMARY;
    }

    function logBackInputEvent(pressTypeName as String, decision as String) as Void {
        System.println("[BodyMetrics][BACK][Input] pressType=" + pressTypeName
            + " mode=" + _modeName(_mode)
            + "(" + _mode.toString() + ")"
            + " decision=" + decision);
    }

    function handleSwipeUp() as Void {
        // In editor touch mode, swipe-up should increase values.
        if (_mode == MODE_DATA || _mode == MODE_TARGET) {
            previousMetric();
            return;
        }
        nextMetric();
    }

    function handleSwipeDown() as Void {
        // In editor touch mode, swipe-down should decrease values.
        if (_mode == MODE_DATA || _mode == MODE_TARGET) {
            nextMetric();
            return;
        }
        previousMetric();
    }

    function openSystemInfo() as Void {
        var lines = [
            {:label => text("sysinfo.app"),     :value => "BodyMetrics"},
            {:label => text("sysinfo.version"),  :value => "1.0.0"},
            {:label => text("sysinfo.release"),  :value => "22 apr 2026"},
            {:label => text("sysinfo.author"),   :value => "BodyMetrics Team"}
        ] as Array;
        var systemView = new BodyMetricsBadgeInfoView(text("sysinfo.title"), lines);
        WatchUi.pushView(systemView, new BodyMetricsBadgeInfoDelegate(systemView), WatchUi.SLIDE_UP);
    }

    function canOpenMenu() as Boolean {
        return true;
    }

    //! Routes the MENU key: contextual field menu in wizard modes, main menu otherwise.
    function openMenu() as Void {
        if (_mode == MODE_DATA) {
            if (!_domain.isMeasurementFieldReadOnly(_dataIndex)) {
                var items = [{:label => text("menu.field_clear"), :id => :field_clear}];
                var ctxView = new BodyMetricsMenuView(text("menu.field_options"), items);
                WatchUi.pushView(ctxView, new BodyMetricsFieldContextMenuDelegate(ctxView, self, :data), WatchUi.SLIDE_UP);
            }
            return;
        }
        if (_mode == MODE_TARGET) {
            var items = [{:label => text("menu.target_reset_field"), :id => :target_reset_field}];
            var ctxView = new BodyMetricsMenuView(text("menu.field_options"), items);
            WatchUi.pushView(ctxView, new BodyMetricsFieldContextMenuDelegate(ctxView, self, :target), WatchUi.SLIDE_UP);
            return;
        }
        if (_mode == MODE_TREND && _domain.hasHistoryEntries()) {
            var items = [{:label => text("menu.history_remove_last"), :id => :history_remove_last}];
            var ctxView = new BodyMetricsMenuView(text("menu.field_options"), items);
            WatchUi.pushView(ctxView, new BodyMetricsFieldContextMenuDelegate(ctxView, self, :trend), WatchUi.SLIDE_UP);
            return;
        }
        _openMainMenu();
    }

    function _openMainMenu() as Void {
        var items = [] as Array;
        items.add({:label => text("menu.cat.data"), :id => :data_management});
        items.add({:label => text("menu.cat.options"), :id => :options});
        items.add({:label => text("menu.cat.info"), :id => :information});
        if (DEBUG) {
            items.add({:label => text("debug.menu.title"), :id => :debug});
        }
        var menuView = new BodyMetricsMenuView(text("menu.title"), items);
        WatchUi.pushView(menuView, new BodyMetricsCustomMenuDelegate(menuView, self), WatchUi.SLIDE_UP);
    }

    function clearCurrentMeasurementField() as Void {
        _domain.clearMeasurementField(_dataIndex);
        _dataDraft = _domain.currentMeasurements();
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("menu.field_cleared"), 2000);
        WatchUi.requestUpdate();
    }

    function clearCurrentTargetField() as Void {
        _domain.clearTargetField(_targetIndex);
        _targetDraft = _domain.currentTargets();
        showFeedbackBadge(text("menu.target_field_reset"), 2000);
        WatchUi.requestUpdate();
    }

    function removeLastHistoryEntryWithFeedback() as Void {
        _domain.removeLastHistoryEntry();
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("menu.history_entry_removed"), 2000);
        WatchUi.requestUpdate();
    }

    //! Check if a screen tap hits the (i) info icon
    function isInfoIconTap(x as Number, y as Number) as Boolean {
        if (_mode != MODE_SUMMARY) { return false; }
        var dx = x - _infoIconCx;
        var dy = y - _infoIconCy;
        var tapR = _infoIconR + 8;  // generous tap target
        return (dx * dx + dy * dy) <= (tapR * tapR);
    }

    function text(key as String) as String {
        return _domain.text(key);
    }

    function currentLanguage() as String {
        return _domain.currentLanguage();
    }

    function supportedLanguages() as Array {
        return _domain.supportedLanguages();
    }

    function languageLabel(language as String) as String {
        return _domain.languageLabel(language);
    }

    function languageMenuLabel() as String {
        return text("menu.language");
    }

    function setLanguage(language as String) as Void {
        _domain.setLanguage(language);
        WatchUi.requestUpdate();
    }

    function requestDataMenuOnExit() as Void {
        _reopenDataMenuAfterExit = true;
    }

    function _resumeAfterWizardExit() as Boolean {
        if (_reopenDataMenuAfterExit) {
            _reopenDataMenuAfterExit = false;
            WatchUi.requestUpdate();
            openDataMenu();
            return true;
        }
        WatchUi.requestUpdate();
        return false;
    }

    function clearMeasurementsWithFeedback() as Void {
        _domain.clearMeasurements();
        _dataDraft = _domain.currentMeasurements();
        _dataIndex = 0;
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("menu.data_cleared"), 2200);
        WatchUi.requestUpdate();
    }

    function clearTargetsWithFeedback() as Void {
        _domain.resetAllTargets();
        _targetDraft = _domain.currentTargets();
        _targetIndex = 0;
        showFeedbackBadge(text("menu.targets_cleared"), 2200);
        WatchUi.requestUpdate();
    }

    function resetAllDataWithFeedback() as Void {
        _domain.resetAllUserData();
        _profileDraft = _domain.currentProfile();
        _dataDraft = _domain.currentMeasurements();
        _targetDraft = _domain.currentTargets();
        _setupIndex = 0;
        _dataIndex = 0;
        _targetIndex = 0;
        _selectedMetric = 0;
        _mode = _domain.hasConfiguredProfile() ? MODE_SUMMARY : MODE_SETUP;
        _invalidateTrendCache();
        _cacheTrendData();
        showFeedbackBadge(text("menu.reset_done"), 2200);
        WatchUi.requestUpdate();
    }

    function showFeedbackBadge(label as String, durationMs as Number) as Void {
        _feedbackBadgeText = label;
        _feedbackBadgeUntil = System.getTimer() + durationMs;
        WatchUi.requestUpdate();
    }

    function drawFeedbackBadge(dc as Dc) as Void {
        if (_feedbackBadgeText.equals("")) {
            return;
        }
        if (System.getTimer() > _feedbackBadgeUntil) {
            _feedbackBadgeText = "";
            _feedbackBadgeUntil = 0;
            return;
        }

        var w = dc.getWidth();
        var h = dc.getHeight();
        var font = Graphics.FONT_XTINY;
        var padX = 10;
        var padY = 4;
        var textW = dc.getTextWidthInPixels(_feedbackBadgeText, font);
        var badgeW = textW + (padX * 2);
        var badgeH = dc.getFontHeight(font) + (padY * 2);
        var x = (w - badgeW) / 2;
        var y = (h - badgeH) / 2;

        dc.setColor(0x2A5A2A, 0x2A5A2A);
        dc.fillRoundedRectangle(x, y, badgeW, badgeH, badgeH / 2);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, y + padY, font, _feedbackBadgeText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function openDataMenu() as Void {
        var items = [] as Array;
        items.add({:label => text("menu.profile"), :id => :profile});
        items.add({:label => text("menu.data"), :id => :data});
        items.add({:label => text("menu.targets"), :id => :targets});
        var subView = new BodyMetricsMenuView(text("menu.cat.data"), items);
        // 1 pop: solo il data submenu (aperto direttamente, senza main menu sotto)
        WatchUi.pushView(subView, new BodyMetricsDataMenuDelegate(subView, self, 1), WatchUi.SLIDE_UP);
    }

    function openLanguageMenu() as Void {
        var items = [] as Array;
        var codes = supportedLanguages();
        for (var i = 0; i < codes.size(); i += 1) {
            var language = codes[i].toString();
            items.add({:label => languageOptionLabel(language), :id => languageSymbol(language)});
        }
        var menuView = new BodyMetricsMenuView(languageMenuLabel(), items);
        WatchUi.pushView(menuView, new BodyMetricsCustomLanguageMenuDelegate(menuView, self), WatchUi.SLIDE_UP);
    }

    function languageOptionLabel(language as String) as String {
        if (language.equals(currentLanguage())) {
            return "* " + languageLabel(language);
        }
        return languageLabel(language);
    }

    function languageSymbol(language as String) as Symbol {
        if (language.equals("en")) {
            return :lang_en;
        }
        if (language.equals("fr")) {
            return :lang_fr;
        }
        if (language.equals("es")) {
            return :lang_es;
        }
        return :lang_it;
    }

    function nextMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, -1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_DATA) {
            _dataDraft = _domain.cycleMeasurementField(_dataDraft, _dataIndex, -1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_TARGET) {
            _targetDraft = _domain.cycleTargetField(_targetDraft, _targetIndex, -1);
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_INFO) {
            _infoScrollY += 30;
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_TREND) {
            _cycleTrendWindow(1);
            WatchUi.requestUpdate();
            return;
        }

        _selectedMetric = (_selectedMetric + 1) % _domain.metricsCount();
        WatchUi.requestUpdate();
    }

    function previousMetric() as Void {
        if (_mode == MODE_SETUP) {
            _profileDraft = _domain.cycleProfileField(_profileDraft, _setupIndex, 1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_DATA) {
            _dataDraft = _domain.cycleMeasurementField(_dataDraft, _dataIndex, 1);
            WatchUi.requestUpdate();
            return;
        }
        if (_mode == MODE_TARGET) {
            _targetDraft = _domain.cycleTargetField(_targetDraft, _targetIndex, 1);
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_INFO) {
            _infoScrollY -= 30;
            if (_infoScrollY < 0) { _infoScrollY = 0; }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_TREND) {
            _cycleTrendWindow(-1);
            WatchUi.requestUpdate();
            return;
        }

        _selectedMetric = (_selectedMetric - 1 + _domain.metricsCount()) % _domain.metricsCount();
        WatchUi.requestUpdate();
    }

    function toggleMode() as Void {
        if (_mode == MODE_SETUP) {
            if (_setupIndex < _domain.profileFieldCount() - 1) {
                _setupIndex += 1;
            } else {
                _domain.saveProfile(_profileDraft);
                _invalidateTrendCache();
                _mode = MODE_SUMMARY;
                _selectedMetric = 0;
                if (_resumeAfterWizardExit()) { return; }
            }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_DATA) {
            if (_dataIndex < _domain.measurementFieldCount() - 1) {
                _dataIndex += 1;
            } else {
                _domain.saveMeasurements(_dataDraft);
                _invalidateTrendCache();
                _mode = MODE_SUMMARY;
                _selectedMetric = 0;
                if (_resumeAfterWizardExit()) { return; }
            }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_TARGET) {
            if (_targetIndex < _domain.targetFieldCount() - 1) {
                _targetIndex += 1;
            } else {
                _domain.saveTargets(_targetDraft);
                _mode = MODE_SUMMARY;
                _selectedMetric = 0;
                if (_resumeAfterWizardExit()) { return; }
            }
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_INFO) {
            _mode = MODE_SUMMARY;
            WatchUi.requestUpdate();
            return;
        }

        if (_mode == MODE_SUMMARY) {
            _mode = MODE_DETAIL;
        } else if (_mode == MODE_DETAIL) {
            _mode = MODE_TARGET_DELTA;
        } else if (_mode == MODE_TARGET_DELTA) {
            _mode = MODE_TREND;
            _cacheTrendData();
        } else {
            _mode = MODE_SUMMARY;
        }
        WatchUi.requestUpdate();
    }

    function handleBack() as Boolean {
        _logBackPath("enter", true);

        if (_mode == MODE_SETUP) {
            if (_setupIndex > 0) {
                _setupIndex -= 1;
                _logBackPath("setup_prev_step", true);
            } else if (_resumeAfterWizardExit()) {
                _logBackPath("setup_resume_after_exit", true);
                return true;
            } else if (_domain.hasConfiguredProfile()) {
                _mode = MODE_SUMMARY;
                _logBackPath("setup_to_summary", true);
                if (_resumeAfterWizardExit()) {
                    _logBackPath("setup_resume_after_summary", true);
                    return true;
                }
            } else {
                // First setup step with no saved profile: let the system handle BACK (exit app).
                _logBackPath("setup_first_step_system_default", false);
                return false;
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_DATA) {
            if (_dataIndex > 0) {
                _dataIndex -= 1;
                _logBackPath("data_prev_step", true);
            } else {
                if (_resumeAfterWizardExit()) {
                    _logBackPath("data_resume_after_exit", true);
                    return true;
                }
                _mode = MODE_SUMMARY;
                _logBackPath("data_to_summary", true);
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_TARGET) {
            if (_targetIndex > 0) {
                _targetIndex -= 1;
                _logBackPath("target_prev_step", true);
            } else {
                if (_resumeAfterWizardExit()) {
                    _logBackPath("target_resume_after_exit", true);
                    return true;
                }
                _mode = MODE_SUMMARY;
                _logBackPath("target_to_summary", true);
            }
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_INFO) {
            _mode = MODE_SUMMARY;
            _logBackPath("info_to_summary", true);
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_DETAIL) {
            _mode = MODE_SUMMARY;
            _logBackPath("detail_to_summary", true);
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_TREND) {
            _mode = MODE_TARGET_DELTA;
            _logBackPath("trend_to_target_delta", true);
            WatchUi.requestUpdate();
            return true;
        }

        if (_mode == MODE_TARGET_DELTA) {
            _mode = MODE_DETAIL;
            _logBackPath("target_delta_to_detail", true);
            WatchUi.requestUpdate();
            return true;
        }

        // Summary/root state: let the system handle BACK (exit app).
        _logBackPath("root_system_default", false);
        return false;
    }

    function _logBackPath(path as String, consumed as Boolean) as Void {
        var consumedText = consumed ? "true" : "false";
        System.println("[BodyMetrics][BACK][View] mode=" + _modeName(_mode)
            + "(" + _mode.toString() + ")"
            + " path=" + path
            + " consumed=" + consumedText);
    }

    function _modeName(modeValue as Number) as String {
        if (modeValue == MODE_SUMMARY) { return "MODE_SUMMARY"; }
        if (modeValue == MODE_INFO) { return "MODE_INFO"; }
        if (modeValue == MODE_DETAIL) { return "MODE_DETAIL"; }
        if (modeValue == MODE_SETUP) { return "MODE_SETUP"; }
        if (modeValue == MODE_DATA) { return "MODE_DATA"; }
        if (modeValue == MODE_TREND) { return "MODE_TREND"; }
        if (modeValue == MODE_TARGET) { return "MODE_TARGET"; }
        if (modeValue == MODE_TARGET_DELTA) { return "MODE_TARGET_DELTA"; }
        return "MODE_UNKNOWN";
    }

    function drawSetup(dc as Dc) as Void {
        _wizardRenderer.drawSetup(dc, {
            :domain => _domain,
            :setupIndex => _setupIndex,
            :profileDraft => _profileDraft,
            :titleText => _domain.hasConfiguredProfile() ? text("setup.edit_profile") : text("setup.configure_profile"),
            :saveHint => text("setup.select_save"),
            :nextHint => text("setup.select_next")
        });
    }

    function drawDataEntry(dc as Dc) as Void {
        _wizardRenderer.drawDataEntry(dc, {
            :domain => _domain,
            :dataIndex => _dataIndex,
            :dataDraft => _dataDraft,
            :titleText => text("data.title"),
            :saveHint => text("data.select_save"),
            :nextHint => text("data.select_next")
        });
    }

    function drawTargetEditor(dc as Dc) as Void {
        _wizardRenderer.drawTargetEditor(dc, {
            :domain => _domain,
            :targetIndex => _targetIndex,
            :targetDraft => _targetDraft,
            :titleText => text("target.title"),
            :saveHint => text("target.select_save"),
            :nextHint => text("target.select_next")
        });
    }

    function manualDateText(metric as Dictionary) as String {
        if (!metric[:available] || metric[:source] == null) {
            return "";
        }
        var date = _domain.lastUpdateDateLabel();
        if (date != null && date.length() > 0) {
            return text("summary.updated_on") + date;
        }
        return "";
    }

    // --- Summary Screen (fully responsive) ---

    function drawSummary(dc as Dc) as Void {
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        var icon = _summaryDetailRenderer.drawSummary(dc, {
            :domain => _domain,
            :selectedMetric => _selectedMetric,
            :animPhase => _animPhase,
            :hintUnavailableText => text("hint.unavailable"),
            :dateText => manualDateText(metric)
        }) as Dictionary;

        _infoIconCx = icon[:iconX].toNumber();
        _infoIconCy = icon[:iconY].toNumber();
        _infoIconR = icon[:iconR].toNumber();
    }

    function drawInfo(dc as Dc) as Void {
        var state = _infoTargetDeltaRenderer.drawInfo(dc, {
            :domain => _domain,
            :selectedMetric => _selectedMetric,
            :infoScrollY => _infoScrollY
        }) as Dictionary;

        _infoScrollY = state[:infoScrollY].toNumber();
        _infoContentH = state[:infoContentH].toNumber();
    }

    // --- Detail Screen (fully responsive) ---

    function drawDetail(dc as Dc) as Void {
        _summaryDetailRenderer.drawDetail(dc, {
            :domain => _domain,
            :selectedMetric => _selectedMetric,
            :hintUnavailableText => text("hint.unavailable"),
            :detailIdealPrefix => text("detail.ideal")
        });
    }

    // --- Target Delta Screen ---

    function drawTargetDelta(dc as Dc) as Void {
        _infoTargetDeltaRenderer.drawTargetDelta(dc, {
            :domain => _domain,
            :selectedMetric => _selectedMetric,
            :targetViewTitleText => text("target.view.title"),
            :targetCurrentText => text("target.current"),
            :targetLabelText => text("target.label"),
            :targetDeltaAbsText => text("target.delta_abs"),
            :targetDisclaimerText => text("target.disclaimer"),
            :targetUnavailableText => text("target.unavailable"),
            :hintUnavailableText => text("hint.unavailable")
        });
    }

    // --- Formatting ---

    function formatValue(metric as Dictionary) as String {
        if (!metric[:available]) {
            return "--";
        }
        return fmt1Global(metric[:value].toFloat());
    }

    // --- Trend Screen ---

    function _invalidateTrendCache() as Void {
        _trendCacheService.invalidate();
        _trendWindow = 0;
    }

    //! Cache trend data for the currently selected metric.
    function _cacheTrendData() as Void {
        var trendState = _trendCacheService.cacheTrendData(_domain, _selectedMetric, _trendWindow);
        _applyTrendState(trendState as Dictionary);
    }

    function _cycleTrendWindow(delta as Number) as Void {
        var trendState = _trendCacheService.cycleTrendWindow(_domain, _selectedMetric, _trendWindow, delta);
        _applyTrendState(trendState as Dictionary);
    }

    function _availableTrendWindows() as Array {
        return _trendCacheService.availableTrendWindows(_domain, _selectedMetric);
    }

    function _trendSampleCount() as Number {
        return _domain.historyValues(_selectedMetric, 365).size();
    }

    hidden function _applyTrendState(trendState as Dictionary) as Void {
        _trendWindow = trendState[:window].toNumber();
        _trendValues = trendState[:values] as Array;
        _trendDirection = trendState[:direction].toNumber();
    }

    //! Draw the trend/history screen with mini chart, trend indicator, and window label.
    function drawTrend(dc as Dc) as Void {
        var metric = _domain.metricAt(_selectedMetric) as Dictionary;
        _trendRenderer.draw(dc, {
            :domain => _domain,
            :selectedMetric => _selectedMetric,
            :trendWindow => _trendWindow,
            :trendValues => _trendValues,
            :trendSampleCount => _trendSampleCount(),
            :trendDirection => _trendDirection,
            :availableWindows => _availableTrendWindows(),
            :currentValueText => formatValue(metric) + " " + metric[:unit].toString(),
            :trendNoDataText => text("trend.no_data"),
            :trendSingleEntryText => text("trend.single_entry"),
            :trendUpText => text("trend.up"),
            :trendDownText => text("trend.down"),
            :trendFlatText => text("trend.flat"),
            :trendLastPrefix => text("trend.last_prefix"),
            :trendLastSuffix => text("trend.last_suffix"),
            :trendLastSuffixShort => text("trend.last_suffix_short")
        });
    }

    //! Compute the usable horizontal width at a given Y on a round screen.
    function _availableWidthAtY(screenW as Number, screenH as Number, textY as Number, textH as Number) as Number {
        return availableWidthAtYGlobal(screenW, screenH, textY, textH);
    }

}

//! UI color constants used across views and menus.
const COLOR_ACCENT = 0x66CCFF;
const COLOR_ACCENT_DIM = 0x224466;
const COLOR_BADGE_BG = 0x335C99;
