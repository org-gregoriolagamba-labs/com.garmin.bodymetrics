# Troubleshooting

## Common Issues

### I do not see the expected trend

- Make sure enough historical data exists.
- After only one measurement, the app may show a dedicated message instead of a full chart.

### Some values do not come from Garmin

- Not every metric is read from the Garmin profile.
- Weight may come from Garmin, while other metrics require manual entry.

### UP/DOWN in the simulator do not change the field value

- The simulator sends only `PRESS_TYPE_ACTION` without the full down/repeat/up sequence of a physical device.
- This is expected behavior: each keypress produces exactly one step.
- On a physical device, holding the key activates adaptive step acceleration (×10 after 1 s, ×50 after 3 s).

### MENU key opens the system menu during data entry

- In any data-entry wizard, the MENU key is blocked and must not open the system menu.
- If the system menu appears in wizard mode, this is a regression: verify that `onMenu()` in the InputDelegate returns `true` when `isWizardEditMode()` is active.

### I changed language and want to verify all strings

- Full catalog validation is a debug action, not an end-user workflow.

### I need to start over

- Use the data reset function from the dedicated menu.
- Remember that reset affects the app's local data.

### The website QR code is hard to scan

- First open the QR code screen: from the `Information` screen, select the "Website" entry (already highlighted on open) and press ENTER.
- The QR code fills the entire screen (120×120 px on FR265): hold your smartphone camera 10–15 cm away with the watch display at full brightness.

## Quick Technical Diagnosis

- If the issue is related to a recent regression, rebuild with the documented `monkeyc` command.
- If the issue is visual or navigation-related, inspect the behavior in the simulator with `.vscode/run-bodymetrics-sim.sh`.
- If the issue involves translations or debug badges, always separate end-user flow from dev-only flow during analysis.
- If a renderer shows incorrectly formatted values, verify there is no local `_round1` or `_fmt1` implementation: the only authoritative implementations are the global functions `round1Global()` and `fmt1Global()`.
