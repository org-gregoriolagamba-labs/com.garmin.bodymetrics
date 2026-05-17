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
| **UP** | Previous metric (Summary) / increase value (wizard) / scroll up (Info) |
| **DOWN** | Next metric (Summary) / decrease value (wizard) / scroll down (Info) |
| **ENTER** / **START** | Confirm / open deeper view |
| **BACK** / **ESC** / **LAP** | Close current view and go back |
| **MENU** / **Long-press UP** | Open main menu (from Summary: Metric Info is the first item) |

{{< callout type="note" >}}
In any wizard screen (Profile, Check-ins, Targets), **MENU is blocked** and will not open the system menu. This prevents accidental navigation away while you are editing a field.
{{< /callout >}}

{{< callout type="tip" >}}
In wizard screens, **UP and DOWN** support rapid-press acceleration: consecutive taps within 600 ms progressively increase the step multiplier (×1 → ×5 → ×10 → ×50). The streak resets when you pause or change direction.
{{< /callout >}}

## View Map

```
Summary
├── ENTER                → Detail
│   └── BACK             → Summary
├── BACK                 → Exit app
└── MENU / Long-press UP → Main Menu
    ├── Metric Info       → Info (for current metric)  [Summary only]
    │   └── BACK          → Summary
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
| Metric Info (Summary only) | `MENU` → `ENTER` |
| User data | `MENU` → `DOWN` → `ENTER` |
| Preferences | `MENU` → `DOWN` → `DOWN` → `ENTER` |
| System | `MENU` → `DOWN` → `DOWN` → `DOWN` → `ENTER` |
| Debug | `MENU` → `DOWN` → `DOWN` → `DOWN` → `DOWN` → `ENTER` |

### User Data Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Profile | `MENU` → `DOWN` → `ENTER` → `ENTER` |
| Check-ins | `MENU` → `DOWN` → `ENTER` → `DOWN` → `ENTER` |
| Targets | `MENU` → `DOWN` → `ENTER` → `DOWN` → `DOWN` → `ENTER` |

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
| Language | `MENU` → `DOWN` → `DOWN` → `ENTER` → `ENTER` |

### System Sub-Menus

| Destination | Key Sequence |
|-------------|-------------|
| Information | `MENU` → `DOWN` → `DOWN` → `DOWN` → `ENTER` → `ENTER` |
| Reset Data | `MENU` → `DOWN` → `DOWN` → `DOWN` → `ENTER` → `DOWN` → `ENTER` |
