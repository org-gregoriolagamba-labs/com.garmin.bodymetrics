---
title: "BodyMetrics Documentation"
description: "Official documentation for BodyMetrics v1.1.0 — the Garmin Connect IQ widget for body metrics tracking."
layout: "docs-home"
version: "v1.1.0"
---

Welcome to the **BodyMetrics v1.1.0** documentation.

BodyMetrics is a Garmin Connect IQ widget that displays key body composition metrics on your wrist, tracks your history over time, and helps you stay on target toward your personal health goals. **v1.1.0 expands support to 53 Garmin devices.**

## What You'll Find Here

- **[Articles](articles/)** — user guide, getting started, features, navigation, localization, and FAQ.
- **[Design](design/)** — architecture, rendering system, data flow, and i18n internals (for contributors and developers).

## Supported Devices

BodyMetrics now supports **53 Garmin Connect IQ devices** across multiple product families:

| Family | Models |
|--------|-------|
| Forerunner | 11 |
| Fenix | 14 |
| Epix | 4 |
| Venu | 7 |
| Vivoactive | 2 |
| MARQ 2 | 2 |
| Enduro | 1 |
| D2 | 4 |
| Instinct 3 AMOLED | 3 |
| Descent | 3 |
| Approach | 2 |

**Global Min API Level:** 2.3.0 (for Application.Storage compatibility)

The full list, with display type and screen size, is in [Supported Devices](articles/supported-devices/).

## Tracked Metrics

| Metric | Source | Notes |
|--------|--------|-------|
| Weight | Manual / Garmin UserProfile | Garmin weight merged when available |
| Body Fat % | Manual | |
| Muscle Mass (kg) | Manual | Muscle % derived |
| Hydration % | Manual | |
| Bone Mass (kg) | Manual | |
| BMI | Derived | From weight + height |
| BMR (kcal) | Derived | From profile data |
| Power (W) | Derived | From muscle mass × 35 |

## Latest Release

**v1.1.0** — October 26, 2026 — multi-device expansion. See [Changelog](articles/changelog/) for details.
