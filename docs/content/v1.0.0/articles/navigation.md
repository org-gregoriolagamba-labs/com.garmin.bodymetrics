---
title: "Navigation"
date: 2026-05-11
draft: false
summary: "Complete key map, view diagram, and all menu paths for BodyMetrics."
toc: true
weight: 40
tags: ["navigation", "keys", "menus"]
---

## Hardware Keys

| Key | Action |
|-----|--------|
| **UP** | Previous metric (Summary) / decrease value (wizard) / scroll up (Info) |
| **DOWN** | Next metric (Summary) / increase value (wizard) / scroll down (Info) |
| **ENTER** / **START** | Confirm / open deeper view |
| **BACK** / **ESC** / **LAP** | Close current view and go back |
| **MENU** | Open context or main menu |
| **Long-press UP** | Open Info screen directly from Summary |

{{< callout type="note" >}}
In any wizard screen (Profile, Check-ins, Targets), **MENU is blocked** and will not open the system menu. This prevents accidental navigation away while you are editing a field.
{{< /callout >}}

## View Map

```
Summary
├── ENTER                → Detail
│   └── BACK             → Summary
├── Long-press UP        → Info (for current metric)
│   └── BACK             → Summary
├── BACK                 → Exit app
└── MENU                 → Main Menu
    ├── User data
    │   ├── Profile       → Profile wizard
    │   ├── Check-ins
    │   │   ├── Enter data  → Measurement wizard
    │   │   └── Clear data  → Confirm & clear
    │   └── Targets
    │       ├── Set         → Target wizard
    │       └── Reset all targets
    ├── Preferences
    │   └── Language      → Language picker
    ├── System
    │   ├── Information   → System info (+ QR code)
    │   └── Reset Data    → Confirm & reset
    └── Debug (dev builds only)
```

## Exact Menu Key Sequences

### Top-Level Menus

| Destination | Key Sequence |
|-------------|-------------|
| User data | `MENU` → `ENTER` |
| Preferences | `MENU` → `DOWN` → `ENTER` |
| System | `MENU` → `DOWN` → `DOWN` → `ENTER` |
| Debug | `MENU` → `DOWN` → `DOWN` → `DOWN` → `ENTER` |

### User Data Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Profile | `MENU` → `ENTER` → `ENTER` |
| Check-ins | `MENU` → `ENTER` → `DOWN` → `ENTER` |
| Targets | `MENU` → `ENTER` → `DOWN` → `DOWN` → `ENTER` |

### Check-ins Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Enter data | …`Check-ins` → `ENTER` |
| Clear data | …`Check-ins` → `DOWN` → `ENTER` |

### Targets Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Set | …`Targets` → `ENTER` |
| Reset all targets | …`Targets` → `DOWN` → `ENTER` |

### Preferences Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Language | `MENU` → `DOWN` → `ENTER` → `ENTER` |

### System Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Information | `MENU` → `DOWN` → `DOWN` → `ENTER` → `ENTER` |
| Reset Data | `MENU` → `DOWN` → `DOWN` → `ENTER` → `DOWN` → `ENTER` |

## Contextual Field Menus (Inside Wizards)

| Action | Key Sequence |
|--------|-------------|
| Clear current field (Check-ins wizard) | `MENU` → `ENTER` |
| Reset to default (Targets wizard) | `MENU` → `ENTER` |
