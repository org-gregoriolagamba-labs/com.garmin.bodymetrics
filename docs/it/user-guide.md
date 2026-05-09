# Guida Utente

## A Chi Serve

Questa guida e` destinata all'utente finale che vuole configurare BodyMetrics e usare l'app per monitorare metriche corporee, storico e obiettivi.

## Come Leggere Questa Guida

- I walkthrough seguono l'ordine reale di utilizzo dell'app.
- Quando un flusso dipende da dati Garmin disponibili sul dispositivo, il comportamento viene indicato esplicitamente.

## Primo Avvio

1. Avvia l'app sul dispositivo.
2. Completa il setup del profilo richiesto al primo avvio.
3. Salva il wizard per arrivare alla schermata summary.

### Walkthrough Completo: Configurazione Profilo

1. Apri BodyMetrics.
2. Se il profilo non e` ancora configurato, l'app entra direttamente nel wizard iniziale.
3. Imposta i campi richiesti nell'ordine proposto dal wizard, usando UP e DOWN per cambiare il valore.
4. Premi ENTER per confermare il campo corrente e passare al successivo.
5. Dopo l'ultimo campo, salva per completare il setup.
6. Verifica l'arrivo alla schermata summary come conferma della configurazione iniziale.

## Navigazione Base

- Usa `UP` e `DOWN` per cambiare metrica o valore del campo attivo.
- Usa `ENTER` (o `START`) per entrare nei livelli successivi o confermare nel wizard.
- Usa `BACK` (tasto `ESC`/`LAP`) per chiudere la vista corrente quando disponibile.
- Usa `MENU` per aprire i menu.
- **Pressione lunga richiesta**: da `Summary`, tieni premuto `ENTER` (o `START`) per aprire direttamente la vista `Info` della metrica corrente.
- **Pressione lunga non richiesta**: per aprire `Menu` basta una pressione breve su `MENU`.

### Mappa Rapida delle Viste

- Summary: punto di ingresso principale, una metrica alla volta.
- Detail: approfondimento sul valore corrente.
- Info: testo descrittivo e zone di riferimento.
- Trend: storico della metrica selezionata.
- Target delta: scostamento dal target effettivo.

### Percorsi Menu: Nomi Esatti E Tasti

- Aprire `Menu` dalla schermata principale: `MENU`.
- Aprire `Dati utente`: `MENU` -> `ENTER`.
- Aprire `Preferenze`: `MENU` -> `DOWN` -> `ENTER`.
- Aprire `Sistema`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER`.
- Aprire `Debug` (se visibile): `MENU` -> `DOWN` -> `DOWN` -> `DOWN` -> `ENTER`.

Percorsi interni da `Dati utente`:

- `Profilo`: `MENU` -> `ENTER` (`Dati utente`) -> `ENTER` (`Profilo`).
- `Rilevazioni`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `ENTER` (`Rilevazioni`).
- `Obiettivi`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `DOWN` -> `ENTER` (`Obiettivi`).

Percorsi interni da `Rilevazioni`:

- `Inserisci dati`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `ENTER` (`Rilevazioni`) -> `ENTER` (`Inserisci dati`).
- `Cancella rilevazioni`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `ENTER` (`Rilevazioni`) -> `DOWN` -> `ENTER` (`Cancella rilevazioni`).

Percorsi interni da `Obiettivi`:

- `Imposta`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `DOWN` -> `ENTER` (`Obiettivi`) -> `ENTER` (`Imposta`).
- `Reset completo`: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `DOWN` -> `ENTER` (`Obiettivi`) -> `DOWN` -> `ENTER` (`Reset completo`).

Percorsi interni da `Preferenze`:

- `Lingua`: `MENU` -> `DOWN` -> `ENTER` (`Preferenze`) -> `ENTER` (`Lingua`).

Percorsi interni da `Sistema`:

- `Informazioni`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`Sistema`) -> `ENTER` (`Informazioni`).
- `Reset Dati`: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`Sistema`) -> `DOWN` -> `ENTER` (`Reset Dati`).

Menu contestuali `Campo`:

- In wizard `Rilevazioni`: `MENU` -> `ENTER` (`Cancella campo`).
- In wizard `Obiettivi`: `MENU` -> `ENTER` (`Ripristina default`).
- In vista `Trend` (se esiste almeno uno storico): `MENU` -> `ENTER` (`Cancella ultimo dato`).

## Inserire le Rilevazioni

1. Apri `Menu` con `MENU`.
2. Entra in `Dati utente` con `ENTER`.
3. Entra in `Rilevazioni` con `DOWN` + `ENTER`.
4. Entra in `Inserisci dati` con `ENTER`.
5. Modifica i campi disponibili e completa il wizard.
6. Salva per aggiornare valori correnti e storico.

### Walkthrough Completo: Inserimento Dati

1. Dalla summary apri il menu dell'app.
2. Esegui la sequenza tasti esatta: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `ENTER` (`Rilevazioni`) -> `ENTER` (`Inserisci dati`).
3. Scorri i campi del wizard uno per volta.
4. Se il peso arriva da Garmin, il campo puo` risultare di sola lettura.
5. Inserisci o aggiorna grasso corporeo, massa muscolare, acqua e massa ossea quando disponibili.
6. Leggi i campi derivati come muscle percent e BMR senza modificarli direttamente.
7. Salva alla fine del wizard per aggiornare i valori correnti e registrare uno snapshot nello storico.
8. Per cancellare un singolo campo durante il wizard: `MENU` -> `ENTER` nel menu `Campo` su `Cancella campo`.

### Cosa Succede Dopo il Salvataggio

- I valori manuali vengono salvati nello storage locale dell'app.
- Il peso manuale resta salvato solo se il dispositivo non fornisce un peso Garmin prioritario.
- Lo storico viene aggiornato con uno snapshot delle metriche correnti.
- Il trend verra` ricalcolato sulle finestre disponibili.

## Leggere le Metriche

- Summary: vista rapida dello stato della metrica selezionata.
- Detail: piu` contesto sul valore attuale.
- Info: significato della metrica e zone di riferimento.
- Trend: andamento storico sulla finestra selezionata.
- Target delta: distanza tra valore attuale e obiettivo.

### Walkthrough Completo: Consultazione e Interpretazione

1. Parti dalla summary e seleziona la metrica desiderata.
2. Entra in detail per leggere il valore corrente con maggiore contesto.
3. Accedi a info per capire la metrica e le zone di riferimento.
4. Per aprire `Info` direttamente da `Summary` usa una pressione lunga su `ENTER` (o `START`).
5. In alternativa, tocca l'icona `(i)` quando visibile sulla schermata `Summary`.
6. Nel simulatore, se la pressione lunga non viene intercettata correttamente, usa due pressioni ravvicinate su `ENTER` come fallback.
7. Entra in trend per osservare l'andamento nel tempo.
8. Se presenti obiettivi, consulta target delta per vedere lo scostamento rispetto al target effettivo.

### Come Interpretare i Casi Particolari

- Se il trend ha dati insufficienti, l'app puo` mostrare un messaggio informativo al posto del grafico completo.
- Se e` presente un solo dato storico, il trend mostra uno stato dedicato che invita ad aggiungere un secondo dato.
- Alcune metriche sono calcolate e dipendono dai dati disponibili nel profilo e nelle rilevazioni.

## Gestire gli Obiettivi

1. Apri `Menu` con `MENU`.
2. Entra in `Dati utente` con `ENTER`.
3. Entra in `Obiettivi` con `DOWN` -> `DOWN` -> `ENTER`.
4. Entra in `Imposta` con `ENTER`.
5. Imposta i target desiderati per le metriche disponibili.
6. Usa il reset del campo o il reset totale quando necessario.

### Walkthrough Completo: Editor Obiettivi

1. Dalla schermata principale usa la sequenza esatta: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `DOWN` -> `ENTER` (`Obiettivi`) -> `ENTER` (`Imposta`).
2. Scegli la voce di impostazione obiettivi (`Imposta`).
3. Modifica i target disponibili uno alla volta con UP e DOWN.
4. Usa il menu contestuale `Campo` quando devi ripristinare il default del singolo target: `MENU` -> `ENTER` (`Ripristina default`).
5. Completa il wizard e salva per rendere attivi i nuovi obiettivi.
6. Se necessario, usa il reset totale con sequenza: `MENU` -> `ENTER` (`Dati utente`) -> `DOWN` -> `DOWN` -> `ENTER` (`Obiettivi`) -> `DOWN` -> `ENTER` (`Reset completo`).

## Cambio Lingua e Reset

- La lingua si cambia dal menu `Preferenze` -> `Lingua`.
- Il reset dati cancella configurazioni e dati locali dell'app dal menu `Sistema` -> `Reset Dati`.

### Walkthrough Completo: Cambio Lingua

1. Apri il menu `Preferenze`.
2. Usa la sequenza tasti esatta: `MENU` -> `DOWN` -> `ENTER` (`Preferenze`) -> `ENTER` (`Lingua`).
3. Scegli la lingua desiderata.
4. Verifica il ricaricamento delle etichette principali nelle schermate dell'app.

### Walkthrough Completo: Reset Dati

1. Apri il menu `Sistema` con la sequenza: `MENU` -> `DOWN` -> `DOWN` -> `ENTER` (`Sistema`).
2. Seleziona `Reset Dati` con `DOWN` -> `ENTER`.
3. Conferma l'azione.
4. Verifica il ritorno a uno stato coerente con profilo, rilevazioni, target e storico azzerati o ripristinati secondo il comportamento dell'app.

## Appendice Export

### Elementi Da Allegare Nella Versione Esportata

- Copertina con nome app, versione documento e lingua.
- Indice cliccabile.
- Screenshot finali che sostituiscono tutti i placeholder `SHOT-*`.
- Nota finale che rimanda a privacy e data handling.

### Asset Condivisi Consigliati

- Usa la cartella `docs/shared/screenshots/` per mantenere i riferimenti stabili.
- Se una schermata cambia in modo sostanziale, aggiorna sia la guida IT sia la guida EN nello stesso ciclo.

## Note Importanti

- Alcuni dati possono arrivare da Garmin, altri solo da inserimento manuale.
- Le funzioni debug non sono parte dell'uso normale dell'app.
- In presenza di storico insufficiente il trend puo` mostrare un messaggio informativo.
- Durante il wizard di inserimento dati, il tasto MENU è bloccato e non apre il menu di sistema.
- Il sito web nella schermata `Informazioni` e` mostrato come QR code: avvicinare la fotocamera dello smartphone per aprire il link.
- Per i dettagli su dati letti, dati salvati e reset, consulta `privacy-data-handling.md`.