# BodyMetrics — Body Composition Tracking for Garmin Forerunner 265

[![License](https://img.shields.io/badge/license-Commons%20Clause%20%2B%20MIT-orange.svg)](LICENSE)
[![Monkey C](https://img.shields.io/badge/language-Monkey%20C-blue.svg)](https://developer.garmin.com/connect-iq/overview/)
[![Version](https://img.shields.io/badge/version-1.1.0-brightgreen.svg)](#releases)
[![API Level](https://img.shields.io/badge/API%20Level-2.3.0+-brightgreen.svg)](#requirements)

**BodyMetrics** is a native **Garmin Connect IQ widget** that brings comprehensive body composition tracking directly to your wrist. Monitor weight, body fat, muscle mass, hydration, bone mass, BMI, BMR, and muscular power — with historical trends, personalized targets, and color-coded health zones. **Now supports 53+ Garmin devices.**

**v1.1.0** — Multi-device expansion (June 14, 2026)  
**Status:** Production-ready | **License:** Commons Clause + MIT | **Languages:** 4 (EN/IT/FR/ES) | **Devices:** 53

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

### 🔐 Privacy & Data Security

- **All data is stored locally** on your device only — no transmission to external servers
- **No analytics, advertising, or third-party tracking**
- **No personal data sharing** with anyone
- Complete control over data deletion via "Reset All Data" option
- See [Privacy Policy](https://gregoriolagamba.github.io/bodymetrics/privacy/) for details

---

## 📋 Requirements

### Hardware
- **Garmin device** from 53 supported models (see [Supported Devices](#supported-devices) section)
- **Garmin Index S2** smart scale (recommended for automatic body composition sync)

### Software
- **Garmin Connect** app installed and configured on your smartphone
- Active phone-to-watch connection for data synchronization

### API Level
- Minimum: **Monkey C SDK 2.3.0**
- Target: **Monkey C SDK 6.x+**

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

## 📱 Supported Devices

BodyMetrics is compatible with **53 Garmin Connect IQ devices**, organized by product family:

### **Forerunner**
- Forerunner 165 / 165M
- Forerunner 255M / 255SM
- Forerunner 265 / 265S
- Forerunner 955 / 965 / 970
- Forerunner 57 (42mm / 47mm)

### **Fenix**
- Fenix 7 / 7S / 7X / 7 Pro / 7S Pro / 7X Pro / 7 Pro No WiFi / 7X Pro No WiFi
- Fenix 8 (43mm / 47mm) / Fenix 8 Pro (47mm) / Fenix 8 Solar (47mm / 51mm)
- Fenix E

### **Epix**
- Epix 2 / Epix 2 Pro (42mm / 47mm / 51mm)

### **Venu**
- Venu 2 / 2S / 2 Plus / SQ / SQ Music
- Venu 3 / 3S

### **Vivoactive**
- Vivoactive 5
- Vivoactive 6

### **MARQ**
- MARQ 2 Aviator / Athlete

### **Enduro**
- Enduro 3

### **D2**
- D2 Air / Air X10 / Mach 1 / Delta

### **Instinct**
- Instinct 3 AMOLED

### **Descent**
- Descent G2 / Descent MK / Descent MK 2S

### **Approach**
- Approach S70 / S70 42mm

**Note:** Minimum API level required is **2.3.0**. All listed devices meet this requirement and have been validated to build successfully.

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

**From VS Code:**
```
Monkey C: Build
```

**From Terminal:**
```bash
cd com.garmin.bodymetrics
monkey build
```

### Running in Simulator

**From VS Code:**
```
Monkey C: Run (FR265 Simulator)
```

**Using the build task:**
```bash
.vscode/run-bodymetrics-sim.sh
```

### Manual Installation (Developers)

To install directly on device or simulator:
```bash
git clone https://github.com/org-gregoriolagamba-labs/com.garmin.bodymetrics.git
cd com.garmin.bodymetrics
monkeyc -d FR265 -y developer_key.key -z manifest.xml -o bin/BodyMetrics.prg
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

- **[Getting Started](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/getting-started/)** — step-by-step setup guide
- **[Features](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/features/)** — comprehensive feature reference
- **[Navigation](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/navigation/)** — all keys, menus, and view paths
- **[FAQ](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/faq/)** — common questions and troubleshooting
- **[Architecture](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/design/architecture/)** — internal design and data flow
- **[Changelog](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/changelog/)** — version history and updates

---

## ⚠️ Important Disclaimers

### Medical Information
**BodyMetrics provides general health indicators based on standard formulas, NOT clinical data.**

- Metrics use **generic scientific formulas** (BMI, BMR, Mifflin-St Jeor formula)
- Results are **NOT certified clinical data** and do NOT replace professional medical consultation
- Results are for **personal informational purposes only**
- NOT intended for medical diagnosis, treatment, or clinical decision-making

**Always consult a healthcare professional** before making significant changes to your health habits, diet, or exercise routine.

### Data Accuracy & Biological Variability
- Calculations are valid for most individuals but individual variation is normal
- Not Garmin-certified clinical measurements
- Data can be influenced by hydration, measurement timing, scale accuracy, and other factors
- A green zone does NOT guarantee good health; a red zone does NOT indicate illness

### Data Synchronization
**Important:** BodyMetrics **does NOT automatically sync body composition data** from your Garmin Index S2 smart scale (API limitation).
- Weight synchronizes automatically via Garmin Connect ✅
- Body composition metrics (fat %, muscle mass, water %, bone mass) require **manual entry** ✅
  - Takes ~10-15 seconds per entry
  - Data is read from Garmin Connect and entered into the app
  - Fully local, no external transmission

---

## 📄 License

This project is licensed under the **Commons Clause License Condition** combined with the **MIT License** — see [LICENSE](LICENSE) file for details.

### ✅ Permitted Uses
- Personal, non-commercial use
- Internal organizational use (non-commercial)
- Code study and learning
- PR contributions and improvements
- Modification for own use
- Reporting issues and feedback

### ❌ Restricted Uses
- Redistribute, resell, or re-license without written consent
- Use as core component of commercial product without permission
- Host, deploy, or provide as a service without permission
- Modify and redistribute without consent from copyright holder
- Commercial sale or commercialization in any form

**For commercial licensing or redistribution exceptions**, contact: **gregoriolagamba@gmail.com**

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
- **Documentation** — Check the [FAQ](https://gregoriolagamba.github.io/bodymetrics/v1.1.0/articles/faq/) for common questions
- **Pull Requests** — Contribute improvements directly

---

## 🗓️ Roadmap

### v1.1.0 (Current - June 14, 2026) ✅
**Multi-device expansion and enhanced build system**:
- ✅ Expanded device support from 1 to 53 Garmin models
  - Forerunner: fr165/m, fr255m/sm, fr265/s, fr955/965/970, fr57042mm/47mm
  - Fenix: 7 series (all variants), 8 series, fenixe
  - Epix: epix2 (all variants)
  - Venu: 2 series, 3 series (all variants)
  - Vivoactive: 5, 6
  - MARQ 2 series, Enduro 3, D2 series, Instinct 3 AMOLED, Descent G2/MK, Approach S70
- ✅ Increased minimum API Level from 1.2.0 to 2.3.0 (better device compatibility)
- ✅ Automated multi-device build system with comprehensive test suite
- ✅ Device-specific simulator testing (parametrized simulator runner)
- ✅ Complete validation: all 53 devices build successfully

### v1.0.0 (May 30, 2026) ✅
**First stable release** with all core features:
- ✅ 9 complete body composition metrics
- ✅ Health zone classification system (Green/Yellow/Orange/Red)
- ✅ Personalized targets and adaptive profiles
- ✅ 7/30/90-day historical trends with visual indicators
- ✅ Multilingual support (4 languages: EN, IT, FR, ES)
- ✅ Full documentation with examples
- ✅ 100% compiler warning resolution
- ✅ Domain-Driven Design architecture

---

## 🐛 Known Limitations

- Body composition data from Index S2 requires manual entry (Garmin API limitation)
- Historical graphs display 7, 30, and 90-day periods only
- Metric calculations based on general population formulas (not clinical-grade)
- Supported on 53 Garmin devices; extensive testing performed on representative sample

---

## 👤 Author

**Gregorio La Gamba**

- GitHub: [@gregoriolagamba](https://github.com/gregoriolagamba)
- Website: [gregoriolagamba.github.io](https://gregoriolagamba.github.io)
- Email: gregoriolagamba@gmail.com

---

## 🎉 Credits & Acknowledgments

**BodyMetrics** was developed with a commitment to:
- Transparency in data collection and processing
- Scientific accuracy in calculations
- User privacy and data security
- Open-source accessibility

**Special thanks to:**
- **Garmin** for the Connect IQ platform and SDK
- **Hugo** and **Shiori** theme for documentation site
- All testers and early adopters for feedback and support

---

**BodyMetrics** — Monitor your body composition with awareness.

*A personal monitoring tool to support your wellness journey, not a medical device.*

**[Documentation](https://gregoriolagamba.github.io/bodymetrics/)** | **[Privacy Policy](https://gregoriolagamba.github.io/bodymetrics/privacy/)**
