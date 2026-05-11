---
title: "FAQ"
date: 2026-05-11
draft: false
summary: "Risposte alle domande più frequenti su BodyMetrics."
toc: true
weight: 60
tags: ["faq", "risoluzione-problemi"]
---

## Installazione e Compatibilità

### Quali dispositivi sono supportati?

Attualmente solo il **Garmin Forerunner 265** (`fr265`). Una build Lite per i dispositivi FR55 e FR735XT è in pianificazione per una release futura.

### Dove posso scaricare BodyMetrics?

Dal **Garmin Connect IQ Store** tramite l'app Garmin Connect sul telefono, o direttamente su [apps.garmin.com](https://apps.garmin.com).

### BodyMetrics richiede una connessione dati?

No. Tutti i dati sono salvati localmente sull'orologio. Una connessione internet è necessaria solo per scaricare o aggiornare il widget.

---

## Dati e Misurazioni

### Da dove viene il mio peso se non l'ho mai inserito?

BodyMetrics legge automaticamente il peso dal **Garmin UserProfile** se è disponibile sul dispositivo (ad es. sincronizzato da Garmin Connect o da una bilancia smart Garmin). Se non è disponibile nessun peso Garmin, verrà mostrato l'ultimo valore inserito manualmente.

### Posso inserire dati storici?

No. BodyMetrics registra uno snapshot storico ogni volta che premi **Inserisci dati** nella procedura guidata Check-in. Non è disponibile un'interfaccia per inserire letture con data precedente.

### Come cancello tutti i miei dati?

Vai su **Menu → Sistema → Reimposta dati** e conferma. Questo elimina definitivamente tutte le misurazioni, lo storico e gli obiettivi. Il profilo viene conservato.

{{< callout type="danger" >}}
Il reset dei dati non può essere annullato. Assicurati di voler davvero eliminare tutto prima di confermare.
{{< /callout >}}

### Come azzero il valore di una singola metrica?

Dentro la **procedura guidata Check-in**, premi **MENU → Azzera campo** per resettare il campo attivo senza influenzare gli altri.

---

## Viste e Navigazione

### Come apro rapidamente la schermata Info?

Dalla schermata **Riepilogo**, **tieni premuto ENTER** (o START). Questo apre direttamente la schermata Info per la metrica selezionata.

### Il grafico Trend mostra "dati insufficienti" — perché?

Servono almeno **due punti dati storici** per tracciare una linea di trend. Inserisci almeno due check-in in giorni diversi per vedere un grafico.

### Posso cambiare la finestra temporale del trend?

Sì. Apri la schermata Trend e premi **MENU** per selezionare una finestra temporale diversa.

---

## Obiettivi

### Cos'è l'"obiettivo effettivo"?

Se hai impostato un obiettivo personalizzato per una metrica, viene usato quel valore. Altrimenti, BodyMetrics calcola automaticamente un **obiettivo derivato dalla policy** basato sul tuo profilo (sesso, fascia d'età, profilo corporeo, altezza). L'obiettivo effettivo è sempre visualizzato — non vedrai mai un obiettivo vuoto.

### Come reimposto un singolo obiettivo?

Apri la **procedura guidata Obiettivi** (Menu → Dati utente → Obiettivi → Imposta), naviga fino alla metrica e premi **MENU → Reimposta al predefinito** per ripristinare solo quell'obiettivo.

---

## Lingua

### Come cambio la lingua?

Vai su **Menu → Preferenze → Lingua**, scegli una lingua e premi **ENTER**. La modifica ha effetto immediatamente. Vedi [Localizzazione](../localization/) per tutte le lingue supportate.

---

## Privacy e Dati

### I dati vengono inviati al cloud?

No. BodyMetrics non invia nessun dato a server esterni. Tutti i dati sono archiviati esclusivamente nell'area di storage locale persistente dell'orologio.

### Quali dati salva l'app?

- Profilo utente (sesso, fascia d'età, profilo corporeo, altezza)
- Misurazioni corporee (peso, grasso corporeo, massa muscolare, idratazione, massa ossea)
- Snapshot storici per ogni inserimento di misurazione
- Obiettivi personalizzati (se impostati)
- Preferenza lingua selezionata
