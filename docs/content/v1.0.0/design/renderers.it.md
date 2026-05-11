---
title: "Sistema di Rendering"
date: 2026-05-11
draft: false
summary: "Come BodyMetrics disegna ogni schermata — renderer, utility condivise e contratto del modello di rendering."
toc: true
weight: 20
tags: ["rendering", "design", "disegno"]
---

## Principi di Design

Tutto il codice di disegno risiede in `source/renderers/`. I renderer:

1. **Ricevono un modello** — un `Dictionary` Monkey C costruito dalla view contenente solo ciò che è necessario per quella schermata.
2. **Disegnano e restituiscono** — possono restituire valori calcolati (ad es. coordinate del hitbox, stato di scorrimento) ma non scrivono nello storage né modificano lo stato applicativo.
3. **Non leggono mai dallo storage** — tutti i dati arrivano pre-caricati nel dizionario modello.

Questa separazione significa che i renderer possono essere testati o sostituiti indipendentemente, e la view rimane snella.

## Mappa dei Renderer

| Renderer | Schermate |
|----------|-----------|
| `BodyMetricsSummaryDetailRenderer` | Riepilogo, Dettaglio |
| `BodyMetricsWizardRenderer` | Procedura guidata Profilo, Misurazioni, Obiettivi |
| `BodyMetricsInfoTargetDeltaRenderer` | Schermata Info, Delta Obiettivo |
| `BodyMetricsTrendRenderer` | Grafico trend |
| `BodyMetricsQrcodeView` | QR code a schermo intero (non è un renderer — è una sottoclasse di View) |

## RendererCommon — Utility Condivise

`source/renderers/RendererCommon.mc` esporta funzioni globali usate da tutti i renderer:

| Funzione | Scopo |
|----------|-------|
| `wrapTextGlobal(dc, text, font, maxW)` | Suddivide una stringa in righe che rientrano in `maxW` |
| `splitWordsGlobal(text)` | Divide il testo in parole rispettando gli spazi bianchi |
| `fitTextBlockGlobal(dc, lines, maxW, maxH)` | Restituisce `{:lines, :font, :width}` per un blocco che rientra nei limiti dati |
| `maxTextWidthGlobal(dc, lines, font)` | Restituisce la larghezza in pixel della riga più larga |
| `drawCenteredTextBlockGlobal(dc, lines, font, cx, cy)` | Disegna un elenco di righe centrate in `(cx, cy)` |
| `availableWidthAtYGlobal(r, cy, y)` | Larghezza orizzontale disponibile alla riga pixel `y` su uno schermo circolare di raggio `r` |
| `pct(value, total)` | Restituisce `value / total` come percentuale float |

{{< callout type="note" >}}
Queste sono le uniche implementazioni autoritative del layout testuale nell'intero codebase. Nessun file renderer o view può definire equivalenti locali.
{{< /callout >}}

## Geometria dello Schermo Circolare

Il FR265 ha un display rotondo. `availableWidthAtYGlobal` usa la formula di Pitagora per calcolare la lunghezza della corda orizzontale a una data posizione verticale:

```
disponibile(y) = 2 × sqrt(r² − (y − cy)²)
```

Questo viene usato dalle funzioni di wrapping e layout del testo per evitare che il testo venga tagliato dai bordi curvi.

## Contratto del Modello di Rendering

La view costruisce un dizionario modello e lo passa al renderer appropriato. Esempio per la schermata Riepilogo:

```monkey-c
var model = {
    :metric     => selectedMetric,
    :value      => formattedValue,
    :unit       => unitString,
    :zoneColor  => classificationColor,
    :zoneName   => classificationLabel,
    :metricName => localizedName
};
summaryDetailRenderer.drawSummary(dc, model);
```

Ogni renderer documenta le proprie chiavi attese. Passare un modello incompleto genera un'eccezione a runtime durante lo sviluppo (fail-fast).

## Hitbox dell'Icona Info

`BodyMetricsSummaryDetailRenderer.drawSummary()` restituisce il bounding box dell'icona info in modo che la view possa rilevare i tap:

```monkey-c
var hitbox = summaryDetailRenderer.drawSummary(dc, model);
// hitbox è {:x, :y, :w, :h}
```

## Stato di Scorrimento (Schermata Info)

`BodyMetricsInfoTargetDeltaRenderer.drawInfo()` restituisce lo stato di scorrimento aggiornato:

```monkey-c
var state = infoTargetDeltaRenderer.drawInfo(dc, model);
// state è {:infoScrollY, :infoContentH}
```

La view memorizza questi valori e li ritrasmette al successivo ciclo di disegno, abilitando uno scorrimento con stato senza che il renderer possieda nessuno stato persistente.

## Vedi Anche

- [Architettura](../architecture/) — dove i renderer si collocano nella struttura a layer complessiva.
- [Flusso dei Dati](../data-flow/) — come i dati raggiungono il modello di rendering.
