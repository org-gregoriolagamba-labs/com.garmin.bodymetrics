---
title: "Getting Started"
date: 2026-05-11
draft: false
summary: "Install BodyMetrics on your Forerunner 265 and complete first-run setup in minutes."
toc: true
weight: 20
tags: ["install", "setup", "quickstart"]
---

## Prerequisites

Before you begin, make sure you have:

- A **Garmin Forerunner 265** (the only currently supported device).
- The **Garmin Connect** app installed and paired with the watch.
- A **Garmin Connect IQ** account (free, at [apps.garmin.com](https://apps.garmin.com)).

## Installation

### From the Connect IQ Store

1. Open the **Garmin Connect** app on your phone.
2. Tap **More → Connect IQ Store**.
3. Search for **BodyMetrics**.
4. Tap **Download** — the widget installs over-the-air onto the watch.

### Manual / Developer Sideload

If you are building from source or testing a development build:

```bash
# Build the widget
monkeyc -f monkey.jungle -d fr265 \
  -o bin/BodyMetrics.prg \
  -y /path/to/your-dev-key.pk8.der

# Deploy to device via Garmin Express or the CIQ SDK simulator
```

{{< callout type="note" >}}
Developer builds require a personal signing key. Generate one with the Connect IQ SDK tools and never share the private `.pk8.der` file.
{{< /callout >}}

## First Launch

When you open BodyMetrics for the **first time**, the app detects that no profile is configured and starts the **setup wizard** automatically.

### Step 1 — Sex

Use **UP / DOWN** to choose your biological sex. Press **ENTER** to confirm and move to the next field.

### Step 2 — Age Band

Select your age range. Press **ENTER** to confirm.

### Step 3 — Body Profile

Select your body profile category. Press **ENTER** to confirm.

### Step 4 — Height

Use **UP / DOWN** to set your height in centimetres. Press **ENTER** to confirm.

### Step 5 — Save

After the last field, the wizard saves the profile and lands you on the **Summary screen** — the main view of the app.

{{< callout type="tip" >}}
The app automatically merges your weight from Garmin UserProfile when it is available on the device, so you may already see a weight reading on the Summary screen without entering it manually.
{{< /callout >}}

## What's Next?

- [Features](../features/) — explore all views and capabilities.
- [Navigation](../navigation/) — full key map and menu paths.
- [Localization](../localization/) — change the interface language.
