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
- `source/renderers/RendererCommon.mc` exposes global functions shared across all renderers: `fitTextBlockGlobal`, `maxTextWidthGlobal`, `drawCenteredTextBlockGlobal`, `wrapTextGlobal`, `splitWordsGlobal`, `availableWidthAtYGlobal`, `pct`.
- `source/BodyMetricsQrcodeView.mc` displays the website QR code full-screen; it is opened by the `BodyMetricsBadgeInfoView` delegate via `BodyMetricsView.openQrcodeView()`.

### Domain Facade

- `source/BodyMetricsDomain.mc` exposes the compatibility surface consumed by the view.
- It coordinates use cases, policies, locale, and trend cache without duplicating presentation logic.
- It does not define storage key constants: the authoritative copies live in the respective use cases.

### Application Workflows

- `source/usecases/BodyMetricsMeasurementsUseCase.mc` manages measurements, editable fields, and derived values.
- `source/usecases/BodyMetricsProfileUseCase.mc` manages the user profile and Garmin data merge.
- `source/usecases/BodyMetricsTargetsUseCase.mc` manages user targets and target fallback behavior.
- `source/usecases/BodyMetricsTrendUseCase.mc` manages history and trend workflows.
- `source/usecases/BodyMetricsResetUserDataUseCase.mc` manages full reset and related invalidation.

### Rules and Services

- `source/policies/BodyMetricsClassificationPolicy.mc` classifies metrics into color zones.
- `source/policies/BodyMetricsThresholdFactory.mc` generates thresholds for each metric and profile; `potenzaRange()` is derived directly from `muscleKgRange()` scaled by 35.
- `source/policies/BodyMetricsHealthCalculators.mc` holds pure BMI, BMR, and muscle calculations.
- `source/BodyMetricsHistory.mc`, `source/BodyMetricsDataProvider.mc`, `source/BodyMetricsTargets.mc`, and `source/BodyMetricsGarminProfile.mc` manage persistence and data integrations.
- `source/trend/BodyMetricsTrendCacheService.mc` is a presentation cache and not the authoritative data source.

### Localization

- `source/i18n/BodyMetricsLocale.mc` is the only runtime lookup adapter.
- `source/i18n/BodyMetricsLocaleCatalog.mc` stores the multilingual catalog (IT, EN, FR, ES).
- `source/i18n/BodyMetricsLocaleValidator.mc` validates completeness against `en`.

## Code Quality Principles

- `round1Global()` and `fmt1Global()` are the only authoritative implementations of one-decimal rounding and formatting in the entire codebase: no file may define local equivalents.
- The global rendering functions in RendererCommon are the only authoritative implementations of text wrapping, width measurement, and centered text drawing.
- `measurementFieldCount()` and `profileFieldCount()` return integer constants consistent with their field definitions: they do not rebuild the array on each call.

## Architectural Constraints

- The view may talk to the domain and renderers, but not to persistence services directly.
- Renderers must not mutate application state.
- Use cases must not depend on UI classes or rendering helpers.
- Policies remain side-effect free.
- Locale fallback is: current language -> `en` -> raw key.
- The Domain must not redefine storage key constants: each use case owns its own.

## Main Flows

- App launch: initial setup if the profile is missing, otherwise summary.
- Metric navigation: summary, detail, info, trend, and target delta.
- Input workflows: profile, measurements, and targets through wizard screens.
- Support workflows: language change, data reset, debug locale/history actions.

## Build Variants

- **Full** (target `fr265`): standard build with all localizations (IT, EN, FR, ES) and all features.
- **Lite** (planned — targets FR55, FR735XT): separate jungle file, English-only locale, all user features preserved.

## Document Status

Updated to build v15 (May 10, 2026). Reflects the completed Clean Code refactoring and the current architectural structure of the repository.
