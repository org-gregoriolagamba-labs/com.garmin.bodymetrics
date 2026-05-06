# Privacy And Data Handling

## Purpose

This document explains which data BodyMetrics reads, which data it stores locally, how it uses that data, and what happens during reset.

## Data Read From The Garmin Device

BodyMetrics reads the Garmin profile through `UserProfile` when the device exposes it.

The readable data may include:

- weight in kg, derived from the Garmin value stored in grams;
- height in cm;
- sex;
- age band derived from birth year.

BodyMetrics does not read from the Garmin profile:

- body fat percentage;
- muscle percentage;
- water percentage;
- bone mass;
- BMR.

## Data Stored Locally By The App

The app stores data in the device's local app storage for its own operation.

The main categories are:

- manual measurements: weight, body fat, muscle mass, water, bone mass;
- update metadata: save timestamp and weight-source metadata;
- user targets for supported metrics;
- metric history snapshots used by trend;
- app profile state and preferences.

## How The Data Is Used

- Profile data is used to personalize calculations and thresholds.
- Manual measurements are used to display current values, derived metrics, and trend.
- Garmin weight, when present, takes precedence over manual weight in current reads.
- User targets are used to compute delta versus target.
- Local history is used to build trend charts and related state messages.

## Derived Data Not Entered Directly

Some values shown by the app are not entered directly by the user but are derived at runtime or while rebuilding the metric set.

These include:

- muscle percent;
- reference BMR;
- BMI;
- power.

## Data Origin And Priority

- Weight may come from Garmin or from manual entry.
- The other body metrics listed above are handled as local manual data.
- When Garmin provides weight, the app treats it as the preferred read source.

## Reset And Data Deletion

The app's full reset clears or restores the data managed locally by the application.

In practice, reset affects:

- app-stored profile data;
- stored manual measurements;
- user targets;
- local metric history.

The app reset does not claim to delete Garmin-managed data outside BodyMetrics local storage.

## Debug And Temporary Data

Debug features may create or temporarily replace local history for testing purposes. These features are intended for development and validation, not for normal end-user use.

## Limits And Statements

- This document describes behavior observable in the current repository code.
- It does not add promises about cloud synchronization or remote data transmission that are not documented in the code reviewed.
- For export or store-facing material, this page must stay aligned with code and release notes.