# ``RiVal_T``

![AmbiaMara Icon](icon.png)

## OVERVIEW

This project is designed to provide executable apps for the iOS/iPadOS App Stores (as native apps), and the Mac App Store (as a [Mac Catalyst](https://developer.apple.com/documentation/uikit/mac-catalyst) executable).

iOS and iPadOS require version 17 or above, and the Mac requires Ventura (Mac OS 13) or above.

The companion Watch app requires watchOS 10 or later.

## BASIC ARCHITECTURE

### THE MODEL

The core of the app, is the ``TimerEngine`` class. This provides the basic timer operation and control. Its domain is just the "ticker," for a single timer. It doesn't define a lot of the app behavior.

Wrapping that, is the ``TimerModel`` class, which adds app behavior to the engine, like multiple timers, and timer groups. Most of the app behavior comes from this class.

The main app owns the timer engine, group selection, and alarms. `RiValT_WatchDelegate` sends the selected timer’s state, available controls, and countdown deadline to the Watch. The Watch uses the deadline to display the remaining time between updates. The main app applies commands and reports the result, including any change to the active timer.

### THE TARGETS

![AmbiaMara Icon](Targets.png)

#### The Main App Target

The main application target is implemented, using Apple's [`UIKit`](https://developer.apple.com/documentation/uikit) application framework. This target is used to build the iOS release (for the iOS App Store), as well as the [Mac Catalyst](https://developer.apple.com/documentation/uikit/mac-catalyst) release (for the Mac App Store).

#### The Watch App and Watch Complication Targets

RiVal.T Remote is a SwiftUI companion embedded in the iOS app. It connects to the paired iPhone through WatchConnectivity. To control an iPad, turn on **Watch Remote** in RiVal.T’s settings on iPad. On the Watch, open **Timer device**, choose **Find nearby iPads**, and select the name shown on the iPad. Check that the pairing code matches and tap **Allow** on the iPad. Close settings and keep RiVal.T in the foreground on the device running the timer. The complication is a separate development target.

#### The Test Targets

There is one target, implementing a SwiftUI test harness for the ``TimerEngine``, and two targets, devoted to unit testing the ``TimerEngine`` and ``TimerModel``. These are only used for testing. The unit tests are not "complete" (providing 100% code coverage), but they do test the crucial functionality of each model subsystem.

## LICENSE

> NOTE: The app code is not licensed for re-use!
> It is "source-available," **NOT** open-source! It does, however, depend on several true, open-source packages (listed below).
> We are not soliciting pull requests or patches. However, if you have a request or an issue, [feel free to contact us.](https://riftvalleysoftware.com/contact)

## DEPENDENCIES

This project depends upon:

- [RVS Basic GCD Timer](https://github.com/RiftValleySoftware/RVS_BasicGCDTimer)
- [RVS Checkbox](https://github.com/RiftValleySoftware/RVS_Checkbox)
- [RVS Generic Swift Toolbox](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox)
- [RVS Persistent Prefs](https://github.com/RiftValleySoftware/RVS_PersistentPrefs)
- [RVS Retro LED Display](https://github.com/RiftValleySoftware/RVS_RetroLEDDisplay)
- [RVS UIKit Toolbox](https://github.com/RiftValleySoftware/RVS_UIKit_Toolbox)
 
It also uses the [Let's Go Digital](https://fonts2u.com/lets-go-digital-regular.font) font, by [Wolf Lambert](https://fonts2u.com/font-designers/wolf-lambert.html)

## MORE INFORMATION:

For more complete instructions, and information about authorship, support, and privacy, visit https://riftvalleysoftware.com/rival-t/
