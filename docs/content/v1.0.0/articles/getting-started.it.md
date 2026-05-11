---
title: "Introduzione"
date: 2026-05-11
draft: false
summary: "Installa BodyMetrics sul tuo Forerunner 265 e completa la configurazione iniziale in pochi minuti."
toc: true
weight: 20
tags: ["installazione", "configurazione", "quickstart"]
---

## Prerequisiti

Prima di iniziare, assicurati di avere:

- Un **Garmin Forerunner 265** (l'unico dispositivo attualmente supportato).
- L'app **Garmin Connect** installata e abbinata all'orologio.
- Un account **Garmin Connect IQ** (gratuito, su [apps.garmin.com](https://apps.garmin.com)).

## Installazione

### Dallo Store Connect IQ

1. Apri l'app **Garmin Connect** sul tuo telefono.
2. Tocca **Altro → Connect IQ Store**.
3. Cerca **BodyMetrics**.
4. Tocca **Scarica** — il widget si installa in modalità wireless sull'orologio.

### Sideload Manuale / Sviluppatore

Se stai compilando dal sorgente o testando una build di sviluppo:

```bash
# Compila il widget
monkeyc -f monkey.jungle -d fr265 \
  -o bin/BodyMetrics.prg \
  -y /percorso/della/tua-chiave-dev.pk8.der

# Distribuisci sul dispositivo tramite Garmin Express o il simulatore CIQ SDK
```

{{< callout type="note" >}}
Le build per sviluppatori richiedono una chiave di firma personale. Generala con gli strumenti del Connect IQ SDK e non condividere mai il file privato `.pk8.der`.
{{< /callout >}}

## Primo Avvio

Quando apri BodyMetrics per la **prima volta**, l'app rileva che non è configurato nessun profilo e avvia automaticamente la **procedura guidata di configurazione**.

### Passaggio 1 — Sesso

Usa **SU / GIÙ** per scegliere il sesso biologico. Premi **ENTER** per confermare e passare al campo successivo.

### Passaggio 2 — Fascia d'Età

Seleziona la tua fascia d'età. Premi **ENTER** per confermare.

### Passaggio 3 — Profilo Corporeo

Seleziona la categoria del tuo profilo corporeo. Premi **ENTER** per confermare.

### Passaggio 4 — Altezza

Usa **SU / GIÙ** per impostare la tua altezza in centimetri. Premi **ENTER** per confermare.

### Passaggio 5 — Salva

Dopo l'ultimo campo, la procedura guidata salva il profilo e ti porta alla **schermata Riepilogo** — la vista principale dell'app.

{{< callout type="tip" >}}
L'app integra automaticamente il peso dal Garmin UserProfile quando è disponibile sul dispositivo, quindi potresti già vedere una lettura del peso nella schermata Riepilogo senza averlo inserito manualmente.
{{< /callout >}}

## Passi Successivi

- [Funzionalità](../features/) — esplora tutte le viste e le funzionalità.
- [Navigazione](../navigation/) — mappa completa dei tasti e dei percorsi menu.
- [Localizzazione](../localization/) — cambia la lingua dell'interfaccia.
