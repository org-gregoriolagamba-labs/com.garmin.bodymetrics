---
name: release-notes
description: Genera la voce di CHANGELOG.md per una release a partire dai commit dall'ultimo tag o dalla release precedente.
disable-model-invocation: true
argument-hint: <versione> [riferimento-git-precedente]
---

# Note di release

Argomenti: `$ARGUMENTS` (versione, es. `1.2.0`, e opzionalmente il riferimento git di partenza).

1. Determina l'intervallo: riferimento passato, altrimenti `git describe --tags --abbrev=0`, altrimenti
   il branch `main`. Leggi `git log --oneline <ref>..HEAD` e `git diff --stat <ref>..HEAD`.
2. Leggi le prime sezioni di `CHANGELOG.md` per imitarne formato e tono (titoli `### 🎉 Added`, `### 🔧 Changed`, ecc.,
   data `YYYY-MM-DD`).
3. Raggruppa i commit per tipo (`feat:`, `fix:`, `docs:`...) e scrivi le voci per l'utente finale, non per gli sviluppatori.
4. Se cambia il numero di dispositivi o la versione, segnala dove vanno aggiornati README, `manifest.xml` e docs.
5. Proponi la nuova sezione in cima a `CHANGELOG.md` e applicala solo dopo conferma. Non fare commit né tag.
