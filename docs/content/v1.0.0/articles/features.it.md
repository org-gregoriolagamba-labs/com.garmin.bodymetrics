---
title: "Funzionalità"
date: 2026-05-11
draft: false
summary: "Riferimento completo di tutte le viste, le funzionalità e i flussi operativi di BodyMetrics."
toc: true
weight: 30
tags: ["funzionalità", "riferimento"]
---

## Viste in Sintesi

BodyMetrics organizza le informazioni in cinque viste dedicate raggiungibili dalla schermata **Riepilogo**:

| Vista | Scopo |
|-------|-------|
| Riepilogo | Punto di accesso principale — una metrica alla volta con badge zona colore |
| Dettaglio | Analisi numerica espansa per la metrica selezionata |
| Info | Descrizione clinica, zone di riferimento e contesto di lettura |
| Trend | Grafico storico con finestre temporali selezionabili |
| Delta Obiettivo | Distanza dall'obiettivo effettivo per la metrica selezionata |

## Schermata Riepilogo

La schermata Riepilogo è la prima cosa che vedi dopo la configurazione. Mostra:

- Il **nome della metrica** e il suo **valore attuale**.
- Un **badge zona colore** che indica dove cade la lettura (sano, borderline, fuori range).
- Suggerimenti per le azioni disponibili.

Usa **SU / GIÙ** per scorrere tra tutte le metriche monitorate. Ogni metrica ricorda l'ultimo valore inserito.

## Schermata Dettaglio

Premi **ENTER** nella schermata Riepilogo per aprire il Dettaglio. Mostra un'analisi numerica più ricca — ad esempio, sia la massa muscolare in kg che la percentuale muscolare derivata.

## Schermata Info

Dal Riepilogo, premi **MENU** (tieni premuto SU sul FR265), poi **ENTER** per aprire la schermata Info per la metrica corrente.

Info mostra:

- Una descrizione testuale della metrica.
- Zone di riferimento con confini basso / normale / alto.
- Contesto su cosa influenza la lettura.

La schermata Info supporta lo **scorrimento** con SU / GIÙ quando il testo supera l'altezza dello schermo.

## Schermata Trend

Accessibile dalla schermata **Dettaglio** o tramite il percorso **Menu → Trend**.

Il Trend mostra un grafico a linee delle tue letture storiche per la metrica selezionata. Puoi cambiare tra le finestre temporali disponibili (ad es. ultimi 7 giorni, 30 giorni, 90 giorni) tramite il menu.

{{< callout type="note" >}}
Quando esiste un solo punto dati storico, BodyMetrics mostra uno stato dedicato "dati insufficienti" invece di un grafico incompleto o fuorviante.
{{< /callout >}}

## Schermata Delta Obiettivo

Mostra la distanza numerica e visiva tra la lettura corrente e l'**obiettivo effettivo** per la metrica selezionata.

L'obiettivo effettivo è:
- il tuo **obiettivo personalizzato**, se ne hai impostato uno; oppure
- l'**obiettivo derivato dalla policy**, calcolato automaticamente dal tuo profilo.

## Inserimento Misurazioni

Da **Menu → Dati utente → Check-in → Inserisci dati**, la procedura guidata di misurazione ti permette di inserire manualmente i valori per tutte le metriche monitorate.

Ogni campo usa un ciclo min/max/step — **SU aumenta** il valore, **GIÙ lo diminuisce**.

{{< callout type="tip" >}}
Premi lo stesso tasto più volte entro 600 ms per attivare l'accelerazione: ×1 → ×5 → ×10 → ×50. Fai una pausa o cambia direzione per azzerare.
{{< /callout >}}

Al salvataggio, l'app:
1. Aggiorna le letture correnti.
2. Registra uno snapshot storico per i grafici trend.
3. Ricalcola tutti i valori derivati.

## Gestione Obiettivi

Da **Menu → Dati utente → Obiettivi → Imposta**, la procedura guidata degli obiettivi ti permette di definire traguardi personali per ogni metrica.

Opzioni:
- **Imposta** — inserisci un obiettivo personalizzato.
- **Reimposta tutti gli obiettivi** — ripristina tutti gli obiettivi ai valori predefiniti derivati dalla policy.

## Gestione Profilo

Da **Menu → Dati utente → Profilo**, puoi rivedere e aggiornare i campi del profilo (sesso, fascia d'età, profilo corporeo, altezza) in qualsiasi momento.

## Cambio Lingua

Da **Menu → Preferenze → Lingua**, puoi cambiare la lingua dell'interfaccia. Vedi [Localizzazione](../localization/) per le lingue supportate.

## Schermata Informazioni di Sistema

Da **Menu → Sistema → Informazioni**, la schermata di sistema mostra:
- Nome e versione dell'app
- Data di rilascio
- Autore
- Sito web (come pulsante QR code selezionabile)

Premendo **ENTER** sulla voce sito web si apre una vista a schermo intero con il QR code.

## Reset Completo dei Dati

Da **Menu → Sistema → Reimposta dati**, puoi cancellare tutte le misurazioni locali, lo storico e gli obiettivi. Il profilo viene conservato per impostazione predefinita.

{{< callout type="danger" >}}
Il reset dei dati è irreversibile. Tutte le letture storiche e gli obiettivi personalizzati verranno eliminati definitivamente.
{{< /callout >}}
