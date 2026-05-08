# Release Notes

## 1.0.0

- release identifier or version: `1.0.0`
- date: `2026-05-06`
- release type: `first stable release`

### Main Contents

- display of the main body metrics in summary and detail views;
- informational screens with metric descriptions, reference zones, and reading context;
- historical trend visualization with dedicated time windows;
- guided first-run workflow for user profile setup;
- guided workflow for body measurement entry;
- guided workflow for custom target setup;
- delta calculation against the effective target;
- support for weight, body fat, muscle mass, water, and bone mass;
- calculation of derived values such as BMI, muscle percent, reference BMR, and power;
- support for local history used to feed trend charts and informational states;
- distinction between local manual data and weight available from Garmin UserProfile;
- interface language switching;
- full reset of the app's local data;
- project baseline documentation started in bilingual Italian/English form.

### Known Limitations

- documented product target: `fr265`;
- manifest-declared permission: access to `UserProfile`;
- the current `manifest.xml` does not expose a separate in-file application version number for this document;
- debug features exist in code but are outside the end-user release scope;
- not every body metric is provided by Garmin: weight may come from `UserProfile`, while other metrics remain manual-only;
- trend history depends on having enough local data available.

### Release Notes

- this entry represents the first publishable stable availability of BodyMetrics;
- release `1.0.0` defines the official functional baseline reference.
