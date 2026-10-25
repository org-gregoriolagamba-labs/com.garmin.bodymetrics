# Changelog

All notable changes to BodyMetrics will be documented in this file.

## [1.1.0] - 2026-06-14

### 🎉 Added

- **Multi-device support expansion**: From 1 device (Forerunner 265) to 53 supported Garmin devices
  - Forerunner series: 165/165M, 255M/255SM, 265/265S, 955/965/970, 57 (42mm/47mm)
  - Fenix series: 7 series (all variants), 8 series, Fenix E
  - Epix series: Epix 2 (all variants)
  - Venu series: 2 series, 3 series (all variants)
  - Vivoactive: 5, 6
  - MARQ 2 series: Aviator, Athlete
  - Enduro 3
  - D2 series: Air, Air X10, Mach 1, Delta
  - Instinct 3 AMOLED
  - Descent series: G2, MK, MK 2S
  - Approach series: S70, S70 42mm

- **Automated multi-device build system**
  - `.vscode/build-all-devices.sh`: Comprehensive build validation for all 53 devices
  - `.vscode/run-sim.sh`: Parametrized simulator launcher for device-specific testing
  - `.vscode/tasks.json`: Enhanced with device picker dropdown (53 devices available)

- **Testing infrastructure**
  - Device-specific simulator testing support
  - Comprehensive build report with pass/fail statistics
  - Retry logic for simulator connection (60 attempts, 1-second intervals)

- **Documentation updates**
  - Added "Supported Devices" section with device families and models
  - Updated README with v1.1.0 release information
  - API level references updated throughout documentation

### 🔧 Changed

- **Minimum API Level**: Upgraded from `1.2.0` to `2.3.0`
  - Ensures compatibility with modern Garmin devices
  - Supports Application.Storage required by data persistence layer
  - Avoids API 3.x method argument limit (max 9 arguments)

- **Device filtering strategy**: Implemented rigorous device validation
  - Widget memory constraints (minimum 256 KB for safety margin)
  - API level compatibility checks
  - Screen shape requirements (circular only)
  - Build test validation (all 53 devices pass compilation)

### ⚠️ Removed

- **11 API 3.x incompatible devices** (due to hard method argument limit)
  - Forerunner 745, 945, 945 LTE
  - Descent MK 1, Descent MK 2
  - Descent 2 (with suffix)
  - All MARQ Gen 1 variants (6 models)
  - **Note**: These devices will be added back in a future release when Garmin resolves the API 3.x limitations

- **8 pre-filtered low-memory devices**
  - Devices with widget memory < 256 KB excluded due to safety constraints

### 📊 Testing & Validation

- ✅ Build validation: **53/53 devices pass** (100% success rate)
- ✅ No compiler warnings or failures
- ✅ Comprehensive device compatibility matrix reviewed
- ✅ Simulator testing infrastructure verified and operational

---

## [1.0.0] - 2026-05-30

### 🎉 Added

- **Initial stable release** with complete body composition tracking
- **9 body composition metrics**:
  - Weight (kg)
  - Body Fat (%)
  - Muscle Mass (kg)
  - Body Water (%)
  - Bone Mass (kg)
  - BMI (Body Mass Index)
  - BMR (Basal Metabolic Rate, kcal/day)
  - Muscular Power (W, watts)
  - Percentage metrics derived automatically from measurements

- **Health zone classification system**
  - Green zone: Within healthy range
  - Yellow zone: Mild attention needed
  - Orange zone: Time to take action
  - Red zone: Alarm zone

- **Personalized goal setting**
  - Auto-calculated targets based on sex, age, height, weight, and body type
  - Manual goal customization support
  - Delta (difference) tracking vs. personal targets

- **Historical trend analysis**
  - 7-day trends
  - 30-day trends
  - 90-day trends
  - Trend detection: improving ↗️ / stable ↔️ / declining ↘️

- **Adaptive profiles**
  - General (baseline standard thresholds)
  - Endurance (optimized for cardio athletes)
  - Strength (optimized for power athletes)

- **Multilingual support**
  - English
  - Italiano (Italian)
  - Français (French)
  - Español (Spanish)

- **Data persistence and privacy**
  - Local-only data storage (no cloud transmission)
  - No analytics, advertising, or third-party tracking
  - Complete data control with "Reset All Data" option

- **Domain-Driven Design architecture**
  - Clear separation of concerns (UI, domain, infrastructure)
  - Pure calculation functions
  - Mock-friendly, testable architecture

- **Complete documentation**
  - Getting started guide
  - Feature reference documentation
  - Navigation guide
  - FAQ section
  - Architecture documentation
  - Full Hugo-based documentation site

- **Supported Device**: Forerunner 265 (initial release, single device)

### 📋 Known Limitations

- Body composition data from Index S2 requires manual entry (Garmin API limitation)
- Historical graphs display 7, 30, and 90-day periods only
- Metric calculations based on general population formulas (not clinical-grade)
- Initial release optimized for Forerunner 265 (multi-device support planned for v1.1.0)

---

## Versioning Strategy

This project adheres to [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH** format
- **MAJOR**: Incompatible API or major feature changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible
