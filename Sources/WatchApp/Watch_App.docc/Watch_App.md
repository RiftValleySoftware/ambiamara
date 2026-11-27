# ``Watch_App``

Display and control the RiVal.T countdown on Apple Watch.

@Metadata {
    @DisplayName("RiVal.T Remote")
}

## Overview

RiVal.T Remote runs on watchOS 10 or later. The wearer selects a paired iPhone or a nearby iPad through **Timer device**. The paired phone uses WatchConnectivity, while the iPad connection uses ``RiValT_BluetoothRemote``.

The selected host runs the timer and advances its group. ``RiValT_WatchDelegate`` requests a snapshot, converts its deadline to the Watch clock, and sends commands against the host state the wearer saw. The UI model uses confirmed host phase changes to play haptics.

The app delegate receives WatchConnectivity deliveries even when the countdown screen is closed. It waits for pending complication updates to finish writing to the shared store before completing the background refresh task. The Watch Complications extension reads that store to build its timeline.

## Topics

### Countdown screen and lifecycle

- ``RiValT_Watch_App``
- ``RiValT_Watch_AppDelegate``
- ``RiValT_Watch_App_MainContentView``
- ``RiValT_ObservableModel``

### Device selection and timer state

- ``RiValT_WatchDelegate``
- ``RiValT_BluetoothRemote``
- ``RiValT_RemoteState``
- ``RiValT_ComplicationState``
