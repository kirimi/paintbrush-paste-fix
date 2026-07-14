# Paintbrush Paste Fix

<img src="Assets/AppIcon.png" width="160" alt="Paintbrush Paste Fix app icon">

Paintbrush Paste Fix is a tiny, local macOS menu bar utility that fixes cropped and oversized image pasting in Paintbrush 2.6 on Retina displays.

Paintbrush 2.6 can misinterpret the relationship between an image's logical size and its 2× Retina pixel dimensions. A pasted screenshot or photo may therefore appear enlarged, offset, and limited to one quarter of the source image. This utility normalizes the clipboard image to a 1× bitmap before Paintbrush reads it.

## Features

- Fixes Retina screenshots and copied photos before `Command-V`.
- Activates automatically when Paintbrush 2.6 is the frontmost app.
- Includes a manual **Fix Clipboard Now** command.
- Runs entirely on the Mac with no network access or analytics.
- Does not modify Paintbrush or any image files.
- Ships as a Universal 2 app for Apple Silicon and Intel Macs.

## Requirements

- macOS 13 Ventura or later.
- Paintbrush 2.6 with bundle identifier `com.soggywaffles.paintbrush`.

## Installation

1. Download `Paintbrush-Paste-Fix.zip` from the latest GitHub release.
2. Unzip it and move **Paintbrush Paste Fix.app** to the Applications folder.
3. On first launch, Control-click the app, choose **Open**, and confirm. Public builds are ad-hoc signed and are not notarized.
4. Keep the menu bar utility running whenever you use Paintbrush.

No Accessibility, Screen Recording, or Full Disk Access permission is required.

## Usage

1. Launch **Paintbrush Paste Fix**. A photo-with-checkmark icon appears in the menu bar.
2. Copy a screenshot or photo.
3. Switch to Paintbrush 2.6.
4. Paste normally with `Command-V`.

The menu status reports the normalized image size. The clipboard is inspected and rewritten automatically only while Paintbrush is frontmost. The manual menu command can be used at any time.

## Privacy

Paintbrush Paste Fix has no network code, telemetry, analytics, update service, or persistent storage. It reads the current clipboard image only to create equivalent PNG and TIFF representations that Paintbrush can paste correctly.

## Build from source

Xcode with Swift 6 is required.

```sh
make test
make app
```

The app is written to `dist/Paintbrush Paste Fix.app`. To also create the GitHub release archive:

```sh
make release
```

## Project structure

- `Sources/PasteFixCore` — image scale detection and normalization.
- `Sources/PaintbrushPasteFix` — menu bar app and clipboard monitoring.
- `Tests/PasteFixCoreTests` — 1× and 2× image normalization tests.
- `Assets` — application icon source and packaged `.icns` file.
- `scripts` — universal app and release packaging.

## Known limitations

- The automatic fix recognizes the official Paintbrush 2.6 bundle identifier only.
- Paintbrush has a separate upstream placement bug when a zoomed canvas is scrolled away from its top-left corner. This utility primarily addresses the Retina scaling and cropping issue.
- Normalization intentionally converts the clipboard image to a 1× bitmap, reducing the pixel dimensions of 2× Retina screenshots while preserving their on-screen size.

## Disclaimer

This project is an independent compatibility utility. It is not affiliated with, endorsed by, or distributed by the Paintbrush authors. Paintbrush itself is not included.

## License

Paintbrush Paste Fix is available under the [MIT License](LICENSE).
