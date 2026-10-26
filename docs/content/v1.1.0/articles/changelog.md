---
title: "Changelog"
date: 2026-10-26
draft: false
summary: "Release history and notable changes for BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "releases"]
---

## v1.1.0 — October 26, 2026

{{< badge color="blue" >}}multi-device expansion{{< /badge >}}

### 🎉 Highlights

- **Device support expanded from 1 to 53 Garmin devices**
- **Automated multi-device build and test infrastructure**
- **Enhanced documentation and device compatibility guide**

### Features

- Expanded device support to 53 Garmin Connect IQ devices across 11 product families
  - Forerunner (11 devices), Fenix (7/8 series), Epix, Venu, Vivoactive
  - MARQ 2, Enduro 3, D2 series, Instinct 3 AMOLED, Descent, Approach
- Automated multi-device build validation system (`.vscode/build-all-devices.sh`)
- Device-specific simulator launcher with retry logic (`.vscode/run-sim.sh`)
- VS Code task integration with device picker dropdown (53 devices available)
- Comprehensive device compatibility matrix and build report

### UX Refinements

- Cross-device rendering optimization with fully adaptive UI
- Dynamic chord geometry for circular screens
- Support for both MIP (e-ink) and AMOLED display types
- No device-specific code paths required (universal rendering system)

### Architecture & Dependencies

- Upgraded minimum API Level from 1.2.0 to 2.3.0
- Ensures compatibility with modern Garmin devices
- Supports Application.Storage required by data persistence layer
- Avoids API 3.x method argument limitation (max 9 arguments per method)
- Build validation: **53/53 devices pass** (100% success rate)

### Fixed

- Crash in wizard mode when rapid-pressing past the first or last value of a profile field or trend window (index wrap-around with negative values)

### Documentation

- Added "Supported Devices" section in README with full device list
- Created comprehensive device compatibility table
- Added device-specific testing guide
- New [Supported Devices](../supported-devices/) page with all 53 models, display type and screen size
- Extended changelog with full feature breakdown for v1.1.0

### Known Limitations & Exclusions

**Excluded Devices (API 3.x incompatibility):**
- Forerunner 745, 945, 945 LTE (API 3.3/3.4)
- Descent MK1, Descent MK2, Descent MK2S (API 3.x)
- MARQ Gen 1 models (API 3.4)

**Reason:** Monkey C API 3.x has a hard limit of 9 arguments per method. BodyMetrics methods `buildTargetMetric()`, `buildTargetMetricThresholds()`, and `_drawMiniChart()` require 10+ arguments, causing compilation failures. These devices will be re-added in a future release when Garmin resolves this API limitation.

**Other exclusions:**
- D2 Air: widget memory of 512 KB, below the 768 KB used by the other supported devices

---

## v1.0.0 — May 12, 2026

{{< badge color="green" >}}first stable release{{< /badge >}}

### Features

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
- **System Info → Website**: selectable button that opens a full-screen QR code view centred on the display.
- Bilingual (IT/EN) project documentation.

### UX Refinements

- **MENU key in wizard**: blocked during data-entry wizard mode to prevent accidental system menu opening.
- **Wizard navigation**: rapid-press acceleration for UP/DOWN — consecutive taps within 600 ms progressively increase the step multiplier (×1 → ×5 → ×10 → ×50).

### Architecture

- Six-layer clean architecture: UI coordination, rendering, domain facade, use cases, business rules, and localisation.
- Global `round1Global()` / `fmt1Global()` as the single authoritative rounding and formatting functions.
- `RendererCommon` as the single authoritative source for all text layout and drawing utilities.
- Pure, side-effect-free policy layer (ClassificationPolicy, ThresholdFactory, HealthCalculators).
- Three-component i18n system: catalog, adapter, and completeness validator.
- Trend cache service with invalidation on measurement save, reset, metric change, and window change.

### Compatibility

- Validated on target `fr265`, reference build v15: **BUILD SUCCESSFUL**.
