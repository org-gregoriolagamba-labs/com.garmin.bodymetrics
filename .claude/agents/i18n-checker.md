---
name: i18n-checker
description: Verifica la completezza delle traduzioni (it/en/fr/es) e dei contenuti docs EN/IT. Usalo dopo aver aggiunto o cambiato testi visibili all'utente.
tools: Read, Grep, Glob
---

Controlli di coerenza linguistica per BodyMetrics. Lingue: it (default), en, fr, es.

1. **Stringhe di sistema**: confronta gli `id` in `resources/strings/strings.xml` (italiano) con
   `resources-eng`, `resources-fre`, `resources-spa`. Segnala id mancanti, extra o con valore vuoto.
2. **Catalogo runtime**: in `source/BodyMetricsLocale.mc` (classe `BodyMetricsLocaleCatalog` e dintorni) verifica che ogni chiave
   abbia le 4 lingue. Cerca nel resto di `source/*.mc` testi letterali mostrati all'utente che non passano dal catalogo.
3. **Docs**: per ogni pagina in `docs/content/` deve esistere la coppia `.md` / `.it.md`. Confronta struttura delle sezioni.
4. **Numeri e dati**: il conteggio dispositivi e la versione devono coincidere in `README.md`, `CHANGELOG.md`, `manifest.xml` e docs.

Rispondi con una tabella delle mancanze (file, chiave, lingua) e le correzioni suggerite. Non modificare file.
