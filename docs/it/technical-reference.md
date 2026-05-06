# Riferimento Tecnico

## Superfici Principali

- `source/BodyMetricsDomain.mc`: facade compatibile consumata dalla UI.
- `source/usecases/*`: workflow applicativi.
- `source/renderers/*`: rendering puro.
- `source/policies/*`: regole di classificazione e soglie.
- `source/i18n/*`: catalogo e lookup locale.

## Persistenza

### Componenti Chiave

- `source/BodyMetricsDataProvider.mc` gestisce rilevazioni e sorgente dati.
- `source/BodyMetricsHistory.mc` gestisce storico e debug history.
- `source/BodyMetricsTargets.mc` gestisce target utente e target effettivi.
- `source/BodyMetricsGarminProfile.mc` adatta il profilo Garmin a un formato applicativo.

### Regole

- Lo storico e` la sorgente autorevole per il trend.
- La cache trend deve essere invalidata dopo save, reset e mutazioni rilevanti.
- I dettagli storage vanno mantenuti coerenti con il codice prima di essere promossi in documentazione esterna.

## Calcoli e Policy

- BMI, BMR, muscle percent e potenza sono derivati da formule applicative.
- La classificazione usa policy dedicate e soglie generate dal threshold factory.
- I target effettivi dipendono da target utente, fallback default e policy della metrica.

## Contratti UI

- La view coordina modalita` e stato ma non deve parlare con storage diretto.
- I renderer ricevono modelli gia` preparati e non eseguono side effect.
- I delegati input e menu traducono eventi in transizioni di stato.

## Build e Validazione

- Build manuale primaria:

```bash
/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc -f monkey.jungle -d fr265 -o /tmp/BodyMetrics-validation.prg -y /home/gregorio/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der
```

- Entry point simulatore:

```bash
bash .vscode/run-bodymetrics-sim.sh
```

## Prossimi Approfondimenti Previsti

- Tabella chiavi storage e tipi.
- Contratti pubblici del domain e dei use case.
- Matrice mode transition e trigger input.
- Workflow di localizzazione e checklist di allineamento IT/EN.