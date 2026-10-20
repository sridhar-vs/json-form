# JSON-Driven Employee Registration Form

A Flutter form engine that builds its fields from [`assets/form_config.json`](assets/form_config.json). The supplied Employee Registration configuration is the source of truth: changing labels, options, validation limits, visibility rules, or dependencies in that file does not require changing the field UI.

## Architecture and data flow

- **Core** contains dependency registration, asset/configuration errors, app navigation, and theme.
- **Data** loads the JSON asset, parses and validates its structure, and implements the repository contract.
- **Domain** contains plain Dart form entities, the repository interface, validation rules, and submission preparation.
- **Presentation** uses one BLoC for loading the configuration and another for field values, visibility, dependent options, validation, and submission.

At startup, `FormConfigBloc` calls `LoadFormConfig`, which asks the repository to load and parse the asset. Once loaded, the page creates a fresh `DynamicFormBloc` for the form instance. Field widgets dispatch value changes; the BLoC recalculates visibility and dependent dropdown options. Submission validates visible fields using `ValidateForm`; only valid data is prepared by `SubmitForm`. A page-level `BlocListener` navigates to the result screen after success. No navigation or widget context is stored in a BLoC.

## Supported configuration

The renderer handles text, email, phone, password, number, date, time, radio, dropdown, multi-select checkbox, single acceptance checkbox, slider, textarea, switch, file upload, and image selection fields. Unknown types show a non-crashing fallback.

Configuration supports required rules, min/max values, min/max text lengths, options, allowed file extensions, `visibleIf` conditions (`equals`, `notEquals`, `contains`, `isEmpty`, and `isNotEmpty`), and dependent dropdowns with `dependsOn` and `optionsMap`. Hidden field values are cleared, and hidden fields are omitted from validation and submission.

## Dependencies

- `flutter_bloc` and `equatable`: immutable BLoC state and event handling.
- `get_it`: factory/lazy-singleton dependency registration.
- `file_picker` and `image_picker`: selecting resume documents and profile images.
- `cupertino_icons`: icon font used by Flutter's Cupertino-style route transitions.
- `bloc_test`: event/state tests.

Validation, JSON parsing, and submission use Flutter/Dart built-ins; no additional result or mocking package is needed.

## Run

```sh
flutter pub get
flutter run
```

Run automated checks:

```sh
flutter analyze
flutter test
```

File and image selections use native/platform picker APIs. The result displays only the selected file's name, extension, size, and `selected_not_uploaded` status; no backend upload is implemented. The iOS photo-library description and macOS user-selected-file entitlements are included in the platform configuration. Android's standard picker flow is used.

## Example displayed submission

```json
{
  "full_name": "Ravi Kumar",
  "email": "ravi@example.com",
  "mobile": "9876543210",
  "age": 32,
  "dob": "1994-06-15",
  "gender": "Male",
  "department": "Engineering",
  "skills": ["Flutter", "Firebase"],
  "experience": 5.0,
  "joining_time": "09:30",
  "resume": {
    "name": "resume.pdf",
    "extension": "pdf",
    "sizeBytes": 24000,
    "status": "selected_not_uploaded"
  },
  "profile_picture": {
    "name": "profile.jpg",
    "extension": "jpg",
    "sizeBytes": 18000,
    "status": "selected_not_uploaded"
  },
  "address": "Chennai",
  "is_married": false,
  "country": "India",
  "state": "Tamil Nadu",
  "accept_terms": true
}
```

The password is intentionally excluded. `spouse_name` is excluded while its visibility condition is false. File paths and platform file objects are not serialized. This output is illustrative; actual selected file metadata and entered values determine the result.

## Manual checklist

1. Run the app and confirm the title and submit label come from JSON.
2. Submit an empty form and confirm required errors prevent navigation.
3. Select **Married** and verify **Spouse Name** appears; turn it off and confirm it disappears.
4. Select a country and verify the State options change; change country and confirm an incompatible state selection clears.
5. Choose a permitted resume file, then submit a valid form; verify metadata is displayed without path/password.
6. Edit a field label or option in `assets/form_config.json`, restart, and verify the rendered form reflects it.

Sensitive fields should be handled by an authenticated API and excluded from logs and user-facing result output. This sample does not transmit form data or upload files.
