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

### System Info Screen

- Accessible from the menu System -> Information.
- Displays: app name, version, release date, author, and website.
- The website entry is a selectable button: pressing ENTER opens a dedicated full-screen view with the QR code centered.

## Input Workflows

- In the data-entry wizard (profile, measurements, or targets), the MENU key is blocked and does not open the system menu.
- This prevents accidental navigation away from the wizard while editing.

## Managed Data

- User profile.
- Manual body measurements and Garmin weight when available.
- Per-metric custom targets.
- Historical metric snapshots.
- Language preference.

## Build Variants

| Variant | Jungle file | Targets | Localizations |
|---------|-------------|---------|---------------|
| Full | `monkey.jungle` | FR265 | IT, EN, FR, ES |
| Lite (planned) | `monkey-lite.jungle` | FR55, FR735XT | EN only |

The Lite variant will preserve all user-facing features but will ship with English only and a separate source configuration to meet device memory limits.

## Current Functional Limits

- Debug features are outside the end-user scope.
- Some values come from Garmin while others are manual-only; the source must remain distinguishable.
