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
| **SU** | Metrica precedente (Riepilogo) / aumenta valore (procedura guidata) / scorri su (Info) |
| **GIÙ** | Metrica successiva (Riepilogo) / diminuisci valore (procedura guidata) / scorri giù (Info) |
| **ENTER** / **START** | Conferma / apri vista più profonda |
| **BACK** / **ESC** / **LAP** | Chiudi la vista corrente e torna indietro |
| **MENU** / **Tieni premuto SU** | Apri il menu principale (dal Riepilogo: Info metrica è la prima voce) |

{{< callout type="note" >}}
In qualsiasi schermata della procedura guidata (Profilo, Check-in, Obiettivi), **MENU è bloccato** e non aprirà il menu di sistema. Questo evita navigazioni accidentali mentre stai modificando un campo.
{{< /callout >}}

{{< callout type="tip" >}}
Nelle schermate della procedura guidata, **SU e GIÙ** supportano l'accelerazione per pressioni rapide: tocchi consecutivi entro 600 ms aumentano progressivamente il moltiplicatore (×1 → ×5 → ×10 → ×50). La serie si azzera quando ci si ferma o si cambia direzione.
{{< /callout >}}

## Mappa delle Viste

```
Riepilogo
├── ENTER                        → Dettaglio
│   └── BACK                     → Riepilogo
├── BACK                         → Esci dall'app
└── MENU / Tieni premuto SU      → Menu Principale
    ├── Info metrica              → Info (per la metrica corrente)  [solo Riepilogo]
    │   └── BACK                  → Riepilogo
    ├── Dati utente
    │   ├── Profilo               → Procedura guidata profilo
    │   ├── Check-in
    │   │   ├── Inserisci dati    → Procedura guidata misurazioni
    │   │   └── Azzera dati       → Conferma e azzera
    │   └── Obiettivi
    │       ├── Imposta           → Procedura guidata obiettivi
    │       └── Reimposta tutti gli obiettivi
    ├── Preferenze
    │   └── Lingua                → Selettore lingua
    ├── Sistema
    │   ├── Informazioni          → Info di sistema (+ QR code)
    │   └── Reimposta dati        → Conferma e reimposta
    └── Debug (solo build dev)
```

## Sequenze Esatte dei Tasti Menu

### Menu di Primo Livello

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Info metrica (solo Riepilogo) | `MENU` → `ENTER` |
| Dati utente | `MENU` → `GIÙ` → `ENTER` |
| Preferenze | `MENU` → `GIÙ` → `GIÙ` → `ENTER` |
| Sistema | `MENU` → `GIÙ` → `GIÙ` → `GIÙ` → `ENTER` |
| Debug | `MENU` → `GIÙ` → `GIÙ` → `GIÙ` → `GIÙ` → `ENTER` |

### Sotto-menu Dati Utente

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Profilo | `MENU` → `GIÙ` → `ENTER` → `ENTER` |
| Check-in | `MENU` → `GIÙ` → `ENTER` → `GIÙ` → `ENTER` |
| Obiettivi | `MENU` → `GIÙ` → `ENTER` → `GIÙ` → `GIÙ` → `ENTER` |

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
| Lingua | `MENU` → `GIÙ` → `GIÙ` → `ENTER` → `ENTER` |

### Sotto-menu Sistema

| Destinazione | Sequenza Tasti |
|--------------|---------------|
| Informazioni | `MENU` → `GIÙ` → `GIÙ` → `GIÙ` → `ENTER` → `ENTER` |
| Reimposta dati | `MENU` → `GIÙ` → `GIÙ` → `GIÙ` → `ENTER` → `GIÙ` → `ENTER` |
