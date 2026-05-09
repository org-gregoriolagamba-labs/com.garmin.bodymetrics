# Shared Changelog Template

This file provides a reusable structure for future BodyMetrics release notes.

## Usage Rules

- Copy one block per release into `docs/it/release-notes.md` and `docs/en/release-notes.md`.
- Keep the same release order and section structure in both languages.
- Write only the delta introduced by that release, not the whole historical baseline again.
- Use patch releases such as `1.0.1` for fixes and small adjustments.
- Use minor releases such as `1.1.0` for new features or broader UX and documentation increments.

## Patch Release Template

```md
## 1.0.1

- release identifier or version: `1.0.1`
- date: `YYYY-MM-DD`

### Main Contents

- short summary of the release goal;
- small functional improvement 1;
- small functional improvement 2;

### Relevant Fixes

- bug fix 1;
- bug fix 2;
- bug fix 3;

### Known Limitations

- limitation that still applies;
- scope intentionally not covered by this patch release;

### Release Notes

- note on compatibility, migration, or validation;
- note on what changed compared to the previous release.
```

## Minor Release Template

```md
## 1.1.0

- release identifier or version: `1.1.0`
- date: `YYYY-MM-DD`

### Main Contents

- new feature area 1;
- new feature area 2;
- UX or navigation improvement;
- documentation or operational improvement;

### Relevant Fixes

- important defect fix 1;
- important defect fix 2;

### Known Limitations

- limitation that remains after the minor release;
- dependency or hardware constraint;

### Release Notes

- note on release scope and baseline changes;
- note on backward compatibility or testing status.
```

## Generic Future Release Template

```md
## X.Y.Z

- release identifier or version: `X.Y.Z`
- date: `YYYY-MM-DD`

### Main Contents

- item 1;
- item 2;
- item 3;

### Relevant Fixes

- fix 1;
- fix 2;

### Known Limitations

- limitation 1;
- limitation 2;

### Release Notes

- note 1;
- note 2.
```

## Suggested Writing Style

- Use concise bullets.
- Keep wording factual and version-specific.
- Separate features from fixes.
- Do not list debug-only changes as user-facing features unless they affect release behavior.

## Build Variants Note

When preparing release notes for a future lite build, add a **Build Variants** section listing the target devices, jungle file, and localizations included. Use the pattern established in `1.0.1` release notes as the reference.

## Architectural Refactoring Note

When a release includes internal refactoring with no user-facing changes, document it in a dedicated **Architectural Refactoring** section (as done in `1.0.1`). Keep user-facing and technical changes separate so end users can skip the technical section.