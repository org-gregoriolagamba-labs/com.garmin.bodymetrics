---
title: "i18n System"
date: 2026-05-11
draft: false
summary: "How BodyMetrics manages multilingual translations — catalog, adapter, fallback, and validator."
toc: true
weight: 40
tags: ["i18n", "localization", "design"]
---

## Architecture

The localization system has three components with a clear separation of concerns:

| Component | File | Role |
|-----------|------|------|
| **Catalog** | `source/i18n/BodyMetricsLocaleCatalog.mc` | Stores all translations for all languages |
| **Adapter** | `source/BodyMetricsLocale.mc` | Single public interface for runtime string lookup |
| **Validator** | `source/i18n/BodyMetricsLocaleValidator.mc` | Development-time completeness checker |

## Catalog Structure

`BodyMetricsLocaleCatalog.mc` stores every translatable string as a key/value pair, grouped by language. English is the **reference language**: every key present in English must also be present in all other languages.

```monkey-c
// Pseudocode — actual implementation uses Dictionary literals
var catalog = {
    "en" => { "summary.weight" => "Weight", "summary.fat" => "Body Fat", … },
    "it" => { "summary.weight" => "Peso",   "summary.fat" => "Grasso corporeo", … },
    "fr" => { "summary.weight" => "Poids",  "summary.fat" => "Masse grasse", … },
    "es" => { "summary.weight" => "Peso",   "summary.fat" => "Grasa corporal", … }
};
```

## Adapter — BodyMetricsLocale

`BodyMetricsLocale.mc` is the **only** component the rest of the app should call for string lookups. The interface is a single function:

```monkey-c
BodyMetricsLocale.get(key)   // returns the localized string
```

Internally it reads the current language setting and delegates to the catalog.

{{< callout type="note" >}}
Do **not** add new `if (key.equals(…))` ladders directly to `BodyMetricsLocale`. Add the key to the catalog and let the adapter's generic lookup handle it.
{{< /callout >}}

## Fallback Chain

When a key is requested, the adapter resolves it in order:

```
1. Active language  →  found? return
2. English ("en")   →  found? return (+ log warning in dev builds)
3. Raw key          →  return as-is  (visible only in bugs)
```

In production, all four languages are complete, so the fallback path is never reached.

## Adding a New String

1. Add the key to the **English** catalog entry in `BodyMetricsLocaleCatalog.mc`.
2. Add the corresponding translation for **all four languages** (`it`, `fr`, `es`).
3. Run the locale validator (Debug menu → Locale Validator) to confirm completeness.

{{< callout type="danger" >}}
Never ship a release with missing translations. The validator will report any gaps. Missing keys produce raw key output on real devices.
{{< /callout >}}

## Locale Validator

`BodyMetricsLocaleValidator.mc` compares every catalog key in every non-English language against the English reference. Any missing or empty entry is reported as a validation failure.

The validator is accessible at runtime from **Debug menu → Locale Validator** in development builds. It is not present in production builds.

## Language Setting Persistence

The selected language is persisted in the app's local storage. It survives:
- App restarts
- Watch sleep / wake
- Full data reset (the language preference is preserved)

## Supported Language Codes

| Code | Language | Garmin Locale Code |
|------|----------|--------------------|
| `en` | English | `eng` |
| `it` | Italian | `ita` |
| `fr` | French | `fre` |
| `es` | Spanish | `spa` |

## See Also

- [Localization (User Guide)](../../articles/localization/) — how end users change the language.
- [Architecture](../architecture/) — where the i18n layer fits in the overall structure.
