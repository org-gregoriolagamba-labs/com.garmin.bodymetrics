# User Guide

## Intended Audience

This guide is intended for the end user who wants to configure BodyMetrics and use the app to monitor body metrics, history, and targets.

## How To Read This Guide

- The walkthroughs follow the real order in which the app is typically used.
- `Screenshot placeholder` blocks mark the locations to replace during PDF, wiki, or review-package export.
- When a flow depends on Garmin data being available on the device, that dependency is called out explicitly.

## First Launch

1. Launch the app on the device.
2. Complete the required profile setup on first launch.
3. Save the wizard to reach the summary screen.

### Full Walkthrough: Profile Setup

1. Open BodyMetrics.
2. If the profile is not configured yet, the app enters the initial wizard automatically.
3. Set the required fields in wizard order, using UP and DOWN to change each value.
4. Press ENTER to confirm the current field and move to the next one.
5. After the last field, save to complete setup.
6. Confirm that the app lands on the summary screen.

Screenshot placeholder:
[SHOT-EN-SETUP-01] Profile wizard entry
[SHOT-EN-SETUP-02] Profile field editing step
[SHOT-EN-SETUP-03] Summary after first save

## Basic Navigation

- Use UP and DOWN to change metric or edit the active field value.
- Use ENTER to move deeper or confirm within a wizard.
- Use BACK to close the current view when available.

### Quick View Map

- Summary: main entry point, one metric at a time.
- Detail: deeper inspection of the current value.
- Info: descriptive text and reference zones.
- Trend: history for the selected metric.
- Target delta: distance from the effective target.

Screenshot placeholder:
[SHOT-EN-NAV-01] Main summary
[SHOT-EN-NAV-02] Detail view
[SHOT-EN-NAV-03] Trend view

## Entering Measurements

1. Open the data menu.
2. Enter the measurement entry item.
3. Edit the available fields and complete the wizard.
4. Save to update current values and history.

### Full Walkthrough: Measurement Entry

1. From summary, open the app menu.
2. Enter the data category and then the measurement entry item.
3. Move through the wizard fields one by one.
4. If weight is available from Garmin, that field may become read-only.
5. Enter or update body fat, muscle mass, water, and bone mass when available.
6. Read derived fields such as muscle percent and BMR without editing them directly.
7. Save at the end of the wizard to update current values and record a history snapshot.

### What Happens After Save

- Manual values are stored in the app's local storage.
- Manual weight stays stored only when no Garmin weight takes precedence.
- History is updated with a snapshot of the current metrics.
- Trend windows will be recomputed from the updated data.

Screenshot placeholder:
[SHOT-EN-DATA-01] Data menu
[SHOT-EN-DATA-02] Measurement wizard with editable field
[SHOT-EN-DATA-03] Garmin read-only field
[SHOT-EN-DATA-04] Confirmation after measurement save

## Reading Metrics

- Summary: quick view of the selected metric state.
- Detail: more context on the current value.
- Info: meaning of the metric and reference zones.
- Trend: historical behavior over the selected window.
- Target delta: distance between the current value and the goal.

### Full Walkthrough: Browsing And Interpreting Metrics

1. Start from summary and select the metric you want to inspect.
2. Enter detail to read the current value with more context.
3. Open info to understand the metric and its reference zones.
4. Open trend to inspect how the value changes over time.
5. If targets exist, review target delta to see the gap from the effective target.

### How To Read Edge Cases

- If trend data is insufficient, the app may show an informational state instead of a complete chart.
- If only one historical point exists, trend shows a dedicated message inviting the user to add another entry.
- Some metrics are derived and depend on the available profile and measurement data.

Screenshot placeholder:
[SHOT-EN-METRIC-01] Summary with color zone
[SHOT-EN-METRIC-02] Info with zones and description
[SHOT-EN-METRIC-03] Trend with selected window
[SHOT-EN-METRIC-04] Target delta

## Managing Targets

1. Open the targets menu.
2. Set the desired goals for the available metrics.
3. Use field reset or full reset when needed.

### Full Walkthrough: Target Editor

1. Open the targets menu from the app navigation.
2. Choose the set-targets entry.
3. Edit the available targets one by one with UP and DOWN.
4. Use the field context menu when you need to restore the default value of a single target.
5. Complete the wizard and save to activate the new targets.
6. If needed, use the full reset to clear all user targets and return to effective default targets.

Screenshot placeholder:
[SHOT-EN-TARGET-01] Targets menu
[SHOT-EN-TARGET-02] Target editor on a field
[SHOT-EN-TARGET-03] Single-field reset
[SHOT-EN-TARGET-04] Feedback after full target reset

## Language Change and Reset

- Language can be changed from the options menu.
- Data reset clears the app's local configuration and data.

### Full Walkthrough: Language Change

1. Open the options menu.
2. Enter language selection.
3. Choose the desired language.
4. Confirm that the main labels refresh across the app.

### Full Walkthrough: Data Reset

1. Open the informational menu or section that contains data reset.
2. Select full reset only when you want to clear the app's local data.
3. Confirm the action.
4. Verify that the app returns to a consistent state with profile, measurements, targets, and history cleared or restored according to app behavior.

Screenshot placeholder:
[SHOT-EN-LANG-01] Language menu
[SHOT-EN-LANG-02] UI after language change
[SHOT-EN-RESET-01] Data reset confirmation
[SHOT-EN-RESET-02] App state after reset

## Export Appendix

### Items To Include In The Exported Version

- Cover page with app name, document version, and language.
- Clickable table of contents.
- Final screenshots replacing every `SHOT-*` placeholder.
- Final note pointing readers to the privacy and data handling document.

### Recommended Shared Assets

- Use `docs/shared/screenshots/` to keep references stable.
- If a screen changes materially, update both the Italian and English guides in the same documentation cycle.

## Important Notes

- Some values may come from Garmin, while others are manual-only.
- Debug features are not part of normal app usage.
- When history is insufficient, the trend screen may show an informational message.
- For details on collected, stored, and resettable data, see `privacy-data-handling.md`.