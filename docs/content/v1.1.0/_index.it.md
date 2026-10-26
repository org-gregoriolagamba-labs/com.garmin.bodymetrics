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

| Famiglia | Modelli |
|--------|-------|
| Forerunner | 11 |
| Fenix | 14 |
| Epix | 4 |
| Venu | 7 |
| Vivoactive | 2 |
| MARQ 2 | 2 |
| Enduro | 1 |
| D2 | 4 |
| Instinct 3 AMOLED | 3 |
| Descent | 3 |
| Approach | 2 |

**API Level Globale Minimo:** 2.3.0 (per compatibilità Application.Storage)

L'elenco completo, con tipo di display e dimensione dello schermo, è in [Dispositivi Supportati](articles/supported-devices/).

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

**v1.1.0** — 26 ottobre 2026 — espansione multi-dispositivo. Vedi il [Changelog](articles/changelog/) per i dettagli.
