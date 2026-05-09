# Troubleshooting

## Problemi Comuni

### Non vedo il trend atteso

- Verifica che esistano abbastanza dati storici.
- Dopo una sola rilevazione, l'app puo` mostrare un messaggio dedicato invece di un grafico completo.

### Alcuni valori non arrivano da Garmin

- Non tutte le metriche sono lette dal profilo Garmin.
- Il peso puo` arrivare da Garmin, mentre altre metriche richiedono inserimento manuale.

### Nel simulatore UP/DOWN non cambiano il valore del campo

- Il simulatore invia solo `PRESS_TYPE_ACTION` senza la sequenza down/repeat/up del dispositivo fisico.
- Questo comportamento e` atteso: ogni pressione produce un singolo passo di modifica.
- Sul dispositivo fisico la pressione prolungata attiva l'accelerazione adattiva (passo x10 dopo 1s, x50 dopo 3s).

### Il tasto MENU apre il menu di sistema durante l'inserimento dati

- Dal wizard di inserimento dati il tasto MENU è bloccato e non apre il menu di sistema.
- Se il menu di sistema si apre in modalita` wizard, e` una regressione: verificare che `onMenu()` nell'InputDelegate stia restituendo `true` quando `isWizardEditMode()` e` attivo.

### Ho cambiato lingua ma voglio verificare tutte le stringhe

- La verifica completa del catalogo e` un'azione di debug, non un workflow utente finale.

### Ho bisogno di ripartire da zero

- Usa la funzione di reset dati dal menu dedicato.
- Ricorda che il reset agisce sui dati locali dell'app.

### Il QR code del sito web non si legge

- Il QR code e` un'immagine PNG 120x120 px: e` ottimizzato per dispositivi con schermo tondo tipo FR265.
- Avvicinare la fotocamera dello smartphone a una distanza adeguata e assicurarsi che lo schermo del watch sia sufficientemente luminoso.

## Diagnosi Tecnica Rapida

- Se il problema riguarda una regressione recente, ricompila con il comando `monkeyc` documentato in `technical-reference.md`.
- Se il problema e` visivo o di navigazione, verifica il comportamento nel simulatore con `.vscode/run-bodymetrics-sim.sh`.
- Se il problema riguarda traduzioni o badge di debug, separa sempre il flusso utente dal flusso dev-only durante l'analisi.
- Se un renderer mostra valori formattati in modo anomalo, verifica che non esista una versione locale di `_round1` o `_fmt1`: l'unica implementazione autorizzata sono le funzioni globali `round1Global()` e `fmt1Global()`.
