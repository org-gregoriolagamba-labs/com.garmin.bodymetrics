---
name: build-all
description: Compila BodyMetrics per tutti i dispositivi del manifest e riassume i fallimenti per causa.
disable-model-invocation: true
allowed-tools: Bash(bash .vscode/build-all-devices.sh*)
---

# Build su tutti i dispositivi

1. Esegui `bash .vscode/build-all-devices.sh` dalla radice del progetto (aggiungi `--fail-fast` se richiesto in `$ARGUMENTS`).
2. Riporta `PASS`/`FAIL` totali.
3. Per ogni dispositivo fallito, raggruppa per causa:
   - memoria/heap insufficiente
   - API level o metodo non disponibile sul dispositivo
   - più di 9 argomenti per metodo
   - altro (riporta il messaggio del compilatore)
4. Per ogni gruppo proponi la correzione più piccola. Non modificare il codice senza conferma.
5. Se tutto passa, dillo in una riga.
