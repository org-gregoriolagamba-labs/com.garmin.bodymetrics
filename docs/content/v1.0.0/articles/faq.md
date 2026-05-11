---
title: "FAQ"
date: 2026-05-11
draft: false
summary: "Answers to the most common questions about BodyMetrics."
toc: true
weight: 60
tags: ["faq", "troubleshooting"]
---

## Installation & Compatibility

### Which devices are supported?

Currently only the **Garmin Forerunner 265** (`fr265`). A Lite build targeting the FR55 and FR735XT is in planning for a future release.

### Where do I download BodyMetrics?

From the **Garmin Connect IQ Store** via the Garmin Connect phone app, or directly at [apps.garmin.com](https://apps.garmin.com).

### Does BodyMetrics require a data connection?

No. All data is stored locally on the watch. An internet connection is only needed to download or update the widget.

---

## Data & Measurements

### Where does my weight come from if I never entered it?

BodyMetrics automatically reads weight from the **Garmin UserProfile** if it is available on the device (e.g. synced from Garmin Connect or a Garmin smart scale). If no Garmin weight is available, it will show the last manually entered value.

### Can I enter historical data?

No. BodyMetrics records a history snapshot each time you press **Enter data** in the Check-ins wizard. There is no interface to enter backdated readings.

### How do I clear all my data?

Go to **Menu → System → Reset Data** and confirm. This permanently deletes all measurements, history, and targets. Your profile is preserved.

{{< callout type="danger" >}}
Reset Data cannot be undone. Make sure you really want to delete everything before confirming.
{{< /callout >}}

### How do I clear a single metric value?

Inside the **Check-ins wizard**, press **MENU → Clear field** to reset the currently active field without affecting the others.

---

## Views & Navigation

### How do I open the Info screen quickly?

From the **Summary** screen, **long-press ENTER** (or START). This opens the Info screen directly for the currently selected metric.

### The Trend chart shows "not enough data" — why?

At least **two historical data points** are required to draw a trend line. Enter at least two check-ins on different days to see a chart.

### Can I change the trend time window?

Yes. Open the Trend screen and press **MENU** to select a different time window.

---

## Targets

### What is the "effective target"?

If you have set a custom target for a metric, that value is used. If you have not, BodyMetrics calculates a **policy-derived target** automatically from your profile (sex, age band, body profile, height). The effective target is always displayed — you never see an empty target.

### How do I reset a single target?

Open the **Targets wizard** (Menu → User data → Targets → Set), navigate to the metric, and press **MENU → Reset to default** to revert only that target.

---

## Language

### How do I change the language?

Go to **Menu → Preferences → Language**, choose a language, and press **ENTER**. The change takes effect immediately. See [Localization](../localization/) for all supported languages.

---

## Privacy & Data Storage

### Is any data sent to the cloud?

No. BodyMetrics does not send any data to external servers. All data is stored exclusively in the watch's local persistent storage.

### What data does the app store?

- User profile (sex, age band, body profile, height)
- Body measurements (weight, body fat, muscle mass, hydration, bone mass)
- History snapshots for each measurement entry
- Custom targets (if set)
- Selected language preference
