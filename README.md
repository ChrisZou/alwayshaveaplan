# AlwaysHaveAPlan (macOS)

SwiftPM + SwiftUI mac app that:

- Listens for screen unlock / wake events.
- Checks for calendar events happening *right now*.
- If events exist: shows a full-screen, borderless overlay for 3 seconds listing all current events.
- If none: shows a floating always-on-top prompt “当前想要做什么” with a “检查日程” button and opens Calendar.app in background.

## Build / Run

Open `mac_app/Package.swift` in Xcode (File → Open), then Run.

Or build from terminal:

```sh
cd mac_app
swift build
```

To run from terminal and still get Calendar permission prompts, use:

```sh
cd mac_app
swift run
```

This will create (or update) a self-contained app bundle at `./run/AlwaysHaveAPlan.app` and launch it.

## Auto-start on login

The app automatically registers itself as a Login Item on launch. For best results, keep the `.app` at a stable path (don’t delete/move it after registering).

## Debug logs

Logs are written to `~/Library/Logs/AlwaysHaveAPlan.log`.

## Permissions

On first launch, macOS will ask for Calendar access. If you deny it, the app will behave as if there are no current events.
