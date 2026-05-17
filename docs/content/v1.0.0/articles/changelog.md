---
title: "Changelog"
date: 2026-05-12
draft: false
summary: "Release history and notable changes for BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "releases"]
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

- **Wizard navigation**: rapid-press acceleration for UP/DOWN — consecutive taps within 500 ms progressively increase the step multiplier (×1 → ×5 → ×10 → ×50).

### Architecture

- Six-layer clean architecture: UI coordination, rendering, domain facade, use cases, business rules, and localisation.
- Global `round1Global()` / `fmt1Global()` as the single authoritative rounding and formatting functions.
- `RendererCommon` as the single authoritative source for all text layout and drawing utilities.
- Pure, side-effect-free policy layer (ClassificationPolicy, ThresholdFactory, HealthCalculators).
- Three-component i18n system: catalog, adapter, and completeness validator.
- Trend cache service with invalidation on measurement save, reset, metric change, and window change.

### Compatibility

- Validated on target `fr265`, reference build v15: **BUILD SUCCESSFUL**.
