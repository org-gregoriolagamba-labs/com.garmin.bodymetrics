---
title: "Sistema i18n"
date: 2026-05-11
draft: false
summary: "Architettura di localizzazione — catalogo, adapter, fallback e aggiunta di nuove stringhe."
toc: true
weight: 40
tags: ["i18n", "localizzazione", "design"]
---

## Panoramica

BodyMetrics supporta quattro lingue — **Italiano (it)**, **Inglese (en)**, **Francese (fr)**, **Spagnolo (es)** — gestite da un sistema i18n a tre componenti:

| Componente | File | Ruolo |
|------------|------|-------|
| **Catalog** | `source/i18n/BodyMetricsLocaleCatalog.mc` | Dizionario master di tutte le stringhe per lingua |
| **Adapter** | `source/BodyMetricsLocale.mc` | Unica interfaccia pubblica per il lookup delle stringhe a runtime |
| **Validator** | `source/i18n/BodyMetricsLocaleValidator.mc` | Strumento da usare durante lo sviluppo per verificare la completezza |

## Struttura del Catalogo

Il catalogo è organizzato come dizionario di dizionari:

```monkey-c
// fonte: BodyMetricsLocaleCatalog.mc
class BodyMetricsLocaleCatalog {
    static function getCatalog() as Dictionary {
        return {
            "it" => {
                "app.title"            => "BodyMetrics",
                "metric.weight"        => "Peso",
                "metric.fat"           => "Grasso Corp.",
                // ... tutte le stringhe IT
            },
            "en" => {
                "app.title"            => "BodyMetrics",
                "metric.weight"        => "Weight",
                "metric.fat"           => "Body Fat",
                // ... tutte le stringhe EN
            },
            "fr" => { /* ... */ },
            "es" => { /* ... */ }
        };
    }
}
```

Le chiavi usano la notazione `dominio.chiave` in minuscolo con separatore `.`.

## Interfaccia dell'Adapter

Tutto il codice dell'app deve passare attraverso `BodyMetricsLocale` per ottenere le stringhe tradotte:

```monkey-c
// Configurazione (eseguita una volta all'avvio)
BodyMetricsLocale.setLanguage("it");

// Lookup a runtime
var label = BodyMetricsLocale.get("metric.weight");
// → "Peso"
```

L'adapter non deve mai essere bypassato. Le chiamate dirette al catalog sono riservate esclusivamente al validator.

## Catena di Fallback

Quando viene richiesta una stringa:

```
La chiave esiste nella lingua corrente?
  SÌ → restituisce la stringa locale
  NO → La chiave esiste in inglese?
         SÌ → restituisce la stringa inglese (fallback)
         NO → restituisce la chiave grezza (fallback debug)
```

Questo garantisce che l'interfaccia rimanga usabile anche in caso di traduzione incompleta, e che le chiavi mancanti siano visibili in sviluppo.

## Aggiungere Nuove Stringhe

Per aggiungere una nuova stringa:

1. **Aggiungi la chiave a tutte e quattro le lingue** nel catalogo.

{{< callout type="danger" >}}
Non aggiungere una chiave solo per una o due lingue. Il validator segnala le chiavi mancanti come errore. Una chiave mancante in produzione cade nel fallback inglese (o alla stringa grezza se manca anche in inglese).
{{< /callout >}}

2. **Usa il validator** per verificare la completezza:

```monkey-c
// BodyMetricsLocaleValidator.mc
// Chiamata dal Domain durante lo sviluppo (non in produzione)
BodyMetricsLocaleValidator.validate();
```

3. **Usa la nuova chiave** tramite l'adapter:

```monkey-c
var text = BodyMetricsLocale.get("my.new.key");
```

## Validatore

`BodyMetricsLocaleValidator.validate()` confronta i set di chiavi tra tutte le lingue e stampa eventuali chiavi mancanti nella console del simulatore. È un'operazione di sola lettura — non modifica lo storage né la configurazione corrente.

Da eseguire sempre dopo aver aggiunto o rinominato chiavi prima di fare commit.

## Persistenza dell'Impostazione Lingua

La lingua preferita dell'utente viene salvata da `ProfileUseCase` nello storage locale dell'app (chiave: `PROFILE_LANG_KEY`). Al successivo avvio:

1. `ProfileUseCase.loadProfile()` legge la chiave lingua.
2. Se trovata, chiama `BodyMetricsLocale.setLanguage(lang)`.
3. Se non trovata, viene usata la lingua predefinita (`"it"`).

## Codici Lingua Supportati

| Codice | Lingua | Risorse UI Garmin |
|--------|--------|-------------------|
| `it` | Italiano | `resources-ita/` |
| `en` | Inglese | `resources-eng/` |
| `fr` | Francese | `resources-fre/` |
| `es` | Spagnolo | `resources-spa/` |

Le risorse UI Garmin (stringhe nelle cartelle `resources-*/`) vengono compilate staticamente. Il catalogo i18n `BodyMetricsLocaleCatalog` gestisce le stringhe dinamiche dell'app visualizzate a runtime.

## Vedi Anche

- [Localizzazione](../../articles/localization/) — come gli utenti cambiano la lingua.
- [Architettura](../architecture/) — posizione del layer i18n nella struttura complessiva.
