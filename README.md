# BodyMetrics — Body Composition Tracking for Garmin Forerunner 265

[![License](https://img.shields.io/badge/license-Commons%20Clause%20%2B%20MIT-orange.svg)](LICENSE)
[![Monkey C](https://img.shields.io/badge/language-Monkey%20C-blue.svg)](https://developer.garmin.com/connect-iq/overview/)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](#releases)
[![API Level](https://img.shields.io/badge/API%20Level-1.2.0+-brightgreen.svg)](#requirements)

**BodyMetrics** is a native **Garmin Connect IQ widget** that brings comprehensive body composition tracking directly to your Forerunner 265 wrist. Monitor weight, body fat, muscle mass, hydration, bone mass, BMI, BMR, and muscular power — with historical trends, personalized targets, and color-coded health zones.

---

## ✨ Features

### 📊 9 Complete Metrics

- **Weight** (kg) — synchronized from Garmin Connect or manual entry
- **Body Fat** (%) — manual entry from smart scale
- **Muscle Mass** (kg) — manual entry; percentage derived automatically
- **Body Water** (%) — manual entry from smart scale
- **Bone Mass** (kg) — manual entry from smart scale
- **BMI** — calculated from weight + height + profile
- **BMR** (kcal/day) — Mifflin-St Jeor formula (scientific standard)
- **Muscular Power** (W) — derived from muscle mass using biomechanics

### 🟢 Health Zones at a Glance

Each metric displays a color-coded zone indicating your health status:
- **🟢 Green** — within healthy range, keep it up
- **🟡 Yellow** — mild attention needed, monitor trend
- **🟠 Orange** — time to take action
- **🔴 Red** — alarm zone, review your habits

### 🎯 Personalized Goals

- Automatically calculates ideal range based on sex, age, height, weight, and body type (General/Endurance/Strength)
- Override targets with your own personal goals
- Track delta (difference) vs. target for each metric
- See percentage progress toward your goals

### 📈 Historical Trends

- View trends over **7, 30, and 90 days**
- Automatic trend detection: improving ↗️ / stable ↔️ / declining ↘️
- Easy pattern recognition with historical data
- Verify if your efforts are working

### 🌍 Multilingual Support

- English
- Italiano (Italian)
- Français (French)
- Español (Spanish)

Switch languages anytime without losing data.

### ⚙️ Adaptive Profiles

Customize your body type:
- **General** — baseline standard thresholds
- **Endurance** — optimized for cardio athletes
- **Strength** — optimized for power athletes

Each type adjusts thresholds automatically for more accurate assessment.

---

## 📋 Requirements

### Hardware
- **Garmin Forerunner 265** or compatible device with Connect IQ support
- **Garmin Index S2** smart scale (recommended for automatic body composition sync)

### Software
- **Garmin Connect** app installed and configured on your smartphone
- Active phone-to-watch connection for data synchronization

### API Level
- Minimum: **Monkey C SDK 1.2.0**
- Target: **Monkey C SDK 4.x+**

---

## 🚀 Quick Start

### Installation

1. **Download** the widget from [Garmin Connect IQ Store](https://apps.garmin.com/)
2. **Open Connect IQ** on your Forerunner 265
3. **Search** for "BodyMetrics"
4. **Tap Install**
5. **Add to Screen** — swipe from the left to access your new widget

### Initial Setup

1. **Configure Profile** — sex, age, height, body type
2. **Enter Metrics** — weight, body fat %, muscle mass, hydration %, bone mass
3. **Set Targets** — customize goals for each metric (or use auto-calculated ranges)
4. **View Trends** — monitor your progress over time

### Data Entry

After each weighing on your smart scale:
1. Open **Garmin Connect** on your phone
2. Read the metrics displayed by your scale
3. **Tap BodyMetrics widget** → Data Entry menu
4. **Enter values** in seconds
5. **Done** — widget updates instantly

---

## 🏗️ Project Structure

```
com.garmin.bodymetrics/
├── source/                 # Monkey C source code
│   ├── BodyMetricsDomain.mc       # Core business logic & domain model
│   ├── use-cases/                  # Use case implementations
│   │   ├── ProfileUseCase.mc
│   │   ├── MeasurementsUseCase.mc
│   │   ├── TargetsUseCase.mc
│   │   ├── TrendUseCase.mc
│   │   └── ResetUserDataUseCase.mc
│   ├── calculators/               # Pure calculation functions
│   │   ├── BmiCalculator.mc
│   │   ├── BmrCalculator.mc
│   │   └── PowerCalculator.mc
│   ├── ui/                        # UI views & navigation
│   │   ├── BodyMetricsView.mc
│   │   ├── views/
│   │   ├── menus/
│   │   └── delegates/
│   └── infrastructure/            # Storage, data providers, i18n
│       ├── DataProvider.mc
│       ├── ThresholdFactory.mc
│       ├── ClassificationPolicy.mc
│       └── [other utilities]
├── resources/              # Localization & assets
│   ├── resources-eng/      # English strings & drawables
│   ├── resources-fre/      # French strings & drawables
│   ├── resources-ita/      # Italian strings & drawables
│   └── resources-spa/      # Spanish strings & drawables
├── docs/                   # Hugo documentation site
│   ├── content/            # Content pages (English + Italian)
│   ├── themes/             # Shiori theme submodule
│   └── sync-to-website.sh  # Script to sync docs to GitHub Pages
├── manifest.xml            # Garmin Connect IQ manifest
├── monkey.jungle           # Build configuration
└── README.md              # This file
```

---

## 🛠️ Development

### Prerequisites

1. **Visual Studio Code** with [Monkey C extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)
2. **Monkey C SDK** (included with VS Code extension)
3. **Garmin Device Simulator** (optional, for testing)

### Building

From VS Code command palette:
```
Monkey C: Build
```

Or from terminal:
```bash
cd /home/gregorio/Software/myProjects/com.garmin.bodymetrics
monk build
```

### Running in Simulator

```
Monkey C: Run (FR265 Simulator)
```

Or use the provided build task:
```bash
.vscode/run-bodymetrics-sim.sh
```

### Code Quality

The codebase follows **Domain-Driven Design** principles:
- **Domain Model** — `BodyMetricsDomain.mc` orchestrates core logic
- **Use Cases** — specific features implemented as independent use cases
- **Calculators** — pure functions with no side effects
- **Separation of Concerns** — UI, storage, and business logic are decoupled
- **Testability** — mock-friendly architecture

---

## 📚 Documentation

Full documentation is available at:

**[BodyMetrics Documentation](https://gregoriolagamba.github.io/bodymetrics/)**

### Key Articles

- **[Getting Started](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/getting-started/)** — step-by-step setup guide
- **[Features](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/features/)** — comprehensive feature reference
- **[Navigation](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/navigation/)** — all keys, menus, and view paths
- **[FAQ](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/faq/)** — common questions and troubleshooting
- **[Architecture](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/design/architecture/)** — internal design and data flow
- **[Changelog](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/changelog/)** — version history and updates

---

## ⚠️ Important Disclaimer

**BodyMetrics provides general health indicators based on standard formulas, NOT clinical data.**

### Data Accuracy
- Metrics are calculated using generic formulas valid for most individuals with indicated profile characteristics
- They are **not** Garmin-certified clinical measurements
- They are approximate indicators, not medical reference values

### Medical Guidance
- Do NOT interpret BodyMetrics data as medical diagnosis or clinical advice
- A green zone does NOT guarantee good health; a red zone does NOT mean illness
- Biological variability is normal; data can be influenced by hydration, measurement timing, scale accuracy, etc.

### Professional Consultation
For accurate body composition assessment and health advice, **consult a qualified nutritionist or your trusted doctor.** BodyMetrics is a **personal monitoring tool**, not a diagnostic device. Important health decisions must be based on verified clinical data, not generic indicators.

---

## 📄 License

This project is licensed under the **Commons Clause License Condition** combined with the **MIT License** — see [LICENSE](LICENSE) file for details.

**Key Points:**
- ✅ Free for personal, non-commercial use and internal organizational use
- ✅ You can modify the code for your own purposes
- ✅ You can study and contribute via pull requests
- ❌ Redistribution, resale, or commercial use requires explicit written permission
- ❌ Hosting as a service without permission is not allowed

If you wish to use BodyMetrics commercially or redistribute it, please contact the author for licensing terms.

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Style
- Follow Monkey C conventions (PascalCase for classes, camelCase for functions)
- Add comments for non-obvious logic
- Keep functions focused and testable

### Testing
- Test your changes in the simulator before submitting
- Verify all supported languages (EN, IT, FR, ES)
- Check for compiler warnings

---

## 📞 Support & Feedback

- **GitHub Issues** — Report bugs or request features
- **Documentation** — Check the [FAQ](https://gregoriolagamba.github.io/bodymetrics/v1.0.0/articles/faq/) for common questions
- **Pull Requests** — Contribute improvements directly

---

## 🗓️ Roadmap

### v1.0.0 (Current - May 2026)
✅ First stable release with core features:
- 9 complete body composition metrics
- Health zone classification system
- Personalized targets and goals
- 7/30/90-day historical trends
- Multilingual support (4 languages)
- Full documentation

### Planned Features
- 🎯 Support for additional Garmin devices (Lite build for FR55, FR735XT)
- 📱 Companion mobile app for detailed analytics

---

## 👤 Author

**Gregorio La Gamba**

- GitHub: [@gregoriolagamba](https://github.com/gregoriolagamba)
- Website: [gregoriolagamba.github.io](https://gregoriolagamba.github.io)

---

## 🎉 Acknowledgments

- **Garmin** for the Connect IQ platform and SDK
- **Hugo** and **Shiori** theme for documentation site
- **Community contributors** and beta testers

---

**BodyMetrics** — Monitor your body composition with awareness.

*A tool to support your wellness journey, not a medical device.*
