# Troubleshooting

## Problemi Comuni

### Non vedo il trend atteso

- Verifica che esistano abbastanza dati storici.
- Dopo una sola rilevazione, l'app puo` mostrare un messaggio dedicato invece di un grafico completo.

### Alcuni valori non arrivano da Garmin

- Non tutte le metriche sono lette dal profilo Garmin.
- Il peso puo` arrivare da Garmin, mentre altre metriche richiedono inserimento manuale.

### Ho cambiato lingua ma voglio verificare tutte le stringhe

- La verifica completa del catalogo e` un'azione di debug, non un workflow utente finale.

### Ho bisogno di ripartire da zero

- Usa la funzione di reset dati dal menu dedicato.
- Ricorda che il reset agisce sui dati locali dell'app.

## Diagnosi Tecnica Rapida

- Se il problema riguarda una regressione recente, ricompila con il comando `monkeyc` documentato.
- Se il problema e` visivo o di navigazione, verifica il comportamento nel simulatore con `.vscode/run-bodymetrics-sim.sh`.
- Se il problema riguarda traduzioni o badge di debug, separa sempre il flusso utente dal flusso dev-only durante l'analisi.