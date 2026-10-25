---
name: add-device
description: Aggiunge un dispositivo Garmin a manifest.xml, verifica la build e aggiorna README, CHANGELOG e docs.
disable-model-invocation: true
argument-hint: <device-id> [famiglia]
---

# Aggiungere un dispositivo

Argomento: `$ARGUMENTS` (id prodotto Connect IQ, es. `fenix8solar51mm`).

1. Verifica che l'id non sia già in `manifest.xml` (`grep -c 'iq:product id="<id>"' manifest.xml`) e che esista nell'SDK
   (`ls ~/.Garmin/ConnectIQ/Devices | grep <id>`). Se non esiste, fermati e dillo.
2. Controlla i requisiti: API level >= 2.3.0 e memoria widget sufficiente. Dispositivi con API 3.3/3.4 hanno
   problemi noti (limite di 9 argomenti per metodo), vedi il commento sul manifest.
3. Il manifest è protetto da un hook. Sblocca solo per questa operazione:
   `touch .claude/.allow-manifest-edit`, modifica `manifest.xml` inserendo il prodotto nella sua famiglia
   (con il commento di famiglia esistente), poi rimuovi il file: `rm .claude/.allow-manifest-edit`.
4. Compila il nuovo dispositivo con `monkeyc -d <id>`, con gli stessi parametri usati in `.vscode/build-all-devices.sh`.
   Se fallisce, ripristina il manifest e riporta l'errore.
5. Aggiorna il conteggio e l'elenco in `README.md` (sezione Supported Devices), `CHANGELOG.md`, `docs/content/_index.md`
   e `docs/content/_index.it.md`. Cerca il vecchio numero con `grep -rn "53" README.md CHANGELOG.md docs/content`.
6. Mostra il diff riassuntivo. Non fare commit.
