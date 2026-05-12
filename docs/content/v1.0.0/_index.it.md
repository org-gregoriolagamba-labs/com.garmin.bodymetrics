---
title: "Documentazione BodyMetrics"
description: "Documentazione ufficiale di BodyMetrics v1.0.0 — il widget Garmin Connect IQ per il monitoraggio delle metriche corporee."
layout: "docs-home"
version: "v1.0.0"
---

Benvenuto nella documentazione di **BodyMetrics v1.0.0**.

BodyMetrics è un widget Garmin Connect IQ per il **Forerunner 265** che mostra le principali metriche della composizione corporea direttamente sul tuo polso, tiene traccia dello storico nel tempo e ti aiuta a raggiungere i tuoi obiettivi personali di salute.

## Cosa Troverai Qui

- **[Articoli](articles/)** — guida utente, introduzione, funzionalità, navigazione, localizzazione e FAQ.
- **[Design](design/)** — architettura, sistema di rendering, flusso dei dati e internazionalizzazione (per contributori e sviluppatori).

## Dispositivo Supportato

| Dispositivo | API Min | Build |
|-------------|---------|-------|
| Forerunner 265 (`fr265`) | 1.2.0 | v15 |

## Metriche Monitorate

| Metrica | Fonte | Note |
|---------|-------|------|
| Peso | Manuale / Garmin UserProfile | Il peso Garmin viene integrato automaticamente se disponibile |
| Grasso Corporeo % | Manuale | |
| Massa Muscolare (kg) | Manuale | La percentuale muscolare è derivata |
| Idratazione % | Manuale | |
| Massa Ossea (kg) | Manuale | |
| BMI | Derivato | Da peso + altezza |
| BMR (kcal) | Derivato | Dal profilo utente |
| Potenza (W) | Derivato | Da massa muscolare × 35 |

## Ultima Release

**v1.0.0** — 10 maggio 2026 — first stable release. Vedi il [Changelog](articles/changelog/) per i dettagli.
