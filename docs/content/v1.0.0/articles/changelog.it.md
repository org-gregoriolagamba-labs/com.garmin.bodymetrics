---
title: "Changelog"
date: 2026-05-11
draft: false
summary: "Storico delle release e modifiche principali di BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "release"]
---

## v1.0.1 — 10 maggio 2026

{{< badge color="blue" >}}patch di qualità{{< /badge >}}

### Modifiche Visibili all'Utente

- **Info Sistema → Sito web**: la voce Sito web è ora un pulsante selezionabile che apre una vista a schermo intero con il QR code centrato sul display.
- **Tasto MENU nelle procedure guidate**: il tasto MENU è ora bloccato durante le procedure guidate di inserimento dati; non apre più accidentalmente il menu di sistema mentre si modifica un campo.
- **Correzione etichetta**: l'etichetta `sysinfo.author` è stata corretta in tutte e quattro le lingue (Autore / Author / Auteur / Autor).
- **Vista badge info**: i valori sono stati ridotti a `FONT_XTINY` per evitare il troncamento su stringhe lunghe.
- **Navigazione nel simulatore**: navigazione SU/GIÙ adattiva — un singolo tocco produce ora un solo passo, coerente con il comportamento del dispositivo fisico.

### Refactoring Architetturale (Interno)

- Rimossi `_round1()` e `_fmt1()` duplicati da sei file; tutte le chiamate ora passano attraverso le funzioni globali `round1Global()` e `fmt1Global()`.
- Rimosso il metodo inutilizzato `calculateMusclePct()` da HealthCalculators.
- Rimossi gli helper renderer duplicati da MenuView in favore delle controparti globali.
- Rimosso il metodo inutilizzato `canOpenMenu()` dalla View.
- Rimossi cinque costanti `PROFILE_*_KEY` duplicate dal Domain.
- Rimossi cinque wrapper banali di una riga dal Domain.
- `potenzaRange()` ora deriva da `muscleKgRange()` scalata di 35 invece di duplicare la logica.
- `measurementFieldCount()` e `profileFieldCount()` restituiscono ora costanti intere invece di ricostruire l'array ad ogni chiamata.
- `fitTextBlockGlobal()` in RendererCommon restituisce ora `:width` nel dizionario risultante per un'interfaccia uniforme.
- Corretta una formattazione errata in `clearStoredMeasurements()` (newline mancante dopo la firma della funzione).

### Compatibilità

- Nessuna funzionalità visibile all'utente rimossa.
- Validato sul target `fr265`, build di riferimento v15: **BUILD SUCCESSFUL**.

---

## v1.0.0 — 6 maggio 2026

{{< badge color="green" >}}prima release stabile{{< /badge >}}

### Funzionalità Incluse

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
- Documentazione di progetto bilingue (IT/EN) avviata.
