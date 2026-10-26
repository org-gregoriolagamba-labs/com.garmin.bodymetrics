---
title: "Flusso dei Dati"
date: 2026-05-11
draft: false
summary: "Come i dati si muovono dallo storage persistente allo schermo in BodyMetrics."
toc: true
weight: 30
tags: ["flusso-dati", "design", "architettura"]
---

## Panoramica

I dati in BodyMetrics fluiscono in una sola direzione: dallo **storage persistente** attraverso gli **use case** e la **facade di dominio** alla **view**, che costruisce un **modello di rendering** passato a un **renderer**. Nessun layer legge a ritroso da un layer inferiore.

## Diagramma di Flusso

```
┌──────────────────────────────────────────────────────────────────────┐
│  Storage Persistente                                                 │
│  (DataProvider · History · Targets · GarminProfile)                 │
└──────────────────────────┬───────────────────────────────────────────┘
                           │ lettura / scrittura
┌──────────────────────────▼───────────────────────────────────────────┐
│  Use Case                                                            │
│  (Measurements · Profile · Targets · Trend · ResetUserData)          │
└──────────────────────────┬───────────────────────────────────────────┘
                           │ dati pronti per la view
┌──────────────────────────▼───────────────────────────────────────────┐
│  Facade di Dominio  (BodyMetricsDomain)                              │
│  + Policy (Classification · Thresholds · HealthCalculators)          │
│  + Cache Trend (TrendCacheService)                                   │
│  + Locale (BodyMetricsLocale)                                        │
└──────────────────────────┬───────────────────────────────────────────┘
                           │ view model / callback
┌──────────────────────────▼───────────────────────────────────────────┐
│  View  (BodyMetricsView)                                             │
│  Costruisce il dizionario modello di rendering                       │
└──────────────────────────┬───────────────────────────────────────────┘
                           │ {:metric, :value, :zone, …}
┌──────────────────────────▼───────────────────────────────────────────┐
│  Renderer                                                            │
│  Disegna su Graphics.Dc di Garmin                                    │
└──────────────────────────────────────────────────────────────────────┘
```

## Flusso di Avvio dell'App

1. `BodyMetricsApp.onStart()` inizializza il domain e crea la view.
2. La view verifica se esiste un profilo tramite il domain.
3. **Nessun profilo** → entra immediatamente in modalità procedura guidata di configurazione.
4. **Profilo esistente** → entra in modalità riepilogo.
5. La view chiama `onUpdate(dc)` ad ogni refresh del display, effettuando il dispatch al renderer corretto in base alla modalità corrente.

## Flusso di Navigazione tra Metriche

1. L'utente preme **SU / GIÙ** nella schermata Riepilogo.
2. `BodyMetricsInputDelegate` chiama `view.nextMetric()` / `view.previousMetric()`.
3. La view aggiorna `_selectedMetric` e richiede un ridisegno.
4. `onUpdate()` costruisce un nuovo modello dal domain e chiama `summaryDetailRenderer.drawSummary(dc, model)`.

## Flusso di Inserimento Misurazioni

1. L'utente apre la procedura guidata Check-in tramite menu.
2. La view entra in `MODE_DATA`.
3. SU/GIÙ scorrono nell'intervallo del campo delimitato (step e limiti definiti per campo in `MeasurementsUseCase`).
4. A **ENTER**, la view avanza al campo successivo.
5. Dopo l'ultimo campo, la view chiama `domain.saveMeasurements(values)`.
6. L'use case scrive su `DataProvider`, registra uno snapshot storico in `History` e invalida la cache trend.
7. La view ritorna alla modalità riepilogo.

## Flusso di Derivazione Obiettivo

Quando visualizza la schermata Delta Obiettivo, BodyMetrics risolve l'**obiettivo effettivo**:

```
Ha un obiettivo personalizzato dell'utente?
  SÌ → usa il valore dell'obiettivo personalizzato
  NO → chiama ThresholdFactory.effectiveTarget(metric, profile)
            → restituisce l'obiettivo derivato dalla policy
```

Il delta è `valoreCorrente − obiettivoEffettivo`, formattato e colorato dalla `ClassificationPolicy`.

## Flusso della Cache Trend

1. Lo storico viene caricato dallo storage persistente da `TrendUseCase`.
2. `TrendCacheService` pre-elabora e mette in cache le finestre per un rendering veloce.
3. La cache viene invalidata quando:
   - viene salvata una misurazione;
   - viene eseguito un reset completo;
   - vengono attivate azioni debug sullo storico;
   - cambia la metrica selezionata;
   - cambia la finestra trend.
4. In caso di cache miss, il servizio ricalcola dai dati storici grezzi.

## Integrazione del Peso Garmin

`ProfileUseCase` legge il peso Garmin UserProfile (se disponibile) e lo confronta con il peso salvato localmente. La regola di integrazione è:

- Se il peso Garmin è presente e l'utente non lo ha sovrascritto manualmente, viene usato il valore Garmin.
- Se l'utente ha inserito un peso manuale, il valore manuale ha la precedenza.

## Vedi Anche

- [Architettura](../architecture/) — il diagramma completo dei layer.
- [Sistema di Rendering](../renderers/) — come il modello di rendering viene consumato.
- [Sistema i18n](../i18n-system/) — come vengono risolte le stringhe localizzate.
