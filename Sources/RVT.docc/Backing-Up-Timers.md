# Back up and restore timers

Move a timer setup between installations or keep a copy in Files.

## Overview

Open **About This App** from RVT's settings. Choose **Export Backup** to save a dated `.rvtbackup` file through the system document picker. A location such as iCloud Drive keeps the file available after the app is removed from the device.

Choose **Restore Backup** and select a `.rvtbackup` or earlier `.rivaltbackup` file. RVT validates the file and shows the number of timers and groups before asking for confirmation. Confirming replaces the current timers and settings. Restored presets begin stopped.

## What the file contains

``RiValT_TimerBackup`` encodes a versioned JSON document with group order, timer durations, warning and final thresholds, display and sound settings, selection, and app-wide timer preferences. It stores bundled sound filenames so the destination can resolve them locally.

``RiValT_Settings`` persists the restored model and preferences. A successful restore stops the existing timers, replaces the live model, and publishes the updated state to the Watch remote.

## Backup controls at larger text sizes

``RiValT_About_ViewController`` measures the localized action titles at the preferred text size and gives each button the full available width when two columns would be too narrow. The About screen scrolls when the backup section needs more height. Each button uses its localized title as its accessible name and provides a localized hint about the document picker.
