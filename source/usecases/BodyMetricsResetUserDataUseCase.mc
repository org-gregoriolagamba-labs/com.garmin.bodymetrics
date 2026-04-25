import Toybox.Lang;

//! Coordinates full user-data reset across profile, measurements, targets, and history.
class BodyMetricsResetUserDataUseCase {

    var _profileUseCase;
    var _dataProvider;
    var _targetsUseCase;
    var _history;

    function initialize(profileUseCase, dataProvider, targetsUseCase, history) {
        _profileUseCase = profileUseCase;
        _dataProvider = dataProvider;
        _targetsUseCase = targetsUseCase;
        _history = history;
    }

    function resetAllUserData() as Dictionary {
        _profileUseCase.clearStoredProfile();
        _dataProvider.clearStoredMeasurements();
        _targetsUseCase.resetAllTargets();
        _history.clearHistory();

        var loaded = _profileUseCase.loadProfile();
        return {
            :hasStoredProfile => loaded[:hasStoredProfile],
            :profile => loaded[:profile],
            :measurements => _dataProvider.loadMeasurements()
        };
    }
}