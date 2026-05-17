---
title: "Navigazione"
date: 2026-05-11
draft: false
summary: "Mappa completa dei tasti, diagramma delle viste e tutti i percorsi menu di BodyMetrics."
toc: true
weight: 40
tags: ["navigazione", "tasti", "menu"]
---

## Tasti Hardware

| Tasto | Azione |
|-------|--------|
| **SU** | Metrica precedente (Riepilogo) / diminuisci valore (procedura guidata) / scorri su (Info) |
| **GIÙ** | Metrica successiva (Riepilogo) / aumenta valore (procedura guidata) / scorri giù (Info) |
| **ENTER** / **START** | Conferma / apri vista più profonda |
| **BACK** / **ESC** / **LAP** | Chiudi la vista corrente e torna indietro |
| **MENU** | Apri menu contestuale o principale |
| **Tieni premuto SU** | Apri la schermata Info direttamente dal Riepilogo |

{{< callout type="note" >}}
In qualsiasi schermata della procedura guidata (Profilo, Check-in, Obiettivi), **MENU è bloccato** e non aprirà il menu di sistema. Questo evita navigazioni accidentali mentre stai modificando un campo.
{{< /callout >}}

## Mappa delle Viste

```
Riepilogo
├── ENTER                    → Dettaglio
│   └── BACK                 → Riepilogo
├── Tieni premuto SU         → Info (per la metrica corrente)
│   └── BACK                 → Riepilogo
├── BACK                     → Esci dall'app
└── MENU                     → Menu Principale
    ├── Dati utente
    │   ├── Profilo           → Procedura guidata profilo
    │   ├── Check-in
    │   │   ├── Inserisci dati  → Procedura guidata misurazioni
    │   │   └── Azzera dati     → Conferma e azzera
    │   └── Obiettivi
    │       ├── Imposta         → Procedura guidata obiettivi
    │       └── Reimposta tutti gli obiettivi
    ├── Preferenze
    │   └── Lingua            → Selettore lingua
    ├── Sistema
    │   ├── Informazioni      → Info di sistema (+ QR code)
    │   └── Reimposta dati    → Conferma e reimposta
    └── Debug (solo build dev)
```

## Sequenze Esatte dei Tasti Menu

### Menu di Primo Livello

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Dati utente | `MENU` → `ENTER` |
| Preferenze | `MENU` → `GIÙ` → `ENTER` |
| Sistema | `MENU` → `GIÙ` → `GIÙ` → `ENTER` |
| Debug | `MENU` → `GIÙ` → `GIÙ` → `GIÙ` → `ENTER` |

### Sotto-menu Dati Utente

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Profilo | `MENU` → `ENTER` → `ENTER` |
| Check-in | `MENU` → `ENTER` → `GIÙ` → `ENTER` |
| Obiettivi | `MENU` → `ENTER` → `GIÙ` → `GIÙ` → `ENTER` |

### Sotto-menu Check-in

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Inserisci dati | …`Check-in` → `ENTER` |
| Azzera dati | …`Check-in` → `GIÙ` → `ENTER` |

### Sotto-menu Obiettivi

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Imposta | …`Obiettivi` → `ENTER` |
| Reimposta tutti gli obiettivi | …`Obiettivi` → `GIÙ` → `ENTER` |

### Sotto-menu Preferenze

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Lingua | `MENU` → `GIÙ` → `ENTER` → `ENTER` |

### Sotto-menu Sistema

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Informazioni | `MENU` → `GIÙ` → `GIÙ` → `ENTER` → `ENTER` |
| Reimposta dati | `MENU` → `GIÙ` → `GIÙ` → `ENTER` → `GIÙ` → `ENTER` |

## Menu Contestuali dei Campi (Nelle Procedure Guidate)

| Azione | Sequenza Tasti |
|--------|---------------|
| Azzera campo corrente (procedura guidata Check-in) | `MENU` → `ENTER` |
| Reimposta al valore predefinito (procedura guidata Obiettivi) | `MENU` → `ENTER` |
