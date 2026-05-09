# Release Notes

## 1.0.1

- identificatore release o versione: `1.0.1`
- data: `2026-05-10`
- tipologia rilascio: `patch di qualita` e UX`

### Contenuti Principali

- schermata informazioni sistema: la voce "Sito web" è ora un button che apre una schermata dedicata con il QR code centrato a tutto schermo;
- pulsante MENU in modalita` wizard di inserimento dati: il menu di sistema non si apre piu` per errore durante la modifica dei campi (fix onMenu);
- label `sysinfo.author` corretta in tutte le quattro lingue (Autore / Author / Auteur / Autor);
- testo dei valori nella vista informazioni badge ridotto a `FONT_XTINY` per evitare troncature su valori lunghi;
- navigazione adattiva con UP/DOWN nel simulatore: il singolo tap produce ora un passo singolo coerente con il comportamento del dispositivo fisico.

### Refactoring Architetturale

- rimosso codice duplicato di `_round1()` e `_fmt1()` da sei file (HealthCalculators, ThresholdFactory, MeasurementsUseCase, SummaryDetailRenderer, TrendRenderer, InfoTargetDeltaRenderer): tutto converge ora sulle funzioni globali `round1Global()` e `fmt1Global()`;
- rimosso metodo `calculateMusclePct()` da HealthCalculators: il calcolo avviene gia` inline in MeasurementsUseCase;
- rimosso codice duplicato dei renderer dalla MenuView (`maxTextWidth`, `drawCenteredLines`, `fitMenuText`) in favore di `maxTextWidthGlobal`, `drawCenteredTextBlockGlobal` e `fitTextBlockGlobal`;
- rimosso metodo morto `canOpenMenu()` dalla View (restituiva sempre `true`) e il relativo guard nell'InputDelegate;
- rimosse cinque costanti duplicate `PROFILE_*_KEY` dal Domain (duplicate di quelle autorevoli in ProfileUseCase);
- rimossi cinque wrapper triviali a una riga dal Domain (`_measurementField*`, `_resetState*`, `_loadedProfile*`): la logica e` ora inline nei siti di chiamata;
- `potenzaRange()` nel ThresholdFactory non duplica piu` la logica di `muscleKgRange()`: i threshold vengono ora derivati direttamente scalando per 35;
- `measurementFieldCount()` e `profileFieldCount()` restituiscono ora una costante intera invece di ricostruire l'array ad ogni chiamata;
- aggiunto `:width` al risultato di `fitTextBlockGlobal()` in RendererCommon, uniformando l'interfaccia con il resto dei renderer;
- corretto bug di formattazione in `clearStoredMeasurements()` in DataProvider (mancava un a-capo).

### Note Sul Rilascio

- nessuna funzionalita` utente rimossa;
- la versione lite per dispositivi a risorse limitate (FR55, FR735XT) e` in pianificazione: non fa parte di questo rilascio;
- compatibilita` confermata con il target `fr265`;
- build di riferimento: `v15`, validata con BUILD SUCCESSFUL.

---

## 1.0.0

- identificatore release o versione: `1.0.0`
- data: `2026-05-06`
- tipologia rilascio: `primo rilascio stabile`

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

### Limitazioni Note

- target prodotto documentato: `fr265`;
- permesso dichiarato nel manifest: accesso a `UserProfile`;
- le funzioni debug esistono nel codice ma non fanno parte del perimetro utente finale del rilascio;
- non tutte le metriche corporee arrivano da Garmin: il peso puo` essere letto da `UserProfile`, mentre altre metriche restano manuali;
- lo storico trend dipende dalla disponibilita` di dati locali sufficienti.

### Note Sul Rilascio

- questa voce rappresenta la prima disponibilita` stabile pubblicabile di BodyMetrics;
- la release `1.0.0` definisce la baseline funzionale ufficiale di riferimento.
