# Panoramica Architetturale

## Scopo

BodyMetrics e` un'app Connect IQ per la consultazione di metriche corporee, trend storici e obiettivi personali. L'architettura separa coordinamento UI, rendering, workflow applicativi, regole di business, persistenza e localizzazione.

## Struttura a Layer

### UI e Navigazione

- `source/BodyMetricsView.mc` coordina modalita`, stato selezione, editor transienti, badge e dispatch verso i renderer.
- `source/BodyMetricsInputDelegate.mc` gestisce input hardware e touch traducendoli in transizioni di stato.
- `source/BodyMetricsMenuView.mc` gestisce menu custom, sottomenu e delegati di navigazione.

### Rendering

- `source/renderers/*` disegna solamente.
- I renderer ricevono modelli pronti per il rendering e non leggono storage o servizi applicativi.
- I renderer principali coprono summary/detail, trend, wizard setup/data/targets e info/target delta.
- `source/BodyMetricsQrcodeView.mc` visualizza il QR code del sito web a schermo intero; viene aperta dal delegate di `BodyMetricsBadgeInfoView` tramite `BodyMetricsView.openQrcodeView()`.

### Facade di Dominio

- `source/BodyMetricsDomain.mc` espone la superficie compatibile usata dalla view.
- Coordina use case, policy, locale e cache trend senza duplicare logica di presentazione.
- Non definisce costanti di storage key: quelle autorevoli risiedono nei rispettivi use case.

### Workflow Applicativi

- `source/usecases/BodyMetricsMeasurementsUseCase.mc` gestisce rilevazioni, campi editabili e valori derivati.
- `source/usecases/BodyMetricsProfileUseCase.mc` gestisce profilo utente e merge con dati Garmin.
- `source/usecases/BodyMetricsTargetsUseCase.mc` gestisce obiettivi utente e fallback target.
- `source/usecases/BodyMetricsTrendUseCase.mc` gestisce storico e trend.
- `source/usecases/BodyMetricsResetUserDataUseCase.mc` gestisce reset completo e invalidazioni collegate.

### Regole e Servizi

- `source/policies/BodyMetricsClassificationPolicy.mc` classifica le metriche in zone cromatiche.
- `source/policies/BodyMetricsThresholdFactory.mc` genera le soglie per ogni metrica e profilo; `potenzaRange()` e` derivato direttamente da `muscleKgRange()` scalato per 35.
- `source/policies/BodyMetricsHealthCalculators.mc` contiene i calcoli puri BMI, BMR e muscolo.
- `source/BodyMetricsHistory.mc`, `source/BodyMetricsDataProvider.mc`, `source/BodyMetricsTargets.mc` e `source/BodyMetricsGarminProfile.mc` gestiscono persistenza e integrazioni dati.
- `source/trend/BodyMetricsTrendCacheService.mc` e` una cache di presentazione e non la sorgente autorevole dei dati.

### Localizzazione

- `source/i18n/BodyMetricsLocale.mc` e` l'adapter unico per il lookup runtime.
- `source/i18n/BodyMetricsLocaleCatalog.mc` contiene il catalogo multilingua (IT, EN, FR, ES).
- `source/i18n/BodyMetricsLocaleValidator.mc` valida la completezza rispetto a `en`.

## Principi di Qualita` del Codice

- Le funzioni `round1Global()` e `fmt1Global()` sono le uniche implementazioni di arrotondamento e formattazione decimale nell'intera codebase: nessun file puo` definire versioni locali equivalenti.
- Le funzioni globali di rendering in RendererCommon sono l'unica implementazione autorizzata di wrapping testo, misurazione larghezza e disegno testo centrato.
- `measurementFieldCount()` e `profileFieldCount()` restituiscono costanti intere coerenti con le definizioni dei rispettivi campi: non ricostruiscono l'array a ogni chiamata.

## Vincoli Architetturali

- La view puo` parlare con domain e renderer, non con servizi di persistenza diretti.
- I renderer non mutano stato applicativo.
- Gli use case non dipendono da classi UI o helper di rendering.
- Le policy restano side-effect free.
- Il fallback locale e`: lingua corrente -> `en` -> chiave raw.
- Il Domain non ridefinisce costanti di storage chiave: ogni use case possiede le proprie.

## Flussi Principali

- Avvio app: setup iniziale se manca il profilo, altrimenti summary.
- Navigazione metriche: summary, detail, info, trend e delta target.
- Workflow di inserimento: profilo, rilevazioni e obiettivi tramite wizard.
- Workflow di supporto: cambio lingua, reset dati, debug locale/storico.

## Build Supportate

- **Full** (target `fr265`): build standard con tutte le localizzazioni (IT, EN, FR, ES) e tutte le funzionalita`.
- **Lite** (target dispositivi a risorse limitate come FR55, FR735XT): in pianificazione. Usera` un jungle dedicato, sorgenti separate e manterra` solo la localizzazione EN. Nessuna funzionalita` utente rimossa rispetto alla versione full.

## Stato del Documento

Aggiornato alla build v15 (10 maggio 2026). Riflette il refactoring Clean Code completo e la struttura architetturale corrente del repository.
