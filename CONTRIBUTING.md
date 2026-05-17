# Contributing Guidelines

Grazie per contribuire a BodyMetrics! 🚀  
Per mantenere qualità, ordine e tracciabilità, seguiamo un workflow semplice ma rigoroso.

---

## 🔒 Regole fondamentali

- ❌ **È vietato fare push diretto su `main`**
- ✅ Tutte le modifiche devono passare da:
  - un branch dedicato
  - una Pull Request
  - almeno 1 review
  - Build Monkey C completata con successo

Queste regole valgono **per tutti, inclusi gli admin**.

---

## 🌳 Struttura dei branch

| Branch | Scopo |
|--------|-------|
| `main` | Release stabili / produzione |
| `feature/*` | Nuove funzionalità |
| `bugfix/*` | Correzioni |

---

## 🏷️ Naming dei branch

Usa nomi chiari e descrittivi:

```
feature/short-description  
bugfix/short-description  
```

Esempi:
- `feature/body-composition-trends`
- `feature/multilingual-support-spanish`
- `bugfix/health-zone-calculation`

---

## 🔁 Workflow standard (feature / bugfix)

1. Parti da `develop`:
    ```bash
    git checkout develop
    git pull
    ```

2. Crea il tuo branch:
    ```bash
    git checkout -b feature/descrizione-breve
    ```

3. Lavora, committa e pusha sul tuo branch:
    ```bash
    git push origin feature/descrizione-breve
    ```

4. Apri una Pull Request verso main

5. Attendi:
    - almeno 1 approvazione
    - Build completata con successo

---

## 🔍 Pull Request: requisiti minimi

Ogni PR deve:
- avere un titolo chiaro
- descrivere cosa cambia e perché
- essere limitata a una singola responsabilità

**Checklist consigliata:**  
- codice testato su device Garmin (o simulatore)
- `./build.sh` completa senza errori
- nessun warning del compilatore Monkey C
- documentazione aggiornata (se necessario)
- nessun commit inutile (fix, debug, ecc.)
- naming coerente
- nessun file di build/output non necessario

### Documentazione

Se una modifica impatta:
- setup/build/testing (documentazione tecnica)
- metriche / calcoli / algoritmi (documentazione funzionale)
- interfaccia utente / usabilità

aggiorna anche:
- README principale
- docs/ (quando pertinente)
- commenti nel codice per logiche complesse

---

## 🔨 Build e Testing

### Build locale

```bash
# Build per Forerunner 265
./build.sh

# Oppure manualmente:
monkeyc -project monkey.jungle -device "Forerunner 265"
```

### Testing sul simulatore

```bash
# Usa lo script di build e run del progetto
./.vscode/run-bodymetrics-sim.sh
```

### Verifiche primarie

Prima di aprire una PR:
- ✅ Compila senza errori
- ✅ Nessun warning del compilatore
- ✅ Funzionamento verificato sul simulatore
- ✅ Metriche calcolate correttamente
- ✅ Testi e interfaccia localizzati correttamente

---

## 👮 Code Review & Ownership

**Le review sono obbligatorie**

Alcune aree del codice richiedono approvazione specifica (da parte dei Code Owners):

**Code Owner principale:**
@gregoriolagamba

---

## 🧹 Buone pratiche di collaborazione

- Preferisci commit piccoli e significativi
- Evita PR "giganti"
- Commenta il codice solo dove serve davvero
- Se una scelta non è ovvia, spiegala nella PR
- Testa sempre su device reale o simulatore prima di aprire PR
- Verifica il comportamento su risoluzioni diverse

---

## 📱 Considerazioni specifiche per lo sviluppo

### Metriche e calcoli

Se modifichi logiche di calcolo (BMI, BMR, Body Fat %, ecc.):
- Documentare la formula utilizzata
- Verificare su valori di test noti
- Controllare edge cases (valori estremi)
- Aggiornare commenti nel codice

### Localizzazione

BodyMetrics supporta più lingue:
- Modifiche all'interfaccia utente = aggiornare tutte le risorse-*
- Usare i file in `resources-*` per testi multilingua
- Testare su tutte le lingue supportate

### Compatibilità device

BodyMetrics è stato testato principalmente su Forerunner 265, ma:
- Documenta ogni limitazione device-specifica
- Usa le API Monkey C in modo compatibile
- Testa su risoluzioni diverse se possibile

---

## ❓ Dubbi o domande

In caso di dubbi:
- chiedi prima di forzare soluzioni
- usa le Pull Request anche per discussioni tecniche

Grazie per contribuire in modo ordinato e professionale! 💪
