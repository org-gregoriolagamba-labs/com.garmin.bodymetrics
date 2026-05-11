---
title: "Changelog"
date: 2026-05-11
draft: false
summary: "Release history and notable changes for BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "releases"]
---

## v1.0.1 — May 10, 2026

{{< badge color="blue" >}}quality patch{{< /badge >}}

### User-Facing Changes

- **System Info → Website**: the Website entry is now a selectable button that opens a full-screen QR code view centred on the display.
- **MENU key in wizard**: the MENU key is now blocked during data-entry wizard mode; it no longer accidentally opens the system menu while editing a field.
- **Label fix**: `sysinfo.author` label corrected in all four languages (Autore / Author / Auteur / Autor).
- **Badge info view**: values reduced to `FONT_XTINY` to prevent truncation on long strings.
- **Simulator navigation**: adaptive UP/DOWN navigation — a single tap now produces one step, consistent with physical device behaviour.

### Architectural Refactoring (Internal)

- Removed duplicate `_round1()` and `_fmt1()` from six files; all calls now route through the global `round1Global()` and `fmt1Global()`.
- Removed dead method `calculateMusclePct()` from HealthCalculators.
- Removed duplicate renderer helpers from MenuView in favour of global counterparts.
- Removed dead method `canOpenMenu()` from the View.
- Removed five duplicate `PROFILE_*_KEY` constants from Domain.
- Removed five trivial one-liner wrappers from Domain.
- `potenzaRange()` now derives from `muscleKgRange()` scaled by 35 instead of duplicating the logic.
- `measurementFieldCount()` and `profileFieldCount()` now return integer constants instead of rebuilding the array on every call.
- `fitTextBlockGlobal()` in RendererCommon now returns `:width` in its result dictionary for a uniform interface.
- Fixed a formatting bug in `clearStoredMeasurements()` (missing newline after function signature).

### Compatibility

- No user-facing features removed.
- Validated on target `fr265`, reference build v15: **BUILD SUCCESSFUL**.

---

## v1.0.0 — May 6, 2026

{{< badge color="green" >}}first stable release{{< /badge >}}

### Features Included

- Summary and detail views for all tracked metrics.
- Informational screens with metric descriptions, reference zones, and reading context.
- Historical trend visualisation with selectable time windows.
- Guided first-run workflow for user profile setup.
- Guided workflow for body measurement entry.
- Guided workflow for custom target setup.
- Target delta calculation against the effective target.
- Support for weight, body fat, muscle mass, hydration, and bone mass.
- Derived values: BMI, muscle percentage, reference BMR, and power output.
- Local history for trend charts and informational states.
- Distinction between manual local data and Garmin UserProfile weight.
- Interface language switching (IT, EN, FR, ES).
- Full reset of local app data.
- Bilingual (IT/EN) project documentation baseline.
