# Riferimento Tecnico

## Superfici Principali

- `source/BodyMetricsDomain.mc`: facade compatibile consumata dalla UI.
- `source/usecases/*`: workflow applicativi.
- `source/renderers/*`: rendering puro.
- `source/policies/*`: regole di classificazione e soglie.
- `source/i18n/*`: catalogo e lookup locale.
- `source/renderers/RendererCommon.mc`: funzioni globali condivise da tutti i renderer.

## Persistenza

### Componenti Chiave

- `source/BodyMetricsDataProvider.mc` gestisce rilevazioni e sorgente dati.
- `source/BodyMetricsHistory.mc` gestisce storico e debug history con cache in memoria.
- `source/BodyMetricsTargets.mc` gestisce target utente e target effettivi.
- `source/BodyMetricsGarminProfile.mc` adatta il profilo Garmin a un formato applicativo.

### Chiavi Storage Principali

| Chiave | Tipo | Componente | Descrizione |
|--------|------|------------|-------------|
| `bodyMetrics.profile.sex` | String | ProfileUseCase | Sesso utente (`male` / `female`) |
| `bodyMetrics.profile.ageBand` | String | ProfileUseCase | Fascia eta` (`18_39` / `40_59` / `60_plus`) |
| `bodyMetrics.profile.bodyProfile` | String | ProfileUseCase | Profilo corporeo (`general` / `endurance` / `strength`) |
| `bodyMetrics.profile.heightCm` | Number | ProfileUseCase | Altezza in cm |
| `bm.meas.weight` | Float | DataProvider | Peso manuale in kg |
| `bm.meas.fat` | Float | DataProvider | Grasso corporeo % |
| `bm.meas.muscleKg` | Float | DataProvider | Massa muscolare kg |
| `bm.meas.water` | Float | DataProvider | Acqua % |
| `bm.meas.bone` | Float | DataProvider | Massa ossea kg |
| `bm.meas.ts` | Number | DataProvider | Timestamp ultimo salvataggio |
| `bm.meas.src` | String | DataProvider | Sorgente dato peso (`garmin` / altro) |
| `bm.hist` | Array | History | Storico snapshot metrici (max 90 entry) |
| `bm.locale` | String | Locale | Lingua selezionata dall'utente |

### Regole

- Lo storico e` la sorgente autorevole per il trend.
- La cache trend deve essere invalidata dopo save, reset e mutazioni rilevanti.
- Il Domain non ridefinisce chiavi storage: le costanti autorevoli sono nei rispettivi use case.

## Calcoli e Policy

- BMI, BMR, muscle percent e potenza sono derivati da formule applicative.
- La classificazione usa policy dedicate e soglie generate dal threshold factory.
- I target effettivi dipendono da target utente, fallback default e policy della metrica.
- `potenzaRange()` e` derivato direttamente da `muscleKgRange()` moltiplicando ogni soglia per 35: nessun dato duplicato.
- Le funzioni `round1Global()` e `fmt1Global()` sono le uniche implementazioni autorizzate di arrotondamento e formattazione a una cifra decimale.

## Contratti UI

- La view coordina modalita` e stato ma non deve parlare con storage diretto.
- I renderer ricevono modelli gia` preparati e non eseguono side effect.
- I delegati input e menu traducono eventi in transizioni di stato.
- Il MENU key e` intercettato da `onMenu()` nell'InputDelegate: in modalita` wizard l'evento viene consumato senza aprire il menu di sistema.

## Sistema Informazioni (Sysinfo)

- La schermata `Informazioni` mostra: nome app, versione, data rilascio, autore e sito web.
- Il sito web e` visualizzato come QR code (`QrcodeWebsite`, 120×120 px) anziché come testo URL.
- La risorsa QR code e` dichiarata in `resources/drawables/drawables.xml` e il file e` `resources/drawables/qrcode_website.png`.

## Build e Validazione

### Build Full (fr265)

```bash
/home/gregorio/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b/bin/monkeyc \
  -f monkey.jungle -d fr265 \
  -o /tmp/bodymetrics_vN.prg \
  -y ~/.Garmin/ConnectIQ/Keys/bodymetrics-dev-key.pk8.der
```

### Avvio Simulatore

```bash
bash .vscode/run-bodymetrics-sim.sh
```

### Parametri Build (VS Code Task)

Il task `Monkey C: Build and Run BodyMetrics (fr265)` in `.vscode/tasks.json` invoca `.vscode/run-bodymetrics-sim.sh`.
Il device target e` parametrizzabile nello script; la modalita` full/lite sara` configurabile tramite variabile di ambiente o argomento al completamento della versione lite.

### Build Lite (in pianificazione)

La versione lite usera` un jungle dedicato (`monkey-lite.jungle`) e sorgenti separate che escludono le localizzazioni IT, FR, ES. Il target primario sara` FR55 e FR735XT. Nessuna funzionalita` utente verra` rimossa.

## Stato del Documento

Aggiornato alla build v15 (10 maggio 2026).
