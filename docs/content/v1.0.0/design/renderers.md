---
title: "Rendering System"
date: 2026-05-11
draft: false
summary: "How BodyMetrics draws each screen — renderers, shared utilities, and the render model contract."
toc: true
weight: 20
tags: ["rendering", "design", "draw"]
---

## Design Principles

All drawing code lives in `source/renderers/`. Renderers:

1. **Receive a model** — a Monkey C `Dictionary` built by the view containing only what is needed for that screen.
2. **Draw and return** — they may return computed values (e.g. hitbox coordinates, scroll state) but never write to storage or change application state.
3. **Never read from storage** — all data arrives pre-loaded in the model dictionary.

This separation means renderers can be tested or swapped independently, and the view remains thin.

## Renderer Map

| Renderer | Screens |
|----------|---------|
| `BodyMetricsSummaryDetailRenderer` | Summary, Detail |
| `BodyMetricsWizardRenderer` | Profile wizard, Measurement wizard, Target wizard |
| `BodyMetricsInfoTargetDeltaRenderer` | Info screen, Target Delta screen |
| `BodyMetricsTrendRenderer` | Trend chart |
| `BodyMetricsQrcodeView` | QR code full-screen (not a renderer — it is a View subclass) |

## RendererCommon — Shared Utilities

`source/renderers/RendererCommon.mc` exports global functions used by all renderers:

| Function | Purpose |
|----------|---------|
| `wrapTextGlobal(dc, text, font, maxW)` | Wraps a string into a list of lines fitting `maxW` |
| `splitWordsGlobal(text)` | Splits text into words respecting whitespace |
| `fitTextBlockGlobal(dc, lines, maxW, maxH)` | Returns `{:lines, :font, :width}` for a block that fits the given bounds |
| `maxTextWidthGlobal(dc, lines, font)` | Returns the pixel width of the widest line |
| `drawCenteredTextBlockGlobal(dc, lines, font, cx, cy)` | Draws a list of lines centred at `(cx, cy)` |
| `availableWidthAtYGlobal(r, cy, y)` | Available horizontal width at pixel row `y` on a circular screen of radius `r` |
| `pct(value, total)` | Returns `value / total` as a percentage float |

{{< callout type="note" >}}
These are the only authoritative implementations of text layout in the codebase. No renderer or view file may define local equivalents.
{{< /callout >}}

## Circular Screen Geometry

The FR265 has a round display. `availableWidthAtYGlobal` uses the Pythagorean formula to compute the horizontal chord length at a given vertical position:

```
availableWidth(y) = 2 × sqrt(r² − (y − cy)²)
```

This is used by the text-wrapping and layout functions to avoid text being clipped by the curved edges.

## Render Model Contract

The view builds a model dictionary and passes it to the appropriate renderer. An example for the Summary screen:

```monkey-c
var model = {
    :metric     => selectedMetric,
    :value      => formattedValue,
    :unit       => unitString,
    :zoneColor  => classificationColor,
    :zoneName   => classificationLabel,
    :metricName => localizedName
};
summaryDetailRenderer.drawSummary(dc, model);
```

Each renderer documents its own expected keys. Passing an incomplete model triggers a runtime exception during development (fail-fast).

## Info Icon Hitbox

`BodyMetricsSummaryDetailRenderer.drawSummary()` returns the bounding box of the info icon so the view can detect taps:

```monkey-c
var hitbox = summaryDetailRenderer.drawSummary(dc, model);
// hitbox is {:x, :y, :w, :h}
```

## Scroll State (Info Screen)

`BodyMetricsInfoTargetDeltaRenderer.drawInfo()` returns updated scroll state:

```monkey-c
var state = infoTargetDeltaRenderer.drawInfo(dc, model);
// state is {:infoScrollY, :infoContentH}
```

The view stores these values and passes them back on the next draw call, enabling stateful scrolling without the renderer owning any persistent state.

## See Also

- [Architecture](../architecture/) — where renderers fit in the overall layered structure.
- [Data Flow](../data-flow/) — how data reaches the render model.
