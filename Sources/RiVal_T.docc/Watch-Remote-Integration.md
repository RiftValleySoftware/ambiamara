# Connecting the Watch remote

Follow a timer request from the Watch to the host and back.

## Overview

The paired iPhone uses WatchConnectivity. A nearby iPad uses an encrypted Bluetooth channel managed by ``RiValT_BluetoothRemote``. Both transports feed requests to ``RiValT_WatchDelegate`` on the host.

### Pair with an iPad

1. Turn on **Watch Remote** in RiVal.T's in-app settings on the iPad.
2. On the Watch, open **Timer device**, choose **Find nearby iPads**, and select the iPad's advertised name.
3. Compare the codes on both devices and tap **Allow** on the iPad.
4. Close settings and keep RiVal.T in the foreground on the host device.

### Follow the state exchange

``RiValT_AppDelegate`` samples the active screen and selected timer together. A ``RiValT_RemoteState/Snapshot`` carries the host's timer phase, deadline, and available commands. The Watch estimates the clock offset so it can update the display between host replies.

A command names the host session and the revision of the controls the wearer saw. The host checks that the revision and command are still valid, applies accepted actions through the same controls used on the host, and replies with a fresh snapshot. Changing the selection or control state can invalidate a command already in flight.

Complication samples can also arrive in the background. These samples support the watch face display. Interactive controls use a live response from the selected host.
