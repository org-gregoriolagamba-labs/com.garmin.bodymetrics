# Privacy E Gestione Dati

## Scopo

Questo documento descrive quali dati BodyMetrics legge, quali dati salva localmente, come li usa e cosa succede durante il reset.

## Dati Letti Dal Dispositivo Garmin

BodyMetrics legge il profilo Garmin tramite `UserProfile` quando il dispositivo lo rende disponibile.

I dati letti possono includere:

- peso in kg, derivato dal valore Garmin espresso in grammi;
- altezza in cm;
- sesso;
- fascia di eta` derivata dall'anno di nascita.

BodyMetrics non legge dal profilo Garmin:

- percentuale di grasso;
- percentuale di muscolo;
- percentuale di acqua;
- massa ossea;
- BMR.

## Dati Salvati Localmente Dall'App

L'app salva nello storage locale del dispositivo dati funzionali al proprio funzionamento.

Le principali categorie sono:

- rilevazioni manuali: peso, grasso corporeo, massa muscolare, acqua, massa ossea;
- metadati di aggiornamento: timestamp di salvataggio e origine del dato peso;
- obiettivi utente per le metriche supportate;
- cronologia degli snapshot metrici utilizzata dal trend;
- preferenze e stato profilo dell'app.

## Come Vengono Usati I Dati

- I dati profilo servono per personalizzare calcoli e soglie.
- Le rilevazioni manuali servono a mostrare valori correnti, metriche derivate e trend.
- Il peso Garmin, quando presente, ha priorita` sul peso manuale nella lettura corrente.
- Gli obiettivi utente servono al calcolo del delta rispetto al target.
- Lo storico locale serve a costruire i grafici trend e i messaggi di stato collegati.

## Dati Derivati Ma Non Inseriti Direttamente

Alcuni valori mostrati dall'app non sono inseriti direttamente dall'utente ma calcolati a runtime o in fase di ricostruzione delle metriche.

Tra questi:

- muscle percent;
- BMR di riferimento;
- BMI;
- potenza.

## Origine Dei Dati E Priorita`

- Il peso puo` arrivare da Garmin o da inserimento manuale.
- Le altre metriche corporee citate sopra sono gestite come dati manuali locali.
- Quando Garmin fornisce il peso, l'app lo considera sorgente prioritaria in lettura.

## Reset E Cancellazione Dati

Il reset completo dell'app cancella o ripristina i dati gestiti localmente dall'applicazione.

In particolare il reset coinvolge:

- profilo salvato dall'app;
- rilevazioni manuali salvate;
- obiettivi utente;
- storico locale delle metriche.

Il reset dell'app non dichiara la cancellazione dei dati custoditi da Garmin fuori dallo storage locale di BodyMetrics.

## Debug E Dati Temporanei

Le funzioni debug possono creare o sostituire temporaneamente lo storico locale per scopi di test. Queste funzioni sono destinate a sviluppo e validazione, non all'uso normale dell'utente finale.

## Limiti E Dichiarazioni

- Questo documento descrive il comportamento osservabile nel codice attuale del repository.
- Non introduce promesse di sincronizzazione cloud o invio remoto dei dati che non risultano documentate nel codice consultato.
- Per materiale export o store listing, questa pagina va mantenuta coerente con il codice e con le note di rilascio.