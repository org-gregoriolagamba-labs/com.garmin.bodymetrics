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

| Family | Devices | Min API |
|--------|---------|---------|
| Forerunner | 165/165M, 255M/255SM, 265/265S, 955/965/970, 57 (42mm/47mm) | 4.0+ |
| Fenix | 7 series (all variants), 8 series, Fenix E | 4.0+ |
| Epix | Epix 2 (all variants) | 4.0+ |
| Venu | 2 series, 3 series (all variants) | 4.0+ |
| Vivoactive | 5, 6 | 4.0+ |
| MARQ | 2 series (Aviator, Athlete) | 4.0+ |
| Enduro | 3 | 4.0+ |
| D2 | Air, Air X10, Mach 1, Delta | 4.0+ |
| Instinct | 3 AMOLED | 5.0+ |
| Descent | G2, MK, MK 2S | 4.0+ |
| Approach | S70, S70 42mm | 4.0+ |

**Global Min API Level:** 2.3.0 (for Application.Storage compatibility)

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

**v1.1.0** — June 14, 2026 — multi-device expansion. See [Changelog](articles/changelog/) for details.
