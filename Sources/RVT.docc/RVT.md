# ``RVT``

Develop RVT, a grouped countdown timer for iPhone and iPad.

@Metadata {
    @DisplayName("RVT")
}

## Overview

![RVT app icon](icon.png)

The UIKit app runs on iOS and iPadOS 17 or later. It owns the timer engine, timer groups, alarms, and saved preferences. RVT Remote extends its controls to Apple Watch, and the embedded WidgetKit complication displays countdown state on the watch face. Both Watch targets require watchOS 10 or later.

Use the guides below to trace a countdown, follow a remote command, or work with the portable backup format. In Xcode, the **RVT**, **WatchApp**, and **WatchComplications** schemes correspond to the three app targets.

RVT is source-available. Reuse requires written permission from the Great Rift Valley Software Company. The repository README lists the open-source dependencies and font credit. [RVT source repository](https://github.com/RiftValleySoftware/ambiamara)

## Topics

### Development guides

- <doc:Countdowns>
- <doc:Watch-Remote-Integration>
- <doc:Backing-Up-Timers>

### Timer model

- ``TimerEngine``
- ``TimerModel``
- ``TimerGroup``
- ``TimerCountdown``

### App screens and preferences

- ``RiValT_GroupEditor_ViewController``
- ``RiValT_EditTimer_ViewController``
- ``RiValT_RunningTimer_ContainerViewController``
- ``RiValT_About_ViewController``
- ``RiValT_Settings``
- ``RiValT_TimerBackup``

### Hosting a Watch remote

- ``RiValT_AppDelegate``
- ``RiValT_WatchDelegate``
- ``RiValT_BluetoothRemote``
- ``RiValT_RemoteState``
