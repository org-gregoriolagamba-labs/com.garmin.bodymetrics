# User Guide

## Intended Audience

This guide is intended for the end user who wants to configure BodyMetrics and use the app to monitor body metrics, history, and targets.

## How To Read This Guide

- The walkthroughs follow the real order in which the app is typically used.
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

## Basic Navigation

- Use `UP` and `DOWN` to change metric or edit the active field value.
- Use `ENTER` (or `START`) to move deeper or confirm within a wizard.
- Use `BACK` (`ESC`/`LAP`) to close the current view when available.
- Use `MENU` to open menus.
- **Long press required**: from `Summary`, hold `ENTER` (or `START`) to open `Info` directly for the current metric.
- **Long press not required**: to open `Menu`, a short press on `MENU` is enough.

### Quick View Map

- Summary: main entry point, one metric at a time.
- Detail: deeper inspection of the current value.
- Info: descriptive text and reference zones.
- Trend: history for the selected metric.
- Target delta: distance from the effective target.

### Menu Paths: Exact Names And Keys

- Open `Menu` from the main screen: `MENU`.
- Open `User data`: `MENU` -> `ENTER`.
- Open `Preferences`: `MENU` -> `DOWN` -> `ENTER`.
- Open `System`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER`.
- Open `Debug` (if visible): `MENU` -> `DOWN` -> `DOWN` -> `DOWN` -> `ENTER`.

Internal paths from `User data`:

- `Profile`: `MENU` -> `ENTER` (`User data`) -> `ENTER` (`Profile`).
- `Check-ins`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `ENTER` (`Check-ins`).
- `Targets`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `DOWN` -> `ENTER` (`Targets`).

Internal paths from `Check-ins`:

- `Enter data`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `ENTER` (`Check-ins`) -> `ENTER` (`Enter data`).
- `Clear data`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `ENTER` (`Check-ins`) -> `DOWN` -> `ENTER` (`Clear data`).

Internal paths from `Targets`:

- `Set`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `DOWN` -> `ENTER` (`Targets`) -> `ENTER` (`Set`).
- `Reset all targets`: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `DOWN` -> `ENTER` (`Targets`) -> `DOWN` -> `ENTER` (`Reset all targets`).

Internal paths from `Preferences`:

- `Language`: `MENU` -> `DOWN` -> `ENTER` (`Preferences`) -> `ENTER` (`Language`).

Internal paths from `System`:

- `Information`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`System`) -> `ENTER` (`Information`).
- `Reset Data`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`System`) -> `DOWN` -> `ENTER` (`Reset Data`).

Contextual `Field` menus:

- In `Check-ins` wizard: `MENU` -> `ENTER` (`Clear field`).
- In `Targets` wizard: `MENU` -> `ENTER` (`Reset to default`).
- In `Trend` view (only if history has at least one entry): `MENU` -> `ENTER` (`Remove last entry`).

## Entering Measurements

1. Open `Menu` with `MENU`.
2. Enter `User data` with `ENTER`.
3. Enter `Check-ins` with `DOWN` + `ENTER`.
4. Enter `Enter data` with `ENTER`.
5. Edit the available fields and complete the wizard.
6. Save to update current values and history.

### Full Walkthrough: Measurement Entry

1. From summary, open the app menu.
2. Use the exact key sequence: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `ENTER` (`Check-ins`) -> `ENTER` (`Enter data`).
3. Move through the wizard fields one by one.
4. If weight is available from Garmin, that field may become read-only.
5. Enter or update body fat, muscle mass, water, and bone mass when available.
6. Read derived fields such as muscle percent and BMR without editing them directly.
7. Save at the end of the wizard to update current values and record a history snapshot.
8. To clear a single field during the wizard: `MENU` -> `ENTER` in `Field` on `Clear field`.

### What Happens After Save

- Manual values are stored in the app's local storage.
- Manual weight stays stored only when no Garmin weight takes precedence.
- History is updated with a snapshot of the current metrics.
- Trend windows will be recomputed from the updated data.

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
4. To open `Info` directly from `Summary`, use a long press on `ENTER` (or `START`).
5. As an alternative, tap the `(i)` icon when visible on `Summary`.
6. In simulator, if long press is not reliably captured, use a quick double press on `ENTER` as fallback.
7. Open trend to inspect how the value changes over time.
8. If targets exist, review target delta to see the gap from the effective target.

### How To Read Edge Cases

- If trend data is insufficient, the app may show an informational state instead of a complete chart.
- If only one historical point exists, trend shows a dedicated message inviting the user to add another entry.
- Some metrics are derived and depend on the available profile and measurement data.

## Managing Targets

1. Open `Menu` with `MENU`.
2. Enter `User data` with `ENTER`.
3. Enter `Targets` with `DOWN` -> `DOWN` -> `ENTER`.
4. Enter `Set` with `ENTER`.
5. Set the desired goals for the available metrics.
6. Use field reset or full reset when needed.

### Full Walkthrough: Target Editor

1. From the main screen use the exact sequence: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `DOWN` -> `ENTER` (`Targets`) -> `ENTER` (`Set`).
2. Choose the target setup entry (`Set`).
3. Edit the available targets one by one with UP and DOWN.
4. Use the `Field` contextual menu when you need to restore the default for a single target: `MENU` -> `ENTER` (`Reset to default`).
5. Complete the wizard and save to activate the new targets.
6. If needed, use full reset with sequence: `MENU` -> `ENTER` (`User data`) -> `DOWN` -> `DOWN` -> `ENTER` (`Targets`) -> `DOWN` -> `ENTER` (`Reset all targets`).

## Language Change and Reset

- Language can be changed from `Preferences` -> `Language`.
- Data reset clears the app's local configuration and data from `System` -> `Reset Data`.

### Full Walkthrough: Language Change

1. Open the `Preferences` menu.
2. Use the exact key sequence: `MENU` -> `DOWN` -> `ENTER` (`Preferences`) -> `ENTER` (`Language`).
3. Choose the desired language.
4. Confirm that the main labels refresh across the app.

### Full Walkthrough: Data Reset

1. Open the `System` menu with sequence: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`System`).
2. Select `Reset Data` with `DOWN` -> `ENTER`.
3. Confirm the action.
4. Verify that the app returns to a consistent state with profile, measurements, targets, and history cleared or restored according to app behavior.

## Export Appendix

### Items To Include In The Exported Version

- Cover page with app name, document version, and language.
- Clickable table of contents.
- Final note pointing readers to the privacy and data handling document.

### Recommended Shared Assets

- Use `docs/shared/screenshots/` to keep references stable.
- If a screen changes materially, update both the Italian and English guides in the same documentation cycle.

## Important Notes

- Some values may come from Garmin, while others are manual-only.
- Debug features are not part of normal app usage.
- When history is insufficient, the trend screen may show an informational message.
- For details on collected, stored, and resettable data, see `privacy-data-handling.md`.
- In the data-entry wizard (profile, measurements, or targets), the MENU key is blocked and does not open the system menu.
- In the `Information` screen, the "Website" entry is a button: press ENTER to open the QR code screen, then bring your smartphone camera close to scan.