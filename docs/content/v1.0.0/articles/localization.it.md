---
title: "Localizzazione"
date: 2026-05-11
draft: false
summary: "Lingue supportate e come cambiare la lingua dell'interfaccia sul dispositivo."
toc: true
weight: 50
tags: ["localizzazione", "lingua", "i18n"]
---

## Lingue Supportate

BodyMetrics include traduzioni complete dell'interfaccia per quattro lingue:

| Lingua | Codice | Stato |
|--------|--------|-------|
| Italiano | `ita` | ✅ Completo |
| Inglese | `eng` | ✅ Completo (lingua di riferimento) |
| Francese | `fre` | ✅ Completo |
| Spagnolo | `spa` | ✅ Completo |

## Come Cambiare Lingua

1. Dalla schermata **Riepilogo**, premi **MENU**.
2. Naviga fino a **Preferenze**.
3. Seleziona **Lingua**.
4. Usa **SU / GIÙ** per scorrere tra le lingue disponibili.
5. Premi **ENTER** per confermare.

L'interfaccia si aggiorna immediatamente — non è necessario riavviare e nessun dato viene perso.

## Comportamento di Fallback

Se una chiave di traduzione mancasse nella lingua attiva, BodyMetrics applica il seguente ordine di fallback:

1. Traduzione nella lingua attiva
2. Traduzione in inglese (`eng`)
3. Chiave grezza (visibile solo in caso di bug)

In pratica, tutte e quattro le lingue sono complete e il percorso di fallback non viene mai raggiunto nelle build di produzione.

## Validazione delle Traduzioni (Sviluppatori)

Durante lo sviluppo, il **menu Debug** espone un **Validatore Traduzioni** che verifica ogni chiave del catalogo rispetto al riferimento inglese. Qualsiasi voce mancante o vuota viene segnalata come avviso.

Questo controllo è disponibile automaticamente nelle build di sviluppo che puntano a `fr265` con i simboli di debug abilitati.

## Vedi Anche

- [Sistema i18n — Design](../../design/i18n-system/) — architettura interna del catalogo traduzioni e dell'adapter locale.
