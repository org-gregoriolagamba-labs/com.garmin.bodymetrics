---
title: "Architecture"
date: 2026-05-11
draft: false
summary: "Module boundaries, dependency rules, and layered structure of the BodyMetrics codebase."
toc: true
weight: 10
tags: ["architecture", "design", "modules"]
---

## Overview

BodyMetrics separates concerns across six layers: UI coordination, rendering, domain facade, application workflows, business rules, and localization. Each layer has strict dependency rules to prevent coupling and make the codebase easy to evolve independently.

## Layered Structure

### Layer 1 — UI and Navigation

| File | Responsibility |
|------|---------------|
| `source/BodyMetricsView.mc` | Mode coordinator — owns mode transitions, selection state, transient editor state, feedback badges, and renderer dispatch |
| `source/BodyMetricsInputDelegate.mc` | Translates hardware and touch input into state transitions |
| `source/BodyMetricsMenuView.mc` | Manages custom menus, sub-menus, and navigation delegates |

The view **does not** read from storage directly. All data access goes through the Domain facade.

### Layer 2 — Rendering

| File | Responsibility |
|------|---------------|
| `source/renderers/BodyMetricsSummaryDetailRenderer.mc` | Draws Summary and Detail screens |
| `source/renderers/BodyMetricsWizardRenderer.mc` | Draws Profile/Measurement/Target wizard screens |
| `source/renderers/BodyMetricsInfoTargetDeltaRenderer.mc` | Draws Info and Target Delta screens |
| `source/renderers/BodyMetricsTrendRenderer.mc` | Draws the historical trend chart |
| `source/renderers/RendererCommon.mc` | Shared drawing utilities (text wrap, fit, draw centred, geometry) |
| `source/BodyMetricsQrcodeView.mc` | Full-screen QR code view |

Renderers receive a **rendering-ready model dictionary** and must not read from storage or mutate application state.

### Layer 3 — Domain Facade

`source/BodyMetricsDomain.mc` is the **compatibility surface** consumed by the view. It coordinates use cases, policies, locale, and trend cache without duplicating presentation logic.

{{< callout type="note" >}}
The Domain must not redefine storage key constants. Each use case owns its own keys.
{{< /callout >}}

### Layer 4 — Application Workflows (Use Cases)

| File | Responsibility |
|------|---------------|
| `source/usecases/BodyMetricsMeasurementsUseCase.mc` | Manages measurements, editable fields, and derived values |
| `source/usecases/BodyMetricsProfileUseCase.mc` | Manages user profile and Garmin data merge |
| `source/usecases/BodyMetricsTargetsUseCase.mc` | Manages user targets and target fallback |
| `source/usecases/BodyMetricsTrendUseCase.mc` | Manages history and trend workflows |
| `source/usecases/BodyMetricsResetUserDataUseCase.mc` | Manages full reset and related invalidation |

Use cases may depend on storage, services, and policies — but must **not** import view classes or rendering helpers.

### Layer 5 — Business Rules and Services

| File | Responsibility |
|------|---------------|
| `source/policies/BodyMetricsClassificationPolicy.mc` | Classifies metrics into colour zones |
| `source/policies/BodyMetricsThresholdFactory.mc` | Generates thresholds per metric and profile |
| `source/policies/BodyMetricsHealthCalculators.mc` | Pure BMI, BMR, and muscle calculations |
| `source/BodyMetricsHistory.mc` | Persists historical snapshots |
| `source/BodyMetricsDataProvider.mc` | Persists current measurements |
| `source/BodyMetricsTargets.mc` | Persists custom targets |
| `source/BodyMetricsGarminProfile.mc` | Reads Garmin UserProfile (weight, etc.) |
| `source/trend/BodyMetricsTrendCacheService.mc` | Presentation cache for trend windows |

Policies must remain **side-effect free**.

### Layer 6 — Localization

| File | Responsibility |
|------|---------------|
| `source/BodyMetricsLocale.mc` | Runtime lookup adapter (only public locale interface) |
| `source/i18n/BodyMetricsLocaleCatalog.mc` | Multilingual translation catalog (IT, EN, FR, ES) |
| `source/i18n/BodyMetricsLocaleValidator.mc` | Completeness validator for development |

## Dependency Rules

```
View  ──────────→  Domain  ──────→  UseCases  ──→  Storage / Services
  │                   │                              │
  └──→  Renderers      └──────────────────→  Policies
             │
             └──→  RendererCommon
```

- **View** may call Domain and Renderers; must not access storage directly.
- **Renderers** depend only on RendererCommon and the render model.
- **UseCases** depend on storage, services, and policies; never on views or renderers.
- **Policies** are pure functions — no side effects, no I/O.
- **Locale** lookups always go through `BodyMetricsLocale`; raw catalog access is only for the validator.

## Global Helper Constraints

Two global functions are the single authoritative implementations across the entire codebase:

| Function | File | Purpose |
|----------|------|---------|
| `round1Global()` | `BodyMetricsDomain.mc` | One-decimal rounding |
| `fmt1Global()` | `BodyMetricsDomain.mc` | One-decimal string formatting |

No file may define local equivalents. Similarly, the rendering utilities in `RendererCommon.mc` are the only authoritative implementations of text wrapping, width measurement, and centred text drawing.

## Build Variants

| Variant | Target | Locales | Status |
|---------|--------|---------|--------|
| Full | `fr265` | IT, EN, FR, ES | ✅ Stable (v15) |
| Lite | FR55, FR735XT | EN only | 🔲 Planned |

## Validation Command

```bash
monkeyc -f monkey.jungle -d fr265 \
  -o /tmp/BodyMetrics-validation.prg \
  -y /path/to/bodymetrics-dev-key.pk8.der
```

## See Also

- [Renderers](../renderers/) — the rendering layer in detail.
- [Data Flow](../data-flow/) — how data moves from storage to screen.
- [i18n System](../i18n-system/) — the localization architecture.
