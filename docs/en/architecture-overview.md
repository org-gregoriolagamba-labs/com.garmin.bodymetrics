# Architecture Overview

## Purpose

BodyMetrics is a Connect IQ application for viewing body metrics, historical trends, and personal targets. The architecture separates UI coordination, rendering, application workflows, business rules, persistence, and localization.

## Layered Structure

### UI and Navigation

- `source/BodyMetricsView.mc` coordinates modes, selection state, transient editors, badges, and renderer dispatch.
- `source/BodyMetricsInputDelegate.mc` translates hardware and touch input into state transitions.
- `source/BodyMetricsMenuView.mc` manages custom menus, submenus, and navigation delegates.

### Rendering

- `source/renderers/*` is responsible for drawing only.
- Renderers receive rendering-ready models and do not read storage or application services.
- The main renderers cover summary/detail, trend, setup/data/targets wizards, and info/target delta.

### Domain Facade

- `source/BodyMetricsDomain.mc` exposes the compatibility surface consumed by the view.
- It coordinates use cases, policies, locale, and trend cache without duplicating presentation logic.

### Application Workflows

- `source/usecases/BodyMetricsMeasurementsUseCase.mc` manages measurements, editable fields, and derived values.
- `source/usecases/BodyMetricsProfileUseCase.mc` manages the user profile and Garmin data merge.
- `source/usecases/BodyMetricsTargetsUseCase.mc` manages user targets and target fallback behavior.
- `source/usecases/BodyMetricsTrendUseCase.mc` manages history and trend workflows.
- `source/usecases/BodyMetricsResetUserDataUseCase.mc` manages full reset and related invalidation.

### Rules and Services

- `source/policies/*` contains classification, thresholds, and deterministic logic.
- `source/BodyMetricsHistory.mc`, `source/BodyMetricsDataProvider.mc`, `source/BodyMetricsTargets.mc`, and `source/BodyMetricsGarminProfile.mc` manage persistence and data integrations.
- `source/trend/BodyMetricsTrendCacheService.mc` is a presentation cache and not the authoritative data source.

### Localization

- `source/i18n/BodyMetricsLocale.mc` is the only runtime lookup adapter.
- `source/i18n/BodyMetricsLocaleCatalog.mc` stores the multilingual catalog.
- `source/i18n/BodyMetricsLocaleValidator.mc` validates completeness against `en`.

## Architectural Constraints

- The view may talk to the domain and renderers, but not to persistence services directly.
- Renderers must not mutate application state.
- Use cases must not depend on UI classes or rendering helpers.
- Policies remain side-effect free.
- Locale fallback is: current language -> `en` -> raw key.

## Main Flows

- App launch: initial setup if the profile is missing, otherwise summary.
- Metric navigation: summary, detail, info, trend, and target delta.
- Input workflows: profile, measurements, and targets through wizard screens.
- Support workflows: language change, data reset, debug locale/history actions.

## Document Status

This document is the first-level architecture overview. Storage details, technical contracts, and functional workflows will be split into the dedicated documents of the same bilingual set.