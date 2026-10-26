---
title: "Data Flow"
date: 2026-05-11
draft: false
summary: "How data moves from persistent storage to the screen in BodyMetrics."
toc: true
weight: 30
tags: ["data-flow", "design", "architecture"]
---

## Overview

Data in BodyMetrics flows in one direction: from **persistent storage** through **use cases** and the **domain facade** to the **view**, which builds a **render model** passed to a **renderer**. No layer reads backwards from a lower layer.

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  Persistent Storage                                             │
│  (DataProvider · History · Targets · GarminProfile)            │
└──────────────────────────┬──────────────────────────────────────┘
                           │ read / write
┌──────────────────────────▼──────────────────────────────────────┐
│  Use Cases                                                      │
│  (Measurements · Profile · Targets · Trend · ResetUserData)     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ view-ready data
┌──────────────────────────▼──────────────────────────────────────┐
│  Domain Facade  (BodyMetricsDomain)                             │
│  + Policies (Classification · Thresholds · HealthCalculators)   │
│  + Trend Cache (TrendCacheService)                              │
│  + Locale (BodyMetricsLocale)                                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ view model / callbacks
┌──────────────────────────▼──────────────────────────────────────┐
│  View  (BodyMetricsView)                                        │
│  Builds render model dictionary                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │ {:metric, :value, :zone, …}
┌──────────────────────────▼──────────────────────────────────────┐
│  Renderers                                                      │
│  Draw to Garmin Graphics.Dc                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Main App Launch Flow

1. `BodyMetricsApp.onStart()` initialises the domain and creates the view.
2. The view checks whether a profile exists via the domain.
3. **No profile** → enters setup wizard mode immediately.
4. **Profile exists** → enters summary mode.
5. The view calls `onUpdate(dc)` on every display refresh, dispatching to the correct renderer based on the current mode.

## Metric Navigation Flow

1. User presses **UP / DOWN** on the Summary screen.
2. `BodyMetricsInputDelegate` calls `view.nextMetric()` / `view.previousMetric()`.
3. The view updates `_selectedMetric` and requests a redraw.
4. `onUpdate()` builds a new render model from the domain and calls `summaryDetailRenderer.drawSummary(dc, model)`.

## Measurement Entry Flow

1. User opens Check-ins wizard via menu.
2. View enters `MODE_DATA`.
3. UP/DOWN cycle through the bounded field range (step and bounds defined per field in `MeasurementsUseCase`).
4. On **ENTER**, the view advances to the next field.
5. After the last field, the view calls `domain.saveMeasurements(values)`.
6. The use case writes to `DataProvider`, records a history snapshot in `History`, and invalidates the trend cache.
7. The view returns to summary mode.

## Target Derivation Flow

When displaying the Target Delta screen, BodyMetrics resolves the **effective target**:

```
Has user custom target?
  YES → use custom target value
  NO  → call ThresholdFactory.effectiveTarget(metric, profile)
             → returns policy-derived target
```

The delta is `currentValue − effectiveTarget`, formatted and coloured by `ClassificationPolicy`.

## Trend Cache Flow

1. History is loaded from persistent storage by `TrendUseCase`.
2. `TrendCacheService` pre-processes and caches windows for fast rendering.
3. Cache is invalidated when:
   - a measurement is saved;
   - a full reset is performed;
   - debug history actions are triggered;
   - the selected metric changes;
   - the trend window changes.
4. On cache miss, the service recomputes from raw history.

## Garmin Weight Merge

`ProfileUseCase` reads the Garmin UserProfile weight (if available) and compares it with the locally stored weight. The merge rule is:

- If Garmin weight is present and the user has not overridden it manually, use the Garmin value.
- If the user has entered a manual weight, the manual value takes precedence.

## See Also

- [Architecture](../architecture/) — the full layer diagram.
- [Rendering System](../renderers/) — how the render model is consumed.
- [i18n System](../i18n-system/) — how localized strings are resolved.
