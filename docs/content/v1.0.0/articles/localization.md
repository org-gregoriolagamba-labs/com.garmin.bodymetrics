---
title: "Localization"
date: 2026-05-11
draft: false
summary: "Language support and how to change the interface language on your device."
toc: true
weight: 50
tags: ["localization", "language", "i18n"]
---

## Supported Languages

BodyMetrics ships with full interface translations for four languages:

| Language | Code | Status |
|----------|------|--------|
| English | `eng` | ✅ Complete (reference language) |
| Italian | `ita` | ✅ Complete |
| French | `fre` | ✅ Complete |
| Spanish | `spa` | ✅ Complete |

## How to Change Language

1. From the **Summary** screen, press **MENU**.
2. Navigate to **Preferences**.
3. Select **Language**.
4. Use **UP / DOWN** to browse available languages.
5. Press **ENTER** to confirm.

The interface updates immediately — no restart required and no data is lost.

## Fallback Behaviour

If a translation key is missing in the active language, BodyMetrics falls back in the following order:

1. Active language translation
2. English (`eng`) translation
3. Raw translation key (visible only in case of a bug)

In practice, all four languages are complete and the fallback path is never reached in production builds.

## Locale Validation (Developer)

During development, the **Debug menu** exposes a **Locale Validator** that checks every key in the catalog against the English reference. Any missing or empty entry is reported as a warning.

This check is automatically available in development builds targeting `fr265` with debug symbols enabled.

## See Also

- [i18n System Design](../../design/i18n-system/) — internal architecture of the translation catalog and locale adapter.
