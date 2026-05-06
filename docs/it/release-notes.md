# Release Notes

## 1.0.0

- identificatore release o versione: `1.0.0`
- data: `2026-05-06`

### Contenuti Principali

- visualizzazione delle metriche corporee principali nelle viste summary e detail;
- schermate informative con descrizione della metrica, zone di riferimento e contesto di lettura;
- visualizzazione trend storico con finestre temporali dedicate;
- workflow guidato per configurazione del profilo utente al primo avvio;
- workflow guidato per inserimento delle rilevazioni corporee;
- workflow guidato per impostazione degli obiettivi personalizzati;
- calcolo del delta rispetto al target effettivo;
- supporto a peso, grasso corporeo, massa muscolare, acqua e massa ossea;
- calcolo di valori derivati come BMI, muscle percent, BMR di riferimento e potenza;
- supporto allo storico locale per alimentare grafici trend e stati informativi;
- distinzione tra dati manuali locali e peso disponibile da Garmin UserProfile;
- cambio lingua dell'interfaccia;
- reset completo dei dati locali dell'app;
- documentazione di base avviata in doppia lingua italiano/inglese.

### Fix Rilevanti Inclusi Nella Baseline 1.0.0

- corretta la gestione del trend con un solo dato storico, sostituendo lo stato ambiguo con un messaggio dedicato;
- corretta la forma delle entry di history debug per includere tutti i campi metrici previsti;
- corretta la ricarica dei dati dopo operazioni debug su history e disattivazione debug;
- corretta la navigazione dei badge e dei ritorni menu nelle azioni debug;
- corretta la gestione iniziale della ciclazione target per i campi che partono da zero.

### Limitazioni Note

- target prodotto documentato: `fr265`;
- permesso dichiarato nel manifest: accesso a `UserProfile`;
- il `manifest.xml` corrente non espone qui un numero di versione applicativa separato dalla documentazione;
- le funzioni debug esistono nel codice ma non fanno parte del perimetro utente finale del rilascio;
- non tutte le metriche corporee arrivano da Garmin: il peso puo` essere letto da `UserProfile`, mentre altre metriche restano manuali;
- lo storico trend dipende dalla disponibilita` di dati locali sufficienti.

### Note Sul Rilascio

- questa voce rappresenta la baseline funzionale documentata della prima versione `1.0.0`;
- le release successive dovranno aggiungere solo variazioni incrementali rispetto a questa baseline, senza riscriverla interamente.

## Formato Per Le Prossime Voci

Ogni nuova voce dovrebbe includere almeno:

- identificatore release o versione;
- data;
- contenuti principali;
- fix rilevanti;
- eventuali limitazioni note.

## Template Riusabile

Per le prossime release usa come riferimento operativo il template condiviso in `docs/shared/changelog-template.md`.

### Blocco Copy-Paste Per 1.0.1

```md
## 1.0.1

- identificatore release o versione: `1.0.1`
- data: `YYYY-MM-DD`

### Contenuti Principali

- miglioramento puntuale 1;
- miglioramento puntuale 2;

### Fix Rilevanti

- fix 1;
- fix 2;

### Limitazioni Note

- limitazione ancora valida 1;
- limitazione ancora valida 2;

### Note Sul Rilascio

- nota di compatibilita` o validazione;
- differenza principale rispetto alla release precedente.
```

### Blocco Copy-Paste Per 1.1.0

```md
## 1.1.0

- identificatore release o versione: `1.1.0`
- data: `YYYY-MM-DD`

### Contenuti Principali

- nuova funzionalita` 1;
- nuova funzionalita` 2;
- miglioramento UX o documentale;

### Fix Rilevanti

- fix importante 1;
- fix importante 2;

### Limitazioni Note

- limitazione residua 1;
- vincolo hardware o di integrazione 2;

### Note Sul Rilascio

- sintesi dell'impatto della minor release;
- nota su compatibilita`, test o rollout.
```

### Regola Per Le Release Successive

- usa patch release come `1.0.2` o `1.0.3` per correzioni e aggiustamenti limitati;
- usa minor release come `1.2.0` o `1.3.0` quando introduci nuove funzionalita` o espansioni di flusso;
- mantieni sempre la stessa sequenza di sezioni per facilitare confronto e traduzione.