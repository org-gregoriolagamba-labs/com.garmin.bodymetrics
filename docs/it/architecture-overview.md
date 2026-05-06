# Panoramica Architetturale

## Scopo

BodyMetrics e` un'app Connect IQ per la consultazione di metriche corporee, trend storici e obiettivi personali. L'architettura separa coordinamento UI, rendering, workflow applicativi, regole di business, persistenza e localizzazione.

## Struttura a Layer

### UI e Navigazione

- `source/BodyMetricsView.mc` coordina modalita`, stato selezione, editor transienti, badge e dispatch verso i renderer.
- `source/BodyMetricsInputDelegate.mc` gestisce input hardware e touch traducendoli in transizioni di stato.
- `source/BodyMetricsMenuView.mc` gestisce menu custom, sottomeni e delegati di navigazione.

### Rendering

- `source/renderers/*` disegna solamente.
- I renderer ricevono modelli pronti per il rendering e non leggono storage o servizi applicativi.
- I renderer principali coprono summary/detail, trend, wizard setup/data/targets e info/target delta.

### Facade di Dominio

- `source/BodyMetricsDomain.mc` espone la superficie compatibile usata dalla view.
- Coordina use case, policy, locale e cache trend senza duplicare logica di presentazione.

### Workflow Applicativi

- `source/usecases/BodyMetricsMeasurementsUseCase.mc` gestisce rilevazioni, campi editabili e valori derivati.
- `source/usecases/BodyMetricsProfileUseCase.mc` gestisce profilo utente e merge con dati Garmin.
- `source/usecases/BodyMetricsTargetsUseCase.mc` gestisce obiettivi utente e fallback target.
- `source/usecases/BodyMetricsTrendUseCase.mc` gestisce storico e trend.
- `source/usecases/BodyMetricsResetUserDataUseCase.mc` gestisce reset completo e invalidazioni collegate.

### Regole e Servizi

- `source/policies/*` contiene classificazione, soglie e logica deterministica.
- `source/BodyMetricsHistory.mc`, `source/BodyMetricsDataProvider.mc`, `source/BodyMetricsTargets.mc` e `source/BodyMetricsGarminProfile.mc` gestiscono persistenza e integrazioni dati.
- `source/trend/BodyMetricsTrendCacheService.mc` e` una cache di presentazione e non la sorgente autorevole dei dati.

### Localizzazione

- `source/i18n/BodyMetricsLocale.mc` e` l'adapter unico per il lookup runtime.
- `source/i18n/BodyMetricsLocaleCatalog.mc` contiene il catalogo multilingua.
- `source/i18n/BodyMetricsLocaleValidator.mc` valida la completezza rispetto a `en`.

## Vincoli Architetturali

- La view puo` parlare con domain e renderer, non con servizi di persistenza diretti.
- I renderer non mutano stato applicativo.
- Gli use case non dipendono da classi UI o helper di rendering.
- Le policy restano side-effect free.
- Il fallback locale e`: lingua corrente -> `en` -> chiave raw.

## Flussi Principali

- Avvio app: setup iniziale se manca il profilo, altrimenti summary.
- Navigazione metriche: summary, detail, info, trend e delta target.
- Workflow di inserimento: profilo, rilevazioni e obiettivi tramite wizard.
- Workflow di supporto: cambio lingua, reset dati, debug locale/storico.

## Stato del Documento

Questo documento e` la panoramica architetturale di primo livello. I dettagli su storage, contratti tecnici e workflow funzionali verranno separati nei documenti dedicati dello stesso set bilingue.