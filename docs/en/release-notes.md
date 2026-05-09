# Release Notes

## 1.0.1

- release identifier or version: `1.0.1`
- date: `2026-05-10`
- release type: `quality and UX patch`

### Main Contents

- system info screen: the author's website is now displayed as a scannable QR code instead of a plain URL text;
- MENU key behavior in data-entry wizard mode: the system menu no longer opens by mistake while editing fields (onMenu fix);
- `sysinfo.author` label corrected in all four languages (Autore / Author / Auteur / Autor);
- badge info view values reduced to `FONT_XTINY` to prevent truncation on long strings;
- adaptive UP/DOWN navigation in the simulator: a single tap now produces one step, consistent with physical device behavior.

### Architectural Refactoring

- removed duplicate `_round1()` and `_fmt1()` from six files (HealthCalculators, ThresholdFactory, MeasurementsUseCase, SummaryDetailRenderer, TrendRenderer, InfoTargetDeltaRenderer): all calls now go through the global functions `round1Global()` and `fmt1Global()`;
- removed dead method `calculateMusclePct()` from HealthCalculators: the same computation already exists inline in MeasurementsUseCase;
- removed duplicate renderer helpers from MenuView (`maxTextWidth`, `drawCenteredLines`, `fitMenuText`) in favor of the global counterparts `maxTextWidthGlobal`, `drawCenteredTextBlockGlobal`, and `fitTextBlockGlobal`;
- removed dead method `canOpenMenu()` from the View (always returned `true`) and the corresponding guard in the InputDelegate;
- removed five duplicate `PROFILE_*_KEY` constants from Domain (the authoritative copies live in ProfileUseCase);
- removed five trivial one-liner wrappers from Domain (`_measurementField*`, `_resetState*`, `_loadedProfile*`): logic is now inline at each call site;
- `potenzaRange()` in ThresholdFactory no longer duplicates the logic of `muscleKgRange()`: thresholds are now derived by scaling the muscle-kg range by 35;
- `measurementFieldCount()` and `profileFieldCount()` now return integer constants instead of rebuilding the field array on every call;
- added `:width` to the return value of `fitTextBlockGlobal()` in RendererCommon, making the interface uniform across all renderers;
- fixed a formatting bug in `clearStoredMeasurements()` in DataProvider (missing newline after the function signature).

### Release Notes

- no user-facing features removed;
- the lite build for resource-constrained devices (FR55, FR735XT) is in planning and is not part of this release;
- compatibility confirmed with target `fr265`;
- reference build: `v15`, validated with BUILD SUCCESSFUL.

---

## 1.0.0

- release identifier or version: `1.0.0`
- date: `2026-05-06`
- release type: `first stable release`

### Main Contents

- display of the main body metrics in summary and detail views;
- informational screens with metric descriptions, reference zones, and reading context;
- historical trend visualization with dedicated time windows;
- guided first-run workflow for user profile setup;
- guided workflow for body measurement entry;
- guided workflow for custom target setup;
- delta calculation against the effective target;
- support for weight, body fat, muscle mass, water, and bone mass;
- calculation of derived values such as BMI, muscle percent, reference BMR, and power;
- support for local history used to feed trend charts and informational states;
- distinction between local manual data and weight available from Garmin UserProfile;
- interface language switching;
- full reset of the app's local data;
- project baseline documentation started in bilingual Italian/English form.

### Known Limitations

- documented product target: `fr265`;
- manifest-declared permission: access to `UserProfile`;
- debug features exist in code but are outside the end-user release scope;
- not every body metric is provided by Garmin: weight may come from `UserProfile`, while other metrics remain manual-only;
- trend history depends on having enough local data available.

### Release Notes

- this entry represents the first publishable stable availability of BodyMetrics;
- release `1.0.0` defines the official functional baseline reference.
