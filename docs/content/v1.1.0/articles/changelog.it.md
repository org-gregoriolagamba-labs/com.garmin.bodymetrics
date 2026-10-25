---
title: "Changelog"
date: 2026-06-14
draft: false
summary: "Cronologia dei rilasci e principali cambiamenti per BodyMetrics."
toc: true
weight: 70
tags: ["changelog", "rilasci"]
---

## v1.1.0 — 14 giugno 2026

{{< badge color="blue" >}}espansione multi-dispositivo{{< /badge >}}

### 🎉 Evidenze

- **Supporto dei dispositivi espanso da 1 a 53 dispositivi Garmin**
- **Infrastruttura automatizzata di build e test multi-dispositivo**
- **Documentazione e guida di compatibilità dei dispositivi migliorate**

### Funzionalità

- Supporto espanso a 53 dispositivi Garmin Connect IQ su 11 famiglie di prodotti
  - Forerunner (11 dispositivi), Fenix (serie 7/8), Epix, Venu, Vivoactive
  - MARQ 2, Enduro 3, serie D2, Instinct 3 AMOLED, Descent, Approach
- Sistema automatizzato di validazione build multi-dispositivo (`.vscode/build-all-devices.sh`)
- Launcher del simulatore specifico per dispositivo con logica di retry (`.vscode/run-sim.sh`)
- Integrazione dei task di VS Code con dropdown di selezione dispositivo (53 dispositivi disponibili)
- Matrice di compatibilità dei dispositivi e rapporto di build completo

### Miglioramenti UX

- Ottimizzazione del rendering cross-device con interfaccia completamente adattiva
- Geometria dinamica degli accordi per schermi circolari
- Supporto sia per display MIP (e-ink) che AMOLED
- Nessun percorso di codice specifico per dispositivo richiesto (sistema di rendering universale)

### Architettura e Dipendenze

- Aggiornamento del livello API minimo da 1.2.0 a 2.3.0
- Garantisce compatibilità con i dispositivi Garmin moderni
- Supporta Application.Storage richiesto dal livello di persistenza dei dati
- Evita il limite di argomenti del metodo API 3.x (max 9 argomenti per metodo)
- Validazione build: **53/53 dispositivi superano** (100% di successo)

### Documentazione

- Aggiunta sezione "Dispositivi Supportati" nel README con elenco completo dei dispositivi
- Creata tabella completa di compatibilità dei dispositivi
- Aggiunta guida di test specifica per dispositivo
- Changelog esteso con breakdown completo delle funzionalità per v1.1.0

### Limitazioni Note ed Esclusioni

**Dispositivi Esclusi (incompatibilità API 3.x):**
- Forerunner 745, 945, 945 LTE (API 3.3/3.4)
- Descent MK 1, Descent MK 2, Descent 2 (API 3.4)
- MARQ Gen 1 (tutte le varianti: 2, Aviation, Athlete, Commander, Golfer, Expedition, Captain) - API 3.x

**Motivo:** Monkey C API 3.x ha un limite fisso di 9 argomenti per metodo. I metodi BodyMetrics `buildTargetMetric()`, `buildTargetMetricThresholds()` e `_drawMiniChart()` richiedono 10+ argomenti, causando errori di compilazione. Questi dispositivi verranno ri-aggiunti in un futuro rilascio quando Garmin risolverà questa limitazione API.

**Dispositivi a Bassa Memoria (esclusi pre-build):**
- 8 dispositivi con memoria widget < 256 KB (margine di sicurezza)
- Esempi selezionati: Forerunner 245, Instinct 2 varianti, ecc.

---

## v1.0.0 — 12 maggio 2026

{{< badge color="green" >}}primo rilascio stabile{{< /badge >}}

### Funzionalità

- Viste di riepilogo e dettagli per tutte le metriche tracciate.
- Schermi informativi con descrizioni delle metriche, zone di riferimento e contesto di lettura.
- Visualizzazione dei trend storici con finestre temporali selezionabili.
- Flusso di lavoro guidato al primo avvio per l'impostazione del profilo utente.
- Flusso di lavoro guidato per l'inserimento delle misurazioni corporee.
- Flusso di lavoro guidato per l'impostazione dei target personalizzati.
- Calcolo del delta target rispetto al target effettivo.
- Supporto per peso, grasso corporeo, massa muscolare, idratazione e massa ossea.
- Valori derivati: BMI, percentuale muscolare, BMR di riferimento e potenza di uscita.
- Cronologia locale per grafici di trend e stati informativi.
- Distinzione tra dati locali manuali e peso del profilo utente Garmin.
- Commutazione della lingua dell'interfaccia (IT, EN, FR, ES).
- Reset completo dei dati locali dell'app.
- **System Info → Website**: pulsante selezionabile che apre una vista QR code a schermo intero centrata sul display.
- Documentazione del progetto bilingue (IT/EN).

### Miglioramenti UX

- **Tasto MENU nella procedura guidata**: bloccato durante la modalità procedura guidata di inserimento dati per evitare l'apertura accidentale del menu di sistema.
- **Navigazione della procedura guidata**: accelerazione a pressione rapida per UP/DOWN — i tocchi consecutivi entro 600 ms aumentano progressivamente il moltiplicatore di passaggio (×1 → ×5 → ×10 → ×50).

### Architettura

- Architettura pulita a sei livelli: coordinamento UI, rendering, facciata di dominio, casi d'uso, regole di business e localizzazione.
- `round1Global()` / `fmt1Global()` globali come funzioni autoritative singole di arrotondamento e formattazione.
- `RendererCommon` come singola fonte autorevole di tutti i layout di testo e le utilità di disegno.
- Livello di policy puro e senza effetti collaterali (ClassificationPolicy, ThresholdFactory, HealthCalculators).
- Sistema i18n a tre componenti: catalogo, adapter e validatore di completezza.
- Servizio cache dei trend con invalidazione al salvataggio delle misurazioni, reset, cambio metrica e cambio finestra.

### Compatibilità

- Validato sul target `fr265`, build di riferimento v15: **BUILD RIUSCITO**.
