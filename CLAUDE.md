# BodyMetrics

Widget Garmin Connect IQ (Monkey C) per il monitoraggio della composizione corporea.
Supporta 53 dispositivi Garmin, 4 lingue (it/en/fr/es), API level minimo 2.3.0.

## Struttura

- `source/*.mc`: codice dell'app (entry `BodyMetricsApp`, viste, dominio, storico, target, locale)
- `BodyMetricsLocale.mc`: catalogo traduzioni a runtime (lingua di default: `it`)
- `resources/`, `resources-{eng,fre,spa}/strings/strings.xml`: stringhe di sistema (`resources/` = italiano)
- `manifest.xml`: elenco dei prodotti supportati (file marcato come generato)
- `monkey.jungle`: progetto; `docs/`: sito Hugo (EN + IT)
- `.vscode/*.sh`: script di build e simulatore

## Comandi

SDK e chiave di firma sono nei percorsi locali già usati da `.vscode/*.sh`.

```bash
bash .vscode/build-all-devices.sh [--fail-fast]   # compila tutti i dispositivi del manifest
bash .vscode/run-sim.sh <device>                  # build + simulatore (default fr265)
```

Compilazione di un solo dispositivo: vedi `.claude/hooks/quick-build.sh`.
Non esiste una suite di test: la verifica è la build senza errori né warning, più il simulatore.

## Vincoli di Monkey C

- Memoria widget limitata: i dispositivi con API 3.3/3.4 e il limite di 9 argomenti per metodo
  hanno escluso fr745/fr945/fr945lte. Non superare 9 argomenti per metodo.
- Ogni nuovo dispositivo va verificato con la build completa, non solo con fr265.
- Ogni testo mostrato all'utente va nel catalogo `BodyMetricsLocale` in tutte e 4 le lingue.

## File generati (non modificare a mano)

`bin/`, `output/`, `docs/public/`, `*.iq`, `*.log`, `*.tmp.md`. Il `manifest.xml` si modifica solo
per aggiungere/rimuovere dispositivi (skill `add-device`); un hook blocca le altre modifiche
ai file generati.

## Workflow Git

- Mai push diretto su `main`: branch `feature/*` o `bugfix/*`, poi Pull Request (vedi `CONTRIBUTING.md`).
- Commit in stile conventional: `feat:`, `fix:`, `docs:`.
- Cambi a calcoli, UI o build: aggiornare `README.md`, `CHANGELOG.md` e `docs/` quando pertinente.
- Il numero di dispositivi (53) compare in README, CHANGELOG e docs: tenerlo coerente.

## Automazioni Claude

- Skill: `/build-all`, `/add-device`, `/release-notes`
- Subagent: `monkeyc-reviewer`, `i18n-checker`
- Hook in `.claude/settings.json`: blocco file generati, build rapida fr265 dopo modifiche a `.mc`
