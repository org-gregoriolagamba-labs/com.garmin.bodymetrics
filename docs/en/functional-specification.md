# Functional Specification

## Product Goal

BodyMetrics allows the user to inspect body metrics, view their history, set personal targets, and manage a personal profile on a compatible Garmin device.

## Core Capabilities

- Summary visualization of metrics with zone-based classification.
- Navigation across detail, clinical information, and target delta views.
- Historical trend visualization with selectable time windows.
- Manual entry of body measurements.
- User profile configuration and maintenance.
- Management of custom metric targets.
- Language switching and local data reset.

## Main User Flows

### First Launch

- If the profile is not configured, the app forces the setup workflow.
- Setup collects at least sex, age band, body profile, and height.
- When setup completes, the system saves the profile and enters summary mode.

### Metric Browsing

- The summary screen shows one metric at a time with a compact status.
- The user can browse metrics and enter detail, info, trend, and target delta.
- Derived values are calculated from the available profile and measurement data.

### Measurement Entry

- From the data menu the user enters the measurement wizard.
- Each field is edited through min/max/step cycles defined by the use case.
- On save, measurements update persistence and record a history snapshot.

### Target Management

- From the targets menu the user sets goals for supported metrics.
- Each target can be set, reset individually, or reset in bulk.
- If a user target is missing, the system uses the effective target derived from policy.

### Trend and History

- Trend uses persisted history and not the cache as the source of truth.
- Available windows are user-selectable.
- When only one historical point exists, the app shows a dedicated state instead of an incomplete chart.

## Managed Data

- User profile.
- Manual body measurements and Garmin weight when available.
- Per-metric custom targets.
- Historical metric snapshots.
- Language preference.

## Current Functional Limits

- The documented active hardware target is `fr265`.
- Debug features are outside the end-user scope.
- Some values come from Garmin while others are manual-only; the source must remain distinguishable.