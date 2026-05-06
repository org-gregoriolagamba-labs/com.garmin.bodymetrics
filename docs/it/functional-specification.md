# Specifica Funzionale

## Obiettivo del Prodotto

BodyMetrics permette all'utente di consultare metriche corporee, visualizzare il loro storico, impostare obiettivi e gestire un profilo personale su dispositivo Garmin compatibile.

## Capacita` Principali

- Visualizzazione sintetica delle metriche con classificazione a zone.
- Navigazione di dettaglio, informazione clinica e delta rispetto all'obiettivo.
- Visualizzazione trend storico per finestre temporali.
- Inserimento manuale di rilevazioni corporee.
- Configurazione e manutenzione del profilo utente.
- Gestione di obiettivi personalizzati per metrica.
- Cambio lingua e reset dati locali.

## Flussi Utente Principali

### Primo Avvio

- Se il profilo non e` configurato, l'app forza il workflow di setup.
- Il setup raccoglie almeno sesso, fascia eta`, profilo corporeo e altezza.
- Al termine il sistema salva il profilo e porta l'utente alla summary.

### Consultazione Metriche

- La schermata summary mostra una metrica alla volta con stato sintetico.
- L'utente puo` scorrere le metriche e accedere a detail, info, trend e target delta.
- I valori derivati vengono calcolati a partire da profilo e rilevazioni disponibili.

### Inserimento Rilevazioni

- Dal menu dati l'utente entra nel wizard di inserimento.
- Ogni campo viene modificato con cicli min/max/step definiti dal use case.
- Al salvataggio le rilevazioni aggiornano la persistenza e registrano uno snapshot storico.

### Gestione Obiettivi

- Dal menu obiettivi l'utente imposta target per le metriche supportate.
- Ogni target puo` essere impostato, resettato singolarmente o resettato in blocco.
- Se manca un target utente, il sistema usa il target effettivo derivato dalla policy.

### Trend e Storico

- Il trend usa lo storico persistito e non la cache come sorgente di verita`.
- Le finestre disponibili sono selezionabili dall'utente.
- In presenza di un solo dato storico l'app mostra uno stato dedicato e non un grafico incompleto.

## Dati Gestiti

- Profilo utente.
- Rilevazioni corporee manuali e dati peso da Garmin quando disponibili.
- Obiettivi personalizzati per metrica.
- Storico dei snapshot metrici.
- Preferenza lingua.

## Limiti Funzionali Correnti

- Il target hardware attivo documentato e` `fr265`.
- Le funzioni debug non fanno parte dello scope utente finale.
- Alcuni dati provengono da Garmin, altri sono solo manuali; la fonte deve restare distinguibile.