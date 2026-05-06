# Release Notes

## 1.0.0

- release identifier or version: `1.0.0`
- date: `2026-05-06`

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

### Relevant Fixes Included In The 1.0.0 Baseline

- corrected trend behavior when only one historical point exists by showing a dedicated message instead of an ambiguous state;
- corrected debug-history entry shape so all expected metric fields are included;
- corrected data reload after debug history operations and debug teardown;
- corrected debug badge and menu return behavior during debug actions;
- corrected initial target cycling behavior for fields starting from zero.

### Known Limitations

- documented product target: `fr265`;
- manifest-declared permission: access to `UserProfile`;
- the current `manifest.xml` does not expose a separate in-file application version number for this document;
- debug features exist in code but are outside the end-user release scope;
- not every body metric is provided by Garmin: weight may come from `UserProfile`, while other metrics remain manual-only;
- trend history depends on having enough local data available.

### Release Notes

- this entry represents the documented functional baseline of the first `1.0.0` release;
- future releases should add incremental changes against this baseline instead of rewriting it completely.

## Template For Future Entries

Each new entry should include at least:

- release identifier or version;
- date;
- main contents;
- relevant fixes;
- known limitations when applicable.

## Reusable Template

Use the shared operational template in `docs/shared/changelog-template.md` for upcoming releases.

### Copy-Paste Block For 1.0.1

```md
## 1.0.1

- release identifier or version: `1.0.1`
- date: `YYYY-MM-DD`

### Main Contents

- focused improvement 1;
- focused improvement 2;

### Relevant Fixes

- fix 1;
- fix 2;

### Known Limitations

- still-open limitation 1;
- still-open limitation 2;

### Release Notes

- compatibility or validation note;
- main difference from the previous release.
```

### Copy-Paste Block For 1.1.0

```md
## 1.1.0

- release identifier or version: `1.1.0`
- date: `YYYY-MM-DD`

### Main Contents

- new feature 1;
- new feature 2;
- UX or documentation improvement;

### Relevant Fixes

- major fix 1;
- major fix 2;

### Known Limitations

- remaining limitation 1;
- hardware or integration constraint 2;

### Release Notes

- summary of the minor release impact;
- note on compatibility, testing, or rollout.
```

### Rule For Subsequent Releases

- use patch releases such as `1.0.2` or `1.0.3` for fixes and limited adjustments;
- use minor releases such as `1.2.0` or `1.3.0` when introducing new features or broader flow expansions;
- always keep the same section order to simplify comparison and translation.