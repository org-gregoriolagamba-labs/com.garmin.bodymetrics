# BodyMetrics Architecture Notes

## Documentation Role

- This file is the compact engineering baseline for architectural guardrails and validation commands.
- The evolving bilingual documentation corpus lives under `docs/`.
- Architecture overviews are maintained in `docs/it/architecture-overview.md` and `docs/en/architecture-overview.md`.
- Use this file for short, high-signal constraints; move long-form explanation to the mirrored documents.

## Module Boundaries

- `source/BodyMetricsView.mc` is the UI state coordinator. It owns mode transitions, selected metric state, transient editor state, feedback badges, and renderer dispatch.
- `source/renderers/*` owns drawing only. Renderers receive a model dictionary and must not mutate application state or talk directly to storage/history providers.
- `source/BodyMetricsDomain.mc` is the compatibility facade consumed by the view/renderers. It coordinates collaborators and preserves the public API surface.
- `source/usecases/*` owns application workflows that combine storage/services and return view-ready data or updated state.
- `source/policies/*` owns deterministic business rules and classification/threshold logic.
- `source/trend/BodyMetricsTrendCacheService.mc` owns presentation-level caching for trend windows and cached history values.
- `source/i18n/*` owns translation catalogs and validation helpers. `source/BodyMetricsLocale.mc` is only the adapter exposed to the rest of the app.

## Dependency Rules

- Views may call the domain and renderers, but not storage/history/targets services directly.
- Renderers may depend on renderer helpers and the render model only.
- Use cases may depend on storage/services/policies, but should not import view classes or renderer helpers.
- Policies should stay side-effect free.
- Locale lookup should go through `BodyMetricsLocale`; raw catalog access is only for validator/debug tooling.

## Placement Guardrails

- New drawing/layout logic goes in `source/renderers/*`.
- New workflow/state-transition logic goes in `source/usecases/*`.
- New thresholds/classification/reference logic goes in `source/policies/*`.
- If a change would only preserve the old public API for callers, keep the delegation shim in `source/BodyMetricsDomain.mc` rather than duplicating logic.
- If a feature needs new localized strings, add them to English first in `source/i18n/BodyMetricsLocaleCatalog.mc`, then add `it`, `fr`, and `es` entries before shipping.

## Locale Safety

- Development-time completeness check is exposed through `BodyMetricsLocaleValidator` and reachable from the debug menu.
- Runtime fallback order is: current language -> `en` -> raw key.
- Do not add new `if (key.equals(...))` ladders back into `BodyMetricsLocale`.

## Trend Cache Contract

- Invalidate trend cache after measurement saves.
- Invalidate trend cache after full user-data reset.
- Invalidate trend cache after debug history populate/clear/disable actions.
- Invalidate trend cache when the selected metric changes.
- Recompute current cached state when the trend window changes.
- The cache service is presentation-scoped; it must not become the source of truth for history data.

## Validation Commands

- Primary build gate:

```bash
/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc -f monkey.jungle -d fr265 -o /tmp/BodyMetrics-validation.prg -y /home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der
```

- Simulator/task entrypoint already wired in the workspace:

```bash
bash .vscode/run-bodymetrics-sim.sh
```

## Benchmark Note

- The original plan requested before/after benchmark numbers and a constrained-target comparison.
- This repo currently enables only `fr265` in `manifest.xml`.
- No numeric baseline was captured before the structural refactor started, so any retroactive before/after table would be synthetic and should not be added.