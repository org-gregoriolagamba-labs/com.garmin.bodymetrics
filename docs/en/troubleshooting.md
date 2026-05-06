# Troubleshooting

## Common Issues

### I do not see the expected trend

- Make sure enough historical data exists.
- After only one measurement, the app may show a dedicated message instead of a full chart.

### Some values do not come from Garmin

- Not every metric is read from the Garmin profile.
- Weight may come from Garmin, while other metrics require manual entry.

### I changed language and want to verify all strings

- Full catalog validation is a debug action, not an end-user workflow.

### I need to start over

- Use the data reset function from the dedicated menu.
- Remember that reset affects the app's local data.

## Quick Technical Diagnosis

- If the issue is related to a recent regression, rebuild with the documented `monkeyc` command.
- If the issue is visual or navigation-related, inspect the behavior in the simulator with `.vscode/run-bodymetrics-sim.sh`.
- If the issue involves translations or debug badges, always separate end-user flow from dev-only flow during analysis.