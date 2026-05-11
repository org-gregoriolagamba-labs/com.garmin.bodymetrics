---
title: "BodyMetrics Documentation"
description: "Official documentation for BodyMetrics v1.0.1 — the Garmin Connect IQ widget for body metrics tracking."
layout: "docs-home"
version: "v1.0.1"
---

Welcome to the **BodyMetrics v1.0.1** documentation.

BodyMetrics is a Garmin Connect IQ widget for the **Forerunner 265** that displays key body composition metrics on your wrist, tracks your history over time, and helps you stay on target toward your personal health goals.

## What You'll Find Here

- **[Articles](articles/)** — user guide, getting started, features, navigation, localization, and FAQ.
- **[Design](design/)** — architecture, rendering system, data flow, and i18n internals (for contributors and developers).

## Supported Device

| Device | Min API | Build |
|--------|---------|-------|
| Forerunner 265 (`fr265`) | 1.2.0 | v15 |

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

**v1.0.1** — May 10, 2026 — quality and UX patch. See [Changelog](articles/changelog/) for details.
