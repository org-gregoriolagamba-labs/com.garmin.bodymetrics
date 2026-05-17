---
title: "Changelog"
date: 2026-05-12
draft: false
summary: "Storico delle release e modifiche principali di BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "release"]
---

## v1.0.0 — 12 maggio 2026

{{< badge color="green" >}}prima release stabile{{< /badge >}}

### Funzionalità

- Viste riepilogo e dettaglio per tutte le metriche monitorate.
- Schermate informative con descrizioni delle metriche, zone di riferimento e contesto di lettura.
- Visualizzazione dello storico trend con finestre temporali selezionabili.
- Procedura guidata di primo avvio per la configurazione del profilo utente.
- Procedura guidata per l'inserimento delle misurazioni corporee.
- Procedura guidata per la configurazione degli obiettivi personalizzati.
- Calcolo del delta rispetto all'obiettivo effettivo.
- Supporto per peso, grasso corporeo, massa muscolare, idratazione e massa ossea.
- Valori derivati: BMI, percentuale muscolare, BMR di riferimento e potenza.
- Storico locale per grafici trend e stati informativi.
- Distinzione tra dati locali manuali e peso Garmin UserProfile.
- Cambio della lingua dell'interfaccia (IT, EN, FR, ES).
- Reset completo dei dati locali dell'app.
- **Info Sistema → Sito web**: pulsante selezionabile che apre una vista a schermo intero con il QR code centrato sul display.
- Documentazione di progetto bilingue (IT/EN).

### Rifinitura UX

- **Tasto MENU nelle procedure guidate**: bloccato durante l'inserimento dati per evitare l'apertura accidentale del menu di sistema.
- **Navigazione nella procedura guidata**: accelerazione per pressioni rapide consecutive su SU/GIÙ — pressioni ravvicinate entro 500 ms aumentano progressivamente il moltiplicatore (×1 → ×5 → ×10 → ×50).

### Architettura

- Architettura clean a sei layer: coordinamento UI, rendering, facade di dominio, use case, regole di business e localizzazione.
- Funzioni globali `round1Global()` / `fmt1Global()` come unica implementazione autoritativa di arrotondamento e formattazione.
- `RendererCommon` come unica fonte autoritativa per il layout testuale e le utility di disegno.
- Layer di policy puro e senza effetti collaterali (ClassificationPolicy, ThresholdFactory, HealthCalculators).
- Sistema i18n a tre componenti: catalogo, adapter e validatore di completezza.
- Cache trend con invalidazione su salvataggio misurazioni, reset, cambio metrica e cambio finestra temporale.

### Compatibilità

- Validato sul target `fr265`, build di riferimento v15: **BUILD SUCCESSFUL**.
