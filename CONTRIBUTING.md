# Contributing

Thanks for helping improve Paintbrush Paste Fix.

## Development setup

- macOS 13 or later
- Xcode with Swift 6
- Paintbrush 2.6 for manual integration testing

Run the automated tests before submitting a change:

```sh
make test
```

Build the Universal 2 app with:

```sh
make app
```

## Pull requests

- Keep changes focused on Paintbrush clipboard compatibility.
- Add or update tests for image normalization changes.
- Keep the app local-only: do not add analytics, telemetry, accounts, or network services.
- Use English for source comments, documentation, and all user-facing strings.

## Reporting bugs

Please include:

- macOS version and Mac model or CPU architecture
- Paintbrush version
- source application used to copy the image
- screenshot or photo dimensions when available
- Paintbrush zoom level and whether the canvas was scrolled
