---
title: "Architettura"
date: 2026-05-11
draft: false
summary: "Confini dei moduli, regole di dipendenza e struttura a layer del codebase di BodyMetrics."
toc: true
weight: 10
tags: ["architettura", "design", "moduli"]
---

## Panoramica

BodyMetrics separa le responsabilità in sei layer: coordinamento UI, rendering, facade di dominio, flussi applicativi, regole di business e localizzazione. Ogni layer ha regole di dipendenza rigide per evitare accoppiamenti e rendere il codebase facilmente evolvibile in modo indipendente.

## Struttura a Layer

### Layer 1 — UI e Navigazione

| File | Responsabilità |
|------|---------------|
| `source/BodyMetricsView.mc` | Coordinatore modalità — gestisce le transizioni di modo, lo stato di selezione, lo stato transiente degli editor, i badge e il dispatch ai renderer |
| `source/BodyMetricsInputDelegate.mc` | Traduce l'input hardware e touch in transizioni di stato |
| `source/BodyMetricsMenuView.mc` | Gestisce menu personalizzati, sotto-menu e delegati di navigazione |

La view **non** legge direttamente dallo storage. Tutti gli accessi ai dati passano attraverso la facade di Domain.

### Layer 2 — Rendering

| File | Responsabilità |
|------|---------------|
| `source/renderers/BodyMetricsSummaryDetailRenderer.mc` | Disegna le schermate Riepilogo e Dettaglio |
| `source/renderers/BodyMetricsWizardRenderer.mc` | Disegna le schermate della procedura guidata (Profilo/Misurazioni/Obiettivi) |
| `source/renderers/BodyMetricsInfoTargetDeltaRenderer.mc` | Disegna le schermate Info e Delta Obiettivo |
| `source/renderers/BodyMetricsTrendRenderer.mc` | Disegna il grafico storico trend |
| `source/renderers/RendererCommon.mc` | Utilities di disegno condivise (wrap testo, fit, disegno centrato, geometria) |
| `source/BodyMetricsQrcodeView.mc` | Vista QR code a schermo intero |

I renderer ricevono un **dizionario modello pronto per il rendering** e non devono leggere dallo storage né modificare lo stato applicativo.

### Layer 3 — Facade di Dominio

`source/BodyMetricsDomain.mc` è la **superficie di compatibilità** consumata dalla view. Coordina use case, policy, locale e cache trend senza duplicare la logica di presentazione.

{{< callout type="note" >}}
Il Domain non deve ridefinire le costanti delle chiavi di storage. Ogni use case possiede le proprie chiavi.
{{< /callout >}}

### Layer 4 — Flussi Applicativi (Use Case)

| File | Responsabilità |
|------|---------------|
| `source/usecases/BodyMetricsMeasurementsUseCase.mc` | Gestisce le misurazioni, i campi editabili e i valori derivati |
| `source/usecases/BodyMetricsProfileUseCase.mc` | Gestisce il profilo utente e l'integrazione con i dati Garmin |
| `source/usecases/BodyMetricsTargetsUseCase.mc` | Gestisce gli obiettivi utente e il fallback degli obiettivi |
| `source/usecases/BodyMetricsTrendUseCase.mc` | Gestisce lo storico e i flussi trend |
| `source/usecases/BodyMetricsResetUserDataUseCase.mc` | Gestisce il reset completo e le invalidazioni correlate |

Gli use case possono dipendere da storage, servizi e policy — ma **non** devono importare classi di view o helper di rendering.

### Layer 5 — Regole di Business e Servizi

| File | Responsabilità |
|------|---------------|
| `source/policies/BodyMetricsClassificationPolicy.mc` | Classifica le metriche in zone colore |
| `source/policies/BodyMetricsThresholdFactory.mc` | Genera le soglie per metrica e profilo |
| `source/policies/BodyMetricsHealthCalculators.mc` | Calcoli puri di BMI, BMR e massa muscolare |
| `source/BodyMetricsHistory.mc` | Persiste gli snapshot storici |
| `source/BodyMetricsDataProvider.mc` | Persiste le misurazioni correnti |
| `source/BodyMetricsTargets.mc` | Persiste gli obiettivi personalizzati |
| `source/BodyMetricsGarminProfile.mc` | Legge il Garmin UserProfile (peso, ecc.) |
| `source/trend/BodyMetricsTrendCacheService.mc` | Cache di presentazione per le finestre trend |

Le policy devono rimanere **senza effetti collaterali**.

### Layer 6 — Localizzazione

| File | Responsabilità |
|------|---------------|
| `source/BodyMetricsLocale.mc` | Adapter di lookup runtime (unica interfaccia pubblica per la localizzazione) |
| `source/i18n/BodyMetricsLocaleCatalog.mc` | Catalogo traduzioni multilingue (IT, EN, FR, ES) |
| `source/i18n/BodyMetricsLocaleValidator.mc` | Validatore di completezza per lo sviluppo |

## Regole di Dipendenza

```
View  ──────────→  Domain  ──────→  UseCase  ──→  Storage / Servizi
  │                   │                             │
  └──→  Renderer       └──────────────────→  Policy
            │
            └──→  RendererCommon
```

- La **View** può chiamare Domain e Renderer; non deve accedere direttamente allo storage.
- I **Renderer** dipendono solo da RendererCommon e dal modello di rendering.
- Gli **UseCase** dipendono da storage, servizi e policy; mai da view o renderer.
- Le **Policy** sono funzioni pure — nessun effetto collaterale, nessun I/O.
- I lookup **Locale** passano sempre attraverso `BodyMetricsLocale`; l'accesso grezzo al catalogo è riservato al validatore.

## Vincoli per le Funzioni Globali

Due funzioni globali sono le implementazioni autoritative uniche nell'intero codebase:

| Funzione | File | Scopo |
|----------|------|-------|
| `round1Global()` | `BodyMetricsDomain.mc` | Arrotondamento a una decimale |
| `fmt1Global()` | `BodyMetricsDomain.mc` | Formattazione stringa a una decimale |

Nessun file può definire equivalenti locali. Analogamente, le utility di rendering in `RendererCommon.mc` sono le uniche implementazioni autoritative di wrapping del testo, misurazione delle larghezze e disegno centrato.

## Varianti di Build

| Variante | Target | Locale | Stato |
|----------|--------|--------|-------|
| Full | `fr265` | IT, EN, FR, ES | ✅ Stabile (v15) |
| Lite | FR55, FR735XT | Solo EN | 🔲 Pianificata |

## Comando di Validazione

```bash
monkeyc -f monkey.jungle -d fr265 \
  -o /tmp/BodyMetrics-validation.prg \
  -y /percorso/bodymetrics-dev-key.pk8.der
```

## Vedi Anche

- [Renderer](../renderers/) — il layer di rendering in dettaglio.
- [Flusso dei Dati](../data-flow/) — come i dati si muovono dallo storage allo schermo.
- [Sistema i18n](../i18n-system/) — l'architettura di localizzazione.
