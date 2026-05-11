---
title: "Features"
date: 2026-05-11
draft: false
summary: "Full reference of all BodyMetrics views, capabilities, and workflows."
toc: true
weight: 30
tags: ["features", "reference"]
---

## Views at a Glance

BodyMetrics organises information into five dedicated views reachable from the **Summary** screen:

| View | Purpose |
|------|---------|
| Summary | Main entry point — one metric at a time with colour zone badge |
| Detail | Expanded numeric breakdown for the selected metric |
| Info | Clinical description, reference zones, and reading context |
| Trend | Historical chart with selectable time windows |
| Target Delta | Distance from the effective target for the selected metric |

## Summary Screen

The Summary screen is the first thing you see after setup. It displays:

- The **metric name** and its **current value**.
- A **colour zone badge** indicating where the reading falls (healthy, borderline, out of range).
- Shortcut hints for available actions.

Use **UP / DOWN** to cycle through all tracked metrics. Each metric remembers the last value you entered.

## Detail Screen

Press **ENTER** on the Summary screen to open Detail. It shows a richer numeric breakdown — for example, both muscle mass in kg and the derived muscle percentage.

## Info Screen

From Summary, **long-press ENTER** (or START) to open the Info screen for the current metric.

Info displays:

- A textual description of the metric.
- Reference zones with low / normal / high boundaries.
- Context about what influences the reading.

The Info screen supports **scrolling** with UP / DOWN when the text exceeds the screen height.

## Trend Screen

Accessible from the **Detail** screen or via the **Menu → Trend** path.

Trend shows a line chart of your historical readings for the selected metric. You can switch between available time windows (e.g. last 7 days, 30 days, 90 days) using the menu.

{{< callout type="note" >}}
When only one historical data point exists, BodyMetrics shows a dedicated "not enough data" state instead of an incomplete or misleading chart.
{{< /callout >}}

## Target Delta Screen

Shows the numerical and visual distance between the current reading and the **effective target** for the selected metric.

The effective target is either:
- your **custom target**, if you have set one; or
- the **policy-derived target** calculated automatically from your profile.

## Measurement Entry

From **Menu → User data → Check-ins → Enter data**, the measurement wizard lets you manually enter values for all tracked metrics.

Each field uses a bounded min/max/step cycle — UP increases the value, DOWN decreases it.

{{< callout type="tip" >}}
You can clear a single field in the wizard with **MENU → Clear field** without losing other entries.
{{< /callout >}}

On save, the app:
1. Updates the current readings.
2. Records a history snapshot for trend charts.
3. Recalculates all derived values.

## Target Management

From **Menu → User data → Targets → Set**, the target wizard lets you define personal goals for each metric.

Options:
- **Set** — enter a custom goal.
- **Reset all targets** — revert all goals to policy-derived defaults.

## Profile Management

From **Menu → User data → Profile**, you can revisit and update the profile fields (sex, age band, body profile, height) at any time.

## Language Switching

From **Menu → Preferences → Language**, you can switch the interface language. See [Localization](../localization/) for supported languages.

## System Info Screen

From **Menu → System → Information**, the system info screen displays:
- App name and version
- Release date
- Author
- Website (as a selectable QR code button)

Pressing **ENTER** on the website entry opens a full-screen QR code view.

## Full Data Reset

From **Menu → System → Reset Data**, you can erase all locally stored measurements, history, and targets. The profile is preserved by default.

{{< callout type="danger" >}}
Reset Data is irreversible. All historical readings and custom targets will be permanently deleted.
{{< /callout >}}
