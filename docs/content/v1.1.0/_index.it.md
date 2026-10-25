---
title: "Documentazione BodyMetrics"
description: "Documentazione ufficiale di BodyMetrics v1.1.0 — il widget Garmin Connect IQ per il monitoraggio delle metriche corporee."
layout: "docs-home"
version: "v1.1.0"
---

Benvenuto nella documentazione di **BodyMetrics v1.1.0**.

BodyMetrics è un widget Garmin Connect IQ che mostra le principali metriche della composizione corporea direttamente sul tuo polso, tiene traccia dello storico nel tempo e ti aiuta a raggiungere i tuoi obiettivi personali di salute. **v1.1.0 espande il supporto a 53 dispositivi Garmin.**

## Cosa Troverai Qui

- **[Articoli](articles/)** — guida utente, introduzione, funzionalità, navigazione, localizzazione e FAQ.
- **[Design](design/)** — architettura, sistema di rendering, flusso dei dati e internazionalizzazione (per contributori e sviluppatori).

## Dispositivi Supportati

BodyMetrics ora supporta **53 dispositivi Garmin Connect IQ** su diverse famiglie di prodotti:

| Famiglia | Dispositivi | API Min |
|----------|-------------|---------|
| Forerunner | 165/165M, 255M/255SM, 265/265S, 955/965/970, 57 (42mm/47mm) | 4.0+ |
| Fenix | serie 7 (tutte le varianti), serie 8, Fenix E | 4.0+ |
| Epix | Epix 2 (tutte le varianti) | 4.0+ |
| Venu | serie 2, serie 3 (tutte le varianti) | 4.0+ |
| Vivoactive | 5, 6 | 4.0+ |
| MARQ | serie 2 (Aviator, Athlete) | 4.0+ |
| Enduro | 3 | 4.0+ |
| D2 | Air, Air X10, Mach 1, Delta | 4.0+ |
| Instinct | 3 AMOLED | 5.0+ |
| Descent | G2, MK, MK 2S | 4.0+ |
| Approach | S70, S70 42mm | 4.0+ |

**API Level Globale Minimo:** 2.3.0 (per compatibilità Application.Storage)

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

**v1.1.0** — 14 giugno 2026 — espansione multi-dispositivo. Vedi il [Changelog](articles/changelog/) per i dettagli.
