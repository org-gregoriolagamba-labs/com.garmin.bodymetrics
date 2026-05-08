# Release Notes

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
- il `manifest.xml` corrente non espone qui un numero di versione applicativa separato dalla documentazione;
- le funzioni debug esistono nel codice ma non fanno parte del perimetro utente finale del rilascio;
- non tutte le metriche corporee arrivano da Garmin: il peso puo` essere letto da `UserProfile`, mentre altre metriche restano manuali;
- lo storico trend dipende dalla disponibilita` di dati locali sufficienti.

### Note Sul Rilascio

- questa voce rappresenta la prima disponibilita` stabile pubblicabile di BodyMetrics;
- la release `1.0.0` definisce la baseline funzionale ufficiale di riferimento.
